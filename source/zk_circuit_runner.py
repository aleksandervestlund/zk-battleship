import argparse
import json
import secrets
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Mapping
from dataclasses import dataclass
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[1]
CIRCUITS_DIR = REPO_ROOT / "circuits"
CIRCUIT_BUILD_DIR = CIRCUITS_DIR / "build"
WINDOWS = sys.platform == "win32"


def _local_node_bin(command: str) -> tuple[str, ...] | None:
    executable = REPO_ROOT / "node_modules" / ".bin" / (
        f"{command}.cmd" if WINDOWS else command
    )
    if executable.exists():
        return (str(executable),)
    return None


def _node_tool_command(command: str) -> tuple[str, ...]:
    return _local_node_bin(command) or (
        "npx.cmd" if WINDOWS else "npx",
        "--no-install",
        command,
    )


def _circom_command() -> tuple[str, ...]:
    if shutil.which("circom"):
        return ("circom",)

    windows_launcher = REPO_ROOT / "scripts" / "circom2.js"
    if WINDOWS and windows_launcher.exists():
        return ("node", str(windows_launcher))

    return _node_tool_command("circom2")


CIRCOM_COMMAND = _circom_command()
SNARKJS_COMMAND = _node_tool_command("snarkjs")
MANIFEST_FILENAME = "artifacts.json"


class ZKCircuitRunnerError(RuntimeError):
    """Raised when an external ZK tool cannot complete a requested command."""


class SnarkJSError(ZKCircuitRunnerError):
    """Raised when snarkjs cannot complete a command."""


class CircomError(ZKCircuitRunnerError):
    """Raised when circom cannot compile a circuit."""


@dataclass(frozen=True, slots=True)
class CommandOutput:
    stdout: str
    stderr: str
    returncode: int


@dataclass(frozen=True, slots=True)
class CircuitArtifacts:
    """Files produced by compiling and setting up a Groth16 circuit."""

    name: str
    r1cs_path: Path
    wasm_path: Path
    zkey_path: Path
    verification_key_path: Path

    @classmethod
    def load(cls, manifest_path: Path) -> "CircuitArtifacts":
        """Load artifact paths from a JSON manifest."""
        base_dir = manifest_path.parent
        try:
            data = json.loads(manifest_path.read_text(encoding="utf-8"))
        except OSError as error:
            raise ZKCircuitRunnerError(
                f"could not read {manifest_path}: {error}"
            ) from error
        except json.JSONDecodeError as error:
            raise ZKCircuitRunnerError(
                f"invalid artifact manifest {manifest_path}: {error}"
            ) from error

        try:
            return cls(
                name=str(data["name"]),
                r1cs_path=_manifest_path(base_dir, data["r1cs_path"]),
                wasm_path=_manifest_path(base_dir, data["wasm_path"]),
                zkey_path=_manifest_path(base_dir, data["zkey_path"]),
                verification_key_path=_manifest_path(
                    base_dir,
                    data["verification_key_path"],
                ),
            )
        except KeyError as error:
            raise ZKCircuitRunnerError(
                f"artifact manifest {manifest_path} is missing {error.args[0]!r}"
            ) from error

    def write_manifest(self, manifest_path: Path) -> None:
        """Write artifact paths to a JSON manifest."""
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "schema_version": 1,
            "name": self.name,
            "r1cs_path": _json_path(self.r1cs_path, manifest_path.parent),
            "wasm_path": _json_path(self.wasm_path, manifest_path.parent),
            "zkey_path": _json_path(self.zkey_path, manifest_path.parent),
            "verification_key_path": _json_path(
                self.verification_key_path,
                manifest_path.parent,
            ),
        }
        manifest_path.write_text(
            json.dumps(data, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )


@dataclass(frozen=True, slots=True)
class ProofArtifacts:
    """Files produced by a Groth16 proof run."""

    proof_path: Path
    public_path: Path


@dataclass(frozen=True, slots=True)
class ProofPayload:
    """Serializable Groth16 proof payload for network messages."""

    proof: Any
    public: list[Any]
    metadata: Mapping[str, Any]

    @classmethod
    def from_artifacts(
        cls,
        proof: ProofArtifacts,
        *,
        metadata: Mapping[str, Any] | None = None,
    ) -> "ProofPayload":
        return cls(
            proof=_read_json(proof.proof_path),
            public=_read_json(proof.public_path),
            metadata=dict(metadata or {}),
        )

    @classmethod
    def from_json(cls, raw_payload: str) -> "ProofPayload":
        try:
            data = json.loads(raw_payload)
        except json.JSONDecodeError as error:
            raise ZKCircuitRunnerError(
                f"invalid proof payload JSON: {error}"
            ) from error

        try:
            return cls(
                proof=data["proof"],
                public=list(data["public"]),
                metadata=dict(data.get("metadata", {})),
            )
        except (KeyError, TypeError, ValueError) as error:
            raise ZKCircuitRunnerError("invalid proof payload") from error

    def to_json(self) -> str:
        return json.dumps(
            {
                "metadata": dict(self.metadata),
                "proof": self.proof,
                "public": self.public,
            },
            separators=(",", ":"),
        )

    def require_public_inputs(self, expected_public_inputs: list[Any]) -> None:
        expected = [str(value) for value in expected_public_inputs]
        print(f"Expected public inputs: {expected}")
        actual = [str(value) for value in self.public]
        print(f"Actual public inputs: {actual}")
        if actual != expected:
            raise ZKCircuitRunnerError("proof public inputs do not match")


def setup_groth16_circuit(
    circom_path: Path,
    *,
    output_dir: Path | None = None,
    ptau_path: Path | None = None,
    power: int = 12,
    name: str | None = None,
    contribution_name: str = "local dev contribution",
    entropy: str | None = None,
) -> CircuitArtifacts:
    """Compile a Circom circuit and produce Groth16 proving artifacts.

    If ``ptau_path`` is omitted, this creates a local development Powers of Tau
    file in the circuit build directory.
    """
    source_name = circom_path.stem
    circuit_name = name or source_name
    build_dir = output_dir or default_build_dir(circom_path)
    build_dir.mkdir(parents=True, exist_ok=True)

    ptau = ptau_path or create_development_ptau(
        build_dir,
        power=power,
        contribution_name=contribution_name,
        entropy=entropy,
    )

    _run_circom(
        (
            str(circom_path),
            "--r1cs",
            "--wasm",
            "--sym",
            "-o",
            str(build_dir),
            "-l",
            str(REPO_ROOT / "node_modules"),
        ),
        check=True,
    )

    r1cs_path = _copy_if_renamed(
        build_dir / f"{source_name}.r1cs",
        build_dir / f"{circuit_name}.r1cs",
        error_type=CircomError,
    )
    wasm_path = _copy_if_renamed(
        build_dir / f"{source_name}_js" / f"{source_name}.wasm",
        build_dir / f"{circuit_name}.wasm",
        error_type=CircomError,
    )

    initial_zkey_path = build_dir / f"{circuit_name}.groth16.0000.zkey"
    zkey_path = build_dir / f"{circuit_name}.groth16.zkey"
    verification_key_path = build_dir / f"{circuit_name}.groth16.vkey.json"

    _run_snarkjs(
        (
            "groth16",
            "setup",
            str(r1cs_path),
            str(ptau),
            str(initial_zkey_path),
        ),
        check=True,
    )
    _run_snarkjs(
        (
            "zkey",
            "contribute",
            str(initial_zkey_path),
            str(zkey_path),
            f"--name={contribution_name}",
            f"-e={entropy or secrets.token_hex(32)}",
        ),
        check=True,
    )

    artifacts = CircuitArtifacts(
        name=circuit_name,
        r1cs_path=r1cs_path,
        wasm_path=wasm_path,
        zkey_path=zkey_path,
        verification_key_path=verification_key_path,
    )
    export_verification_key(
        artifacts.zkey_path,
        artifacts.verification_key_path,
    )
    artifacts.write_manifest(build_dir / MANIFEST_FILENAME)
    return artifacts


def create_development_ptau(
    output_dir: Path,
    *,
    power: int = 12,
    contribution_name: str = "local dev contribution",
    entropy: str | None = None,
) -> Path:
    """Create a local development Powers of Tau file."""
    ptau_0000 = output_dir / f"pot{power}_0000.ptau"
    ptau_0001 = output_dir / f"pot{power}_0001.ptau"
    ptau_final = output_dir / f"pot{power}_final.ptau"
    contribution_entropy = entropy or secrets.token_hex(32)

    _run_snarkjs(
        ("powersoftau", "new", "bn128", str(power), str(ptau_0000)),
        check=True,
    )
    _run_snarkjs(
        (
            "powersoftau",
            "contribute",
            str(ptau_0000),
            str(ptau_0001),
            f"--name={contribution_name}",
            f"-e={contribution_entropy}",
        ),
        check=True,
    )
    _run_snarkjs(
        (
            "powersoftau",
            "prepare",
            "phase2",
            str(ptau_0001),
            str(ptau_final),
        ),
        check=True,
    )
    return ptau_final


def prove_groth16_inputs(
    circom_path: Path,
    inputs: Mapping[str, Any],
    *,
    build_dir: Path | None = None,
    output_dir: Path | None = None,
    proof_name: str = "proof",
) -> ProofArtifacts:
    """Generate a Groth16 proof from Python input values."""
    proof_dir = output_dir or default_proof_dir(circom_path)
    proof_dir.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        suffix=".json",
        delete=False,
        dir=proof_dir,
    ) as input_file:
        json.dump(dict(inputs), input_file)
        input_path = Path(input_file.name)

    try:
        return prove_groth16_artifacts(
            inputs_path=input_path,
            artifacts=load_circuit_artifacts(
                manifest_path_for(circom_path, build_dir)
            ),
            output_dir=proof_dir,
            proof_name=proof_name,
        )
    finally:
        input_path.unlink(missing_ok=True)


def verify_groth16_proof(
    circom_path: Path,
    proof: ProofArtifacts,
    *,
    build_dir: Path | None = None,
) -> bool:
    """Verify a Groth16 proof for a circuit source file."""
    return verify_groth16_artifacts(
        artifacts=load_circuit_artifacts(
            manifest_path_for(circom_path, build_dir)
        ),
        proof=proof,
    )


def prove_groth16_payload(
    circom_path: Path,
    inputs: Mapping[str, Any],
    *,
    metadata: Mapping[str, Any] | None = None,
    build_dir: Path | None = None,
    output_dir: Path | None = None,
    proof_name: str = "proof",
) -> ProofPayload:
    """Generate a serializable Groth16 proof payload."""
    print("proof inputs:",inputs)
    proof = prove_groth16_inputs(
        circom_path,
        inputs,
        build_dir=build_dir,
        output_dir=output_dir,
        proof_name=proof_name,
    )
    return ProofPayload.from_artifacts(proof, metadata=metadata)


def verify_groth16_payload(
    circom_path: Path,
    payload: ProofPayload,
    *,
    build_dir: Path | None = None,
) -> bool:
    """Verify a serializable Groth16 proof payload."""
    with tempfile.TemporaryDirectory() as temp_dir:
        proof_path = Path(temp_dir) / "proof.json"
        public_path = Path(temp_dir) / "public.json"
        proof_path.write_text(json.dumps(payload.proof), encoding="utf-8")
        public_path.write_text(json.dumps(payload.public), encoding="utf-8")
        return verify_groth16_proof(
            circom_path,
            ProofArtifacts(proof_path=proof_path, public_path=public_path),
            build_dir=build_dir,
        )


def load_circuit_artifacts(manifest_path: Path) -> CircuitArtifacts:
    """Load a circuit artifact manifest."""
    return CircuitArtifacts.load(manifest_path)


def prove_groth16_artifacts(
    inputs_path: Path,
    artifacts: CircuitArtifacts,
    output_dir: Path,
    *,
    proof_name: str = "proof",
) -> ProofArtifacts:
    """Generate a Groth16 proof using compiled circuit artifacts."""
    output_dir.mkdir(parents=True, exist_ok=True)
    proof = ProofArtifacts(
        proof_path=output_dir / f"{proof_name}.json",
        public_path=output_dir / f"{proof_name}.public.json",
    )
    _run_snarkjs(
        (
            "groth16",
            "fullprove",
            str(inputs_path),
            str(artifacts.wasm_path),
            str(artifacts.zkey_path),
            str(proof.proof_path),
            str(proof.public_path),
        ),
        check=True,
    )
    return proof


def verify_groth16_artifacts(
    artifacts: CircuitArtifacts,
    proof: ProofArtifacts,
) -> bool:
    """Verify a Groth16 proof using compiled circuit artifacts."""
    result = _run_snarkjs(
        (
            "groth16",
            "verify",
            str(artifacts.verification_key_path),
            str(proof.public_path),
            str(proof.proof_path),
        ),
        check=False,
    )

    output = f"{result.stdout}\n{result.stderr}"
    if "OK" in output:
        return True
    if "Invalid proof" in output:
        return False
    if result.returncode != 0:
        raise SnarkJSError(
            _format_failure((*SNARKJS_COMMAND, "groth16", "verify"), result)
        )
    return False


def export_verification_key(
    zkey_path: Path,
    verification_key_path: Path,
) -> CommandOutput:
    """Export the verifier's JSON key from a Groth16 zkey."""
    return _run_snarkjs(
        (
            "zkey",
            "export",
            "verificationkey",
            str(zkey_path),
            str(verification_key_path),
        ),
        check=True,
    )


def default_build_dir(circom_path: Path) -> Path:
    return CIRCUIT_BUILD_DIR / circom_path.stem


def default_manifest_path(circom_path: Path) -> Path:
    return default_build_dir(circom_path) / MANIFEST_FILENAME


def manifest_path_for(
    circom_path: Path, build_dir: Path | None = None
) -> Path:
    return (build_dir or default_build_dir(circom_path)) / MANIFEST_FILENAME


def default_proof_dir(circom_path: Path) -> Path:
    return default_build_dir(circom_path) / "proofs"


def _copy_if_renamed(
    source_path: Path,
    target_path: Path,
    *,
    error_type: type[ZKCircuitRunnerError],
) -> Path:
    if source_path == target_path:
        return target_path
    try:
        shutil.copy2(source_path, target_path)
    except OSError as error:
        raise error_type(
            f"could not copy generated file from {source_path} to {target_path}: {error}"
        ) from error
    return target_path


def _run_circom(
    args: tuple[str, ...],
    *,
    check: bool,
) -> CommandOutput:
    return _run_command(
        (*CIRCOM_COMMAND, *args),
        check=check,
        error_type=CircomError,
    )


def _run_snarkjs(
    args: tuple[str, ...],
    *,
    check: bool,
) -> CommandOutput:
    return _run_command(
        (*SNARKJS_COMMAND, *args),
        check=check,
        error_type=SnarkJSError,
    )


def _run_command(
    command: tuple[str, ...],
    *,
    check: bool,
    error_type: type[ZKCircuitRunnerError],
) -> CommandOutput:
    completed = subprocess.run(
        command,
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    result = CommandOutput(
        stdout=completed.stdout,
        stderr=completed.stderr,
        returncode=completed.returncode,
    )

    if check and completed.returncode != 0:
        raise error_type(_format_failure(command, result))

    return result


def _format_failure(command: tuple[str, ...], result: CommandOutput) -> str:
    details = "\n".join(
        part
        for part in (
            f"{command[0]} exited with {result.returncode}",
            result.stdout.strip(),
            result.stderr.strip(),
        )
        if part
    )
    return details


def _manifest_path(base_dir: Path, raw_path: Any) -> Path:
    path = Path(str(raw_path))
    if path.is_absolute():
        return path
    return base_dir / path


def _json_path(path: Path, base_dir: Path) -> str:
    resolved_path = (
        path if path.is_absolute() else (REPO_ROOT / path).resolve()
    )
    resolved_base_dir = (
        base_dir
        if base_dir.is_absolute()
        else (REPO_ROOT / base_dir).resolve()
    )
    try:
        return str(resolved_path.relative_to(resolved_base_dir))
    except ValueError:
        return str(resolved_path)


def _read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Build, prove, and verify Groth16 Circom circuits.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    setup_parser = subparsers.add_parser(
        "setup",
        help="Compile a Circom circuit and generate Groth16 artifacts.",
    )
    setup_parser.add_argument("circom_path", type=Path)
    setup_parser.add_argument("--out-dir", type=Path)
    setup_parser.add_argument("--ptau", type=Path)
    setup_parser.add_argument("--power", type=int, default=12)
    setup_parser.add_argument("--name")
    setup_parser.add_argument(
        "--contribution-name", default="local dev contribution"
    )
    setup_parser.add_argument("--entropy")

    prove_parser = subparsers.add_parser(
        "prove",
        help="Generate a Groth16 proof from JSON input values.",
    )
    prove_parser.add_argument("circom_path", type=Path)
    prove_parser.add_argument("--input", required=True)
    prove_parser.add_argument("--build-dir", type=Path)
    prove_parser.add_argument("--out-dir", type=Path)
    prove_parser.add_argument("--proof-name", default="proof")

    verify_parser = subparsers.add_parser(
        "verify",
        help="Verify a Groth16 proof.",
    )
    verify_parser.add_argument("circom_path", type=Path)
    verify_parser.add_argument("--proof", type=Path)
    verify_parser.add_argument("--public", type=Path)
    verify_parser.add_argument("--build-dir", type=Path)
    verify_parser.add_argument("--proof-name", default="proof")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.command == "setup":
            artifacts = setup_groth16_circuit(
                circom_path=args.circom_path,
                output_dir=args.out_dir,
                ptau_path=args.ptau,
                power=args.power,
                name=args.name,
                contribution_name=args.contribution_name,
                entropy=args.entropy,
            )
            manifest_path = (
                args.out_dir or default_build_dir(args.circom_path)
            ) / (MANIFEST_FILENAME)
            print(f"Wrote manifest to {manifest_path}")
            print(f"Wrote wasm to {artifacts.wasm_path}")
            print(f"Wrote zkey to {artifacts.zkey_path}")
            print(
                f"Wrote verification key to {artifacts.verification_key_path}"
            )
            return 0

        if args.command == "prove":
            proof = prove_groth16_inputs(
                circom_path=args.circom_path,
                inputs=_parse_json_object(args.input),
                build_dir=args.build_dir,
                output_dir=args.out_dir,
                proof_name=args.proof_name,
            )
            print(f"Wrote proof to {proof.proof_path}")
            print(f"Wrote public inputs to {proof.public_path}")
            return 0

        if args.command == "verify":
            proof = _proof_from_args(args)
            is_valid = verify_groth16_proof(
                args.circom_path,
                proof,
                build_dir=args.build_dir,
            )
            print("Proof is valid" if is_valid else "Proof is invalid")
            return 0 if is_valid else 1

    except ZKCircuitRunnerError as error:
        print(str(error), file=sys.stderr)
        return 2

    parser.error(f"unknown command: {args.command}")
    return 2


def _parse_json_object(raw_json: str) -> Mapping[str, Any]:
    try:
        data = json.loads(raw_json)
    except json.JSONDecodeError as error:
        raise ZKCircuitRunnerError(
            f"--input must be valid JSON: {error}"
        ) from error
    if not isinstance(data, dict):
        raise ZKCircuitRunnerError("--input must be a JSON object")
    return data


def _proof_from_args(args: argparse.Namespace) -> ProofArtifacts:
    proof_dir = args.out_dir if hasattr(args, "out_dir") else None
    default_dir = proof_dir or default_proof_dir(args.circom_path)
    proof_path = args.proof or default_dir / f"{args.proof_name}.json"
    public_path = args.public or default_dir / f"{args.proof_name}.public.json"
    return ProofArtifacts(proof_path=proof_path, public_path=public_path)


if __name__ == "__main__":
    raise SystemExit(main())
