# Applied Cryptography Project

The ZK helper is Python-centric: keep Circom source files in `circuits/`, then
let `source.zk_circuit_runner` compile, set up, prove, and verify. You should
not need to hand-write input JSON files or manually pass around `.wasm`,
`.zkey`, or verification key paths.

Install dependencies once:

```bash
pip install -r requirements/dev.txt
npm install
```

## Command Line End-to-End

Compile and set up a circuit:

```bash
python3 -m source.zk_circuit_runner setup circuits/polynomial.circom
```

This writes generated files under `circuits/build/polynomial/`, including:

```text
artifacts.json
polynomial.wasm
polynomial.groth16.zkey
polynomial.groth16.vkey.json
```

Generate a proof by passing input values directly as JSON:

```bash
python3 -m source.zk_circuit_runner prove \
  circuits/polynomial.circom \
  --input '{"x": 9, "y": 113}'
```

Verify the proof:

```bash
python3 -m source.zk_circuit_runner verify circuits/polynomial.circom
```

By default, proofs are written to `circuits/build/polynomial/proofs/`.

For local development, `setup` creates a local Powers of Tau file and makes one
local contribution automatically. That keeps the project easy to run, but it is
not a production ceremony.

## Python End-to-End

```python
from pathlib import Path

from source.zk_circuit_runner import (
    prove_groth16_inputs,
    setup_groth16_circuit,
    verify_groth16_proof,
)


circom_path = Path("circuits/polynomial.circom")

setup_groth16_circuit(circom_path)

proof = prove_groth16_inputs(
    circom_path,
    {"x": 9, "y": 113},
)

is_valid = verify_groth16_proof(circom_path, proof)
print(is_valid)
```

## Battleship ZK Flow

The game currently uses `circuits/battleship_hit.circom` to prove each
hit/miss response. The circuit proves that a defender knows a private committed
ship coordinate and salt, and that the reported result for the attacker's guess
is correct.

The current circuit proves one committed ship cell, so the demo game uses one
ship of length 1. Generated Battleship artifacts are written under:

```text
circuits/build/battleship_hit/
```

During game startup, both players exchange Poseidon commitments. During each
defense turn, the defender sends a JSON response containing:

```text
result
proof
public inputs
```

The attacker verifies that proof before accepting the hit/miss result. The
socket layer uses newline-delimited messages so proof JSON can be larger than a
single TCP receive buffer.
