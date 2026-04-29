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

## Circuit Validation Rules

The `circuits/validity.circom` circuit proves a battleship board layout is valid without revealing ship positions. It enforces ALL game rules in zero-knowledge.

### Rules Enforced by Circuit (Cryptographic Proof)

#### 1. **Coordinate Bounds Validation**

- All start positions (X, Y): `1 ≤ startX ≤ 10` and `1 ≤ startY ≤ 10`
- All end positions (X, Y): `1 ≤ endX ≤ 10` and `1 ≤ endY ≤ 10`
- Uses `GreaterThan(5)` and `LessThan(5)` comparators for all 5 ships
- **Uses 1-indexing** (board coordinates are 1-10, not 0-9)

#### 2. **Direction Validation**

- Each ship's direction must be 0 (horizontal) or 1 (vertical)
- Enforced: `direction * (direction - 1) === 0` (only 0 and 1 satisfy this)

#### 3. **Contiguity by Construction**

- Ships are modeled as contiguous cells computed from start position + direction + length
- Cell formula:
  - If horizontal (dir=0): cells at (startX + j, startY) for j ∈ [0, length)
  - If vertical (dir=1): cells at (startX, startY + j) for j ∈ [0, length)

#### 4. **Non-Overlapping Ships**

- All 17 ship cells verified to have unique (X, Y) coordinates
- Pairwise comparison: for all cell pairs (a, b) where a < b:
  - `(cellsX[a] === cellsX[b]) AND (cellsY[a] === cellsY[b]) === 0`
- Ensures no two cells occupy the same board position

#### 5. **Board Commitment Verification**

- Circuit verifies the public commitment hash matches the private inputs
- Uses Poseidon hash
- Prevents prover from changing the board after commitment

### Rules Applied by Python Wrapper

Before proof generation, the Python code (`source/battleship_zk.py`) performs identical checks:

- Validates bounds for all ships
- Validates no overlaps
- Validates directions are 0 or 1

**These checks protect the client. The circuit proves the checks were done correctly.**
