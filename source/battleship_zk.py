import subprocess
from dataclasses import dataclass
from pathlib import Path

from source.constants import HIT_STR, LOST_STR, MISS_STR, ROWS, SHIP_LENGTHS
from source.coordinate import Coordinate
from source.zk_circuit_runner import (
    ProofPayload,
    ZKCircuitRunnerError,
    manifest_path_for,
    prove_groth16_payload,
    setup_groth16_circuit,
    verify_groth16_payload,
)


BATTLESHIP_CIRCUIT = Path("circuits/battleship_hit.circom")
BOARD_CIRCUIT = Path("circuits/board_commitment.circom")


@dataclass(frozen=True, slots=True)
class BattleshipSecret:
    ship_coordinate: Coordinate
    salt: int

    @property
    def ship_x(self) -> int:
        return coordinate_fields(self.ship_coordinate)[0]

    @property
    def ship_y(self) -> int:
        return coordinate_fields(self.ship_coordinate)[1]


@dataclass(frozen=True, slots=True)
class BoardSecret:
    start_x: list[int]
    start_y: list[int]
    dir: list[int]
    salt: int

    def __post_init__(self) -> None:
        if not (len(self.start_x) == len(self.start_y) == len(self.dir) == 5):
            raise ValueError(
                "BoardSecret start_x, start_y, and dir must be length 5"
            )
        if any(d not in {0, 1} for d in self.dir):
            raise ValueError("BoardSecret dir values must be 0 or 1")


def setup_battleship_circuit() -> None:
    """Ensure the Battleship hit circuit has proving artifacts."""
    if not manifest_path_for(BATTLESHIP_CIRCUIT).exists():
        setup_groth16_circuit(BATTLESHIP_CIRCUIT)


def setup_board_circuit() -> None:
    if not manifest_path_for(BOARD_CIRCUIT).exists():
        setup_groth16_circuit(BOARD_CIRCUIT)


def make_secret(
    ship_coordinate: Coordinate, salt: int = 3
) -> BattleshipSecret:
    return BattleshipSecret(ship_coordinate=ship_coordinate, salt=salt)


def commitment_for(secret: BattleshipSecret) -> str:
    return poseidon_hash(secret.ship_x, secret.ship_y, secret.salt)


def make_hit_response(
    guess: Coordinate,
    *,
    hit: bool,
    result: str,
    commitment: str,
    secret: BattleshipSecret,
) -> str:
    """Return a JSON response containing the result and proof."""
    setup_battleship_circuit()
    guess_x, guess_y = coordinate_fields(guess)
    payload = prove_groth16_payload(
        BATTLESHIP_CIRCUIT,
        {
            "pubGuessX": guess_x,
            "pubGuessY": guess_y,
            "pubCommitment": commitment,
            "pubReportedHit": 1 if hit else 0,
            "privShipX": secret.ship_x,
            "privShipY": secret.ship_y,
            "privSalt": secret.salt,
        },
        metadata={"result": result},
    )
    return payload.to_json()


def verify_hit_response(
    raw_response: str,
    *,
    guess: Coordinate,
    expected_commitment: str,
) -> str:
    """Verify a proof-bearing response and return HIT, MISS, or LOST."""
    setup_battleship_circuit()
    payload = ProofPayload.from_json(raw_response)

    if (result := str(payload.metadata.get("result"))) not in {
        HIT_STR,
        MISS_STR,
        LOST_STR,
    }:
        raise ZKCircuitRunnerError(f"invalid Battleship result: {result!r}")

    reported_hit = 1 if result in {HIT_STR, LOST_STR} else 0
    guess_x, guess_y = coordinate_fields(guess)
    expected_public = [
        str(guess_x),
        str(guess_y),
        str(expected_commitment),
        str(reported_hit),
    ]
    payload.require_public_inputs(expected_public)

    if not verify_groth16_payload(BATTLESHIP_CIRCUIT, payload):
        raise ZKCircuitRunnerError("invalid Battleship proof")
    return result


def coordinate_fields(coordinate: Coordinate) -> tuple[int, int]:
    return ROWS.index(coordinate.row) + 1, coordinate.column


def poseidon_hash(*values: int) -> str:
    script = (
        "const {buildPoseidon}=require('circomlibjs');"
        "(async()=>{"
        "const poseidon=await buildPoseidon();"
        "const values=process.argv.slice(1).map(BigInt);"
        "console.log(poseidon.F.toString(poseidon(values)));"
        "})().catch((err)=>{console.error(err);process.exit(1);});"
    )
    result = subprocess.run(
        ("node", "-e", script, *(str(value) for value in values)),
        cwd=Path(__file__).resolve().parents[1],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise ZKCircuitRunnerError(result.stderr.strip())
    return result.stdout.strip()


def board_commitment_for(secret: BoardSecret) -> str:
    flat: list[int] = []

    for i in range(5):
        flat.append(secret.start_x[i])
        flat.append(secret.start_y[i])
        flat.append(secret.dir[i])

    flat.append(secret.salt)
    return poseidon_hash(*flat)


def validate_ship(sx: int, sy: int, length: int, direction: int) -> bool:
    ex = sx + length - 1 if direction == 0 else sx
    ey = sy + length - 1 if direction == 1 else sy
    return 1 <= sx <= 10 and 1 <= sy <= 10 and 1 <= ex <= 10 and 1 <= ey <= 10


def validate_no_overlap(secret: BoardSecret) -> bool:
    grid: set[tuple[int, int]] = set()

    for i in range(5):
        x, y = secret.start_x[i], secret.start_y[i]
        d = secret.dir[i]
        l = SHIP_LENGTHS[i]

        for j in range(l):
            cx = x + j if d == 0 else x
            cy = y + j if d == 1 else y

            if (cx, cy) in grid:
                return False

            grid.add((cx, cy))

    return True


def prove_board(secret: BoardSecret) -> str:
    if not all(
        validate_ship(
            secret.start_x[i],
            secret.start_y[i],
            SHIP_LENGTHS[i],
            secret.dir[i],
        )
        for i in range(5)
    ):
        raise ValueError("Invalid ship placement")
    if not validate_no_overlap(secret):
        raise ValueError("Overlapping ships")

    setup_board_circuit()

    payload = prove_groth16_payload(
        BOARD_CIRCUIT,
        {
            "privStartX": secret.start_x,
            "privStartY": secret.start_y,
            "privDirections": secret.dir,
            "privSalt": secret.salt,
            "pubBoardCommitment": board_commitment_for(secret),
        },
    )
    return payload.to_json()


def verify_board(raw_response: str, expected_commitment: str) -> None:
    setup_board_circuit()
    payload = ProofPayload.from_json(raw_response)
    payload.require_public_inputs([expected_commitment])

    if not verify_groth16_payload(BOARD_CIRCUIT, payload):
        raise ZKCircuitRunnerError("invalid board proof")

    print("Board proof verified!")
