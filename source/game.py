import json
from dataclasses import dataclass, field
from queue import Empty
from secrets import randbelow
from time import perf_counter

from source.battleship_zk import (
    BoardSecret2,
    make_board_secret_2,
    make_hit_response2,
    prove_board2,
    setup_battleship_circuit_2,
    verify_board2,
    verify_hit_response2,
)
from source.client import recv, send
from source.constants import (
    HIT_STR,
    LOST_MSG,
    LOST_STR,
    MISS_STR,
    QUIT_STR,
    REPLAY_MSG,
    REPLAY_STR,
    ROWS,
    TURN_MSG,
    WIN_MSG,
)
from source.coordinate import Coordinate
from source.player import Player
from source.pygame_ui import PygameUI
from source.zk_circuit_runner import ZKCircuitRunnerError


@dataclass(slots=True)
class ProofTiming:
    operation: str
    coordinate: Coordinate
    seconds: float


@dataclass(slots=True)
class Game:
    player: Player
    secret: BoardSecret2 | None = None
    commitment: str | None = None
    opponent_commitment: str | None = None
    last_action_status: str = ""
    proof_timings: list[ProofTiming] = field(default_factory=list)
    initial_proof: str | None = None

    def __post_init__(self) -> None:
        setup_battleship_circuit_2()

    def check_lost(self) -> bool:
        return self.player.board.check_all_ships_sunk()

    def handle_my_go(self, ui: PygameUI) -> str:
        if (
            choice := ui.wait_for_target_click(
                self.player.board, status=self._status(TURN_MSG)
            )
        ) is None:
            return "quit"

        row, col = choice
        coordinate = Coordinate(ROWS[row], col + 1)

        send(self.player.conn, str(coordinate))

        ui.draw(self.player.board, status="Verifying opponent's proof...")
        raw_response = self._recv_with_ui(
            ui, status="Waiting for opponent's proof..."
        )
        if raw_response is None:
            return "quit"

        ui.set_proof_lines(
            [
                "Proof Inspector",
                f"Received proof for guess {coordinate}.",
                f"Expected commitment: {self._short(self._opponent_commitment())}",
                "Checking public inputs and Groth16 proof...",
            ]
        )
        verify_started = perf_counter()
        try:
            result = verify_hit_response2(
                raw_response,
                guess=coordinate,
                expected_commitment=self._opponent_commitment(),
            )
        except ZKCircuitRunnerError as error:
            verify_seconds = perf_counter() - verify_started
            self.proof_timings.append(
                ProofTiming("reject", coordinate, verify_seconds)
            )
            self.last_action_status = (
                f"Proof REJECTED at {coordinate}: {error}"
            )
            ui.set_proof_lines(
                [
                    "Proof Inspector",
                    f"Claim for {coordinate}: REJECTED in {verify_seconds:.2f}s",
                    f"Reason: {error}",
                    "The reported result did not match the committed secret.",
                ]
            )
            ui.draw(self.player.board, status=self.last_action_status)
            return "rejected"

        verify_seconds = perf_counter() - verify_started
        self.proof_timings.append(
            ProofTiming("verify", coordinate, verify_seconds)
        )
        ui.draw(self.player.board, status="Opponent's proof verified.")
        hit = result in {HIT_STR, LOST_STR}
        self.player.board.check_hit_on_other(coordinate, hit)
        ui.set_proof_lines(
            [
                "Proof Inspector",
                f"Claim for {coordinate}: {result}",
                f"Commitment checked: {self._short(self._opponent_commitment())}",
                f"Verification PASSED in {verify_seconds:.2f}s",
                "Private ship location stayed hidden.",
            ]
        )
        self.last_action_status = self._shot_status(
            "Your shot",
            coordinate,
            hit,
            proof_status=f"Verified in {verify_seconds:.2f}s",
        )

        if result == LOST_STR:
            ui.draw(self.player.board, status=WIN_MSG)
            return "won"
        return "continue"

    def handle_opponent_go(self, ui: PygameUI) -> str:
        ui.draw(
            self.player.board, status=self._status("Waiting for opponent...")
        )

        raw_coordinate = self._recv_with_ui(
            ui, status=self._status("Waiting for opponent...")
        )
        if raw_coordinate is None:
            return "quit"

        coordinate = Coordinate.from_str(raw_coordinate)
        hit = self.player.board.check_hit_on_self(coordinate)
        result = (
            LOST_STR
            if hit and self.check_lost()
            else HIT_STR if hit else MISS_STR
        )
        ui.set_proof_lines(
            [
                "Proof Inspector",
                f"Generating proof for opponent guess {coordinate}.",
                f"Public claim: {result}",
                f"Commitment: {self._short(self._commitment())}",
                "Private inputs: ship coordinate and salt are hidden.",
            ]
        )
        ui.draw(self.player.board, status="Generating proof...")
        generate_started = perf_counter()
        response = make_hit_response2(
            coordinate,
            hit=hit,
            result=result,
            commitment=self._commitment(),
            secret=self._secret(),
        )
        generate_seconds = perf_counter() - generate_started
        self.proof_timings.append(
            ProofTiming("generate", coordinate, generate_seconds)
        )
        if ui.cheat_mode:
            response = self._tamper_hit_response(response)

        sent_result = self._response_result(response)
        inspector_result = (
            f"Tampered claim sent: {sent_result}"
            if ui.cheat_mode
            else f"Claim sent: {sent_result}"
        )
        ui.set_proof_lines(
            [
                "Proof Inspector",
                inspector_result,
                f"Proof generated in {generate_seconds:.2f}s",
                f"Commitment used: {self._short(self._commitment())}",
                (
                    "Verifier should reject tampering."
                    if ui.cheat_mode
                    else "Verifier can check this without seeing your ship."
                ),
            ]
        )
        ui.draw(self.player.board, status="Proof generated.")
        send(self.player.conn, response)
        self.last_action_status = self._shot_status(
            "Opponent's shot",
            coordinate,
            hit,
            proof_status=f"Generated in {generate_seconds:.2f}s",
        )

        if hit and self.check_lost():
            ui.draw(self.player.board, status=LOST_MSG)
            return "lost"

        if ui.cheat_mode:
            return "rejected"

        return "continue"

    def run(self, ui: PygameUI, *, starter_is_my_turn: bool) -> bool:
        ui.draw(self.player.board, status="Exchanging commitments...")
        if not self.exchange_commitments(ui):
            return False
        ui.draw(self.player.board, status="Commitments exchanged.")

        my_go = starter_is_my_turn
        round_result = "continue"

        while round_result == "continue":
            round_result = (
                self.handle_my_go(ui) if my_go else self.handle_opponent_go(ui)
            )
            if round_result == "continue":
                my_go = not my_go

        if round_result == "quit":
            return False

        self._print_proof_timing_summary()
        return self._agree_to_replay(ui, round_result)

    def _agree_to_replay(self, ui: PygameUI, round_result: str) -> bool:
        prompt = (
            f"Proof rejected! {REPLAY_MSG}"
            if round_result == "rejected"
            else f"{WIN_MSG if round_result == 'won' else LOST_MSG} {REPLAY_MSG}"
        )
        wants_replay = ui.wait_for_replay(self.player.board, status=prompt)
        send(self.player.conn, REPLAY_STR if wants_replay else QUIT_STR)
        raw_replay = self._recv_with_ui(
            ui, status="Waiting for opponent's replay choice..."
        )
        if raw_replay is None:
            return False
        opponent_wants_replay = raw_replay == REPLAY_STR
        return wants_replay and opponent_wants_replay

    def exchange_commitments(self, ui: PygameUI) -> bool:
        shipx_coords = [
            ROWS.index(coord.row) + 1
            for ship in self.player.ships
            for coord in ship._get_all_coordinates()
        ]
        shipy_coords = [
            coord.column
            for ship in self.player.ships
            for coord in ship._get_all_coordinates()
        ]
        salt = randbelow(2**32)
        self.secret = make_board_secret_2(
            ships_x=shipx_coords, ships_y=shipy_coords, salt=salt
        )
        self.initial_proof = prove_board2(self.secret)
        self.commitment = json.loads(self.initial_proof)["public"][0]

        send(self.player.conn, self._commitment())
        self.opponent_commitment = self._recv_with_ui(
            ui, status="Exchanging commitments..."
        )
        if self.opponent_commitment is not None:
            ui.set_proof_lines(
                [
                    "Proof Inspector",
                    f"Your commitment: {self._short(self._commitment())}",
                    f"Opponent commitment: {self._short(self.opponent_commitment)}",
                    "Each proof must match these locked commitments.",
                ]
            )
        return self.opponent_commitment is not None

    def _recv_with_ui(self, ui: PygameUI, *, status: str) -> str | None:
        while True:
            ui.draw(self.player.board, status=status)
            if not ui.pump_events():
                return None

            try:
                return recv(timeout=1 / ui.FPS)
            except Empty:
                continue

    def _status(self, current_status: str) -> str:
        if not self.last_action_status:
            return current_status
        return f"{self.last_action_status}\n{current_status}"

    def _print_proof_timing_summary(self) -> None:
        if not self.proof_timings:
            return

        print()
        print("Proof timing summary:")
        for timing in self.proof_timings:
            print(
                f"- {timing.operation} at {timing.coordinate}: "
                f"{timing.seconds:.2f}s"
            )

    @staticmethod
    def _response_result(raw_response: str) -> str:
        try:
            return str(json.loads(raw_response)["metadata"]["result"])
        except (KeyError, TypeError, json.JSONDecodeError):
            return "unknown"

    @staticmethod
    def _tamper_hit_response(raw_response: str) -> str:
        payload = json.loads(raw_response)
        result = str(payload["metadata"]["result"])
        payload["metadata"]["result"] = (
            MISS_STR if result in {HIT_STR, LOST_STR} else HIT_STR
        )
        return json.dumps(payload, separators=(",", ":"))

    @staticmethod
    def _short(value: str) -> str:
        if len(value) <= 18:
            return value
        return f"{value[:8]}...{value[-8:]}"

    @staticmethod
    def _shot_status(
        actor: str,
        coordinate: Coordinate,
        hit: bool,
        *,
        proof_status: str = "",
    ) -> str:
        result = "Hit" if hit else "Miss"
        status = f"{actor} at {coordinate}: {result}."
        if proof_status:
            return f"{status} {proof_status}."
        return status

    def exchange_initial_proofs(self) -> None:
        send(self.player.conn, self.initial_proof or "")
        msg = recv()
        self.opponent_commitment = json.loads(msg)["public"][0]
        verify_board2(msg)

    def _secret(self) -> BoardSecret2:
        if self.secret is None:
            raise RuntimeError("Battleship ZK secret is not initialized")
        return self.secret

    def _commitment(self) -> str:
        if self.commitment is None:
            raise RuntimeError("Battleship commitment is not initialized")
        return self.commitment

    def _opponent_commitment(self) -> str:
        if self.opponent_commitment is None:
            raise RuntimeError("Opponent commitment is not initialized")
        return self.opponent_commitment
