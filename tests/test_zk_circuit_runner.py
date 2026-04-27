import contextlib
import io
import tempfile
from pathlib import Path
from unittest import TestCase

from source.battleship_zk import (
    commitment_for,
    make_hit_response,
    make_secret,
    setup_battleship_circuit,
    verify_hit_response,
)
from source.constants import HIT_STR, MISS_STR
from source.coordinate import Coordinate
from source.zk_circuit_runner import (
    ProofArtifacts,
    ProofPayload,
    ZKCircuitRunnerError,
    main,
    prove_groth16_inputs,
    setup_groth16_circuit,
    verify_groth16_proof,
)


class ZKCircuitRunnerTests(TestCase):
    def test_proof_payload_round_trips_metadata_and_public_inputs(
        self,
    ) -> None:
        payload = ProofPayload(
            proof={"pi_a": ["1", "2", "1"]},
            public=["1", 2, "3"],
            metadata={"result": HIT_STR},
        )

        parsed = ProofPayload.from_json(payload.to_json())

        self.assertEqual(parsed.metadata["result"], HIT_STR)
        parsed.require_public_inputs([1, "2", 3])

    def test_battleship_hit_and_miss_proofs_verify(self) -> None:
        setup_battleship_circuit()
        secret = make_secret(Coordinate("A", 1), salt=3)
        commitment = commitment_for(secret)

        hit_response = make_hit_response(
            Coordinate("A", 1),
            hit=True,
            result=HIT_STR,
            commitment=commitment,
            secret=secret,
        )
        miss_response = make_hit_response(
            Coordinate("A", 2),
            hit=False,
            result=MISS_STR,
            commitment=commitment,
            secret=secret,
        )

        self.assertEqual(
            verify_hit_response(
                hit_response,
                guess=Coordinate("A", 1),
                expected_commitment=commitment,
            ),
            HIT_STR,
        )
        self.assertEqual(
            verify_hit_response(
                miss_response,
                guess=Coordinate("A", 2),
                expected_commitment=commitment,
            ),
            MISS_STR,
        )

    def test_python_api_sets_up_proves_and_verifies(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            build_dir = Path(temp_dir) / "build"
            proof_dir = Path(temp_dir) / "proofs"

            setup_groth16_circuit(
                Path("circuits/polynomial.circom"),
                output_dir=build_dir,
                power=4,
                entropy="test",
            )

            proof = prove_groth16_inputs(
                Path("circuits/polynomial.circom"),
                {"x": 9, "y": 113},
                build_dir=build_dir,
                output_dir=proof_dir,
            )

            self.assertTrue(proof.proof_path.exists())
            self.assertTrue(proof.public_path.exists())
            self.assertTrue(
                verify_groth16_proof(
                    Path("circuits/polynomial.circom"),
                    proof,
                    build_dir=build_dir,
                )
            )

    def test_cli_sets_up_proves_and_verifies(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            build_dir = Path(temp_dir) / "build"
            proof_dir = Path(temp_dir) / "proofs"

            setup_exit_code = _run_cli(
                [
                    "setup",
                    "circuits/polynomial.circom",
                    "--out-dir",
                    str(build_dir),
                    "--power",
                    "4",
                    "--entropy",
                    "test",
                ]
            )

            self.assertEqual(setup_exit_code, 0)

            prove_exit_code = _run_cli(
                [
                    "prove",
                    "circuits/polynomial.circom",
                    "--input",
                    '{"x": 9, "y": 113}',
                    "--build-dir",
                    str(build_dir),
                    "--out-dir",
                    str(proof_dir),
                ]
            )

            self.assertEqual(prove_exit_code, 0)
            self.assertTrue((proof_dir / "proof.json").exists())
            self.assertTrue((proof_dir / "proof.public.json").exists())

            verify_exit_code = _run_cli(
                [
                    "verify",
                    "circuits/polynomial.circom",
                    "--proof",
                    str(proof_dir / "proof.json"),
                    "--public",
                    str(proof_dir / "proof.public.json"),
                    "--build-dir",
                    str(build_dir),
                ]
            )

            self.assertEqual(verify_exit_code, 0)

    def test_python_api_rejects_invalid_input(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            build_dir = Path(temp_dir) / "build"
            proof_dir = Path(temp_dir) / "proofs"

            setup_groth16_circuit(
                Path("circuits/polynomial.circom"),
                output_dir=build_dir,
                power=4,
                entropy="test",
            )

            with self.assertRaises(ZKCircuitRunnerError):
                prove_groth16_inputs(
                    Path("circuits/polynomial.circom"),
                    {"x": 9, "y": 114},
                    build_dir=build_dir,
                    output_dir=proof_dir,
                )

    def test_verifier_rejects_invalid_proof(self) -> None:
        proof = ProofArtifacts(
            proof_path=Path("missing-proof.json"),
            public_path=Path("missing-public.json"),
        )

        with self.assertRaises(ZKCircuitRunnerError):
            verify_groth16_proof(Path("circuits/polynomial.circom"), proof)


def _run_cli(argv: list[str]) -> int:
    with contextlib.redirect_stdout(io.StringIO()):
        with contextlib.redirect_stderr(io.StringIO()):
            return main(argv)
