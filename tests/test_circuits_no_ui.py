#!/usr/bin/env python3
import sys
import traceback

from source.battleship_zk import (
    BoardSecret2,
    board_commitment_for2,
    make_hit_response2,
    prove_board2,
    verify_board2,
    verify_hit_response2,
)
from source.constants import HIT_STR, MISS_STR
from source.coordinate import Coordinate


def test_board_commitment() -> tuple[BoardSecret2, str, str]:
    ships_x = [1] * 5 + [2] * 4 + [3] * 3 + [4] * 3 + [5] * 2
    ships_y = [1, 2, 3, 4, 5, 1, 2, 3, 4, 1, 2, 3, 1, 2, 3, 1, 2]
    salt = 42
    secret = BoardSecret2(ships_x=ships_x, ships_y=ships_y, salt=salt)

    print("Created BoardSecret2 with 17 coordinates")
    print(f"  Ships X: {ships_x}")
    print(f"  Ships Y: {ships_y}")
    print(f"  Salt: {salt}")

    commitment = board_commitment_for2(secret)
    print(f"Calculated Python merkle root: {commitment}")

    print("Generating board proof...")
    proof = prove_board2(secret)
    print(f"Proof generated ({len(proof)} bytes)")

    print("Verifying board proof...")
    verify_board2(proof)
    print("Board proof verified!")
    return secret, commitment, proof


def test_hit_response(secret: BoardSecret2, board_commitment: str) -> str:
    guess = Coordinate(row="A", column=1)
    hit = True
    result = HIT_STR

    print(f"Testing guess at {guess} (hit={hit})")
    print("Generating hit response proof...")
    proof = make_hit_response2(
        guess,
        hit=hit,
        result=result,
        commitment=board_commitment,
        secret=secret,
    )
    print(f"Hit response proof generated ({len(proof)} bytes)")
    print("Verifying hit response proof...")
    verified_result = verify_hit_response2(
        proof,
        guess=guess,
        expected_commitment=board_commitment,
    )
    print(f"Hit response verified as: {verified_result}")
    assert (
        verified_result == result
    ), f"Expected {result}, got {verified_result}"

    return proof


def test_miss_response(secret: BoardSecret2, board_commitment: str) -> str:
    guess = Coordinate(row="F", column=6)
    hit = False
    result = MISS_STR

    print(f"Testing guess at {guess} (hit={hit})")
    print("Generating miss response proof...")
    proof = make_hit_response2(
        guess,
        hit=hit,
        result=result,
        commitment=board_commitment,
        secret=secret,
    )
    print(f"Miss response proof generated ({len(proof)} bytes)")

    print("Verifying miss response proof...")
    verified_result = verify_hit_response2(
        proof,
        guess=guess,
        expected_commitment=board_commitment,
    )
    print(f"Miss response verified as: {verified_result}")
    assert (
        verified_result == result
    ), f"Expected {result}, got {verified_result}"
    return proof


def main() -> int:
    try:
        secret, commitment, _ = test_board_commitment()
        test_hit_response(secret, commitment)
        test_miss_response(secret, commitment)

        print("All circuit compilation tests PASSED")
        print("All proof generation tests PASSED")
        print("All proof verification tests PASSED")
        print("Ready for integration with pygame UI!")
    except Exception as e:
        print(f"TEST FAILED: {e}")
        traceback.print_exc()
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
