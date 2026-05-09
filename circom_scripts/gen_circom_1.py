#!/usr/bin/env python3

import argparse

VALID_SHIP_TEMPLATE = r"""
template ValidShip(L) {
    signal input X[L];
    signal input Y[L];

    component isYEq[L-1];
    component isXInc[L-1];
    signal isHorizontal[L];
    signal horizStep[L-1];
    isHorizontal[0] <== 1;

    component isXEq[L-1];
    component isYInc[L-1];
    signal isVertical[L];
    signal vertStep[L-1];
    isVertical[0] <== 1;

    for (var i = 0; i < L-1; i++) {
        // Horizontal checks
        isYEq[i] = IsEqual();
        isYEq[i].in[0] <== Y[i];
        isYEq[i].in[1] <== Y[i+1];

        isXInc[i] = IsEqual();
        isXInc[i].in[0] <== X[i] + 1;
        isXInc[i].in[1] <== X[i+1];

        horizStep[i] <== isYEq[i].out * isXInc[i].out;
        isHorizontal[i+1] <== isHorizontal[i] * horizStep[i];

        // Vertical checks
        isXEq[i] = IsEqual();
        isXEq[i].in[0] <== X[i];
        isXEq[i].in[1] <== X[i+1];

        isYInc[i] = IsEqual();
        isYInc[i].in[0] <== Y[i] + 1;
        isYInc[i].in[1] <== Y[i+1];

        vertStep[i] <== isXEq[i].out * isYInc[i].out;
        isVertical[i+1] <== isVertical[i] * vertStep[i];
    }

    isHorizontal[L-1] + isVertical[L-1] === 1;
}
"""

def generate_circuit(ship_lengths):
    num_ships = len(ship_lengths)
    total_coords = sum(ship_lengths)

    # Merkle tree parameters
    tree_leaves = total_coords + 1
    tree_size = 1
    tree_height = 0
    while tree_size < tree_leaves:
        tree_size *= 2
        tree_height += 1
    num_hashers = tree_size - 1

    # Overlap pairs
    num_pairs = total_coords * (total_coords - 1) // 2

    lines = []
    lines.append("pragma circom 2.1.6;\n")
    lines.append('include "circomlib/circuits/poseidon.circom";')
    lines.append('include "circomlib/circuits/comparators.circom";\n')
    lines.append(VALID_SHIP_TEMPLATE.strip())
    lines.append("\ntemplate BoardSetup() {")

    # Inputs & outputs
    lines.append(f"    signal input privShipX[{total_coords}];")
    lines.append(f"    signal input privShipY[{total_coords}];")
    lines.append("    signal input privSalt;")
    lines.append("    signal output pubCommitment;\n")

    # Leaves array
    lines.append(f"    signal leaves[{tree_size}];\n")

    # Bounds checks and leaf packing
    lines.append("    component lessX[{total_coords}];")
    lines.append("    component lessY[{total_coords}];\n")

    for i in range(total_coords):
        lines.append(f"    lessX[{i}] = LessThan(4);")
        lines.append(f"    lessX[{i}].in[0] <== privShipX[{i}];")
        lines.append(f"    lessX[{i}].in[1] <== 10;")
        lines.append(f"    lessX[{i}].out === 1;\n")
        lines.append(f"    lessY[{i}] = LessThan(4);")
        lines.append(f"    lessY[{i}].in[0] <== privShipY[{i}];")
        lines.append(f"    lessY[{i}].in[1] <== 10;")
        lines.append(f"    lessY[{i}].out === 1;\n")
        lines.append(f"    leaves[{i}] <== privShipX[{i}] * 10 + privShipY[{i}] + 1;\n")

    # Salt leaf
    lines.append(f"    leaves[{total_coords}] <== privSalt;\n")

    # Padding leaves
    for i in range(total_coords + 1, tree_size):
        lines.append(f"    leaves[{i}] <== 0;\n")

    # Overlap check (pairwise)
    lines.append(f"    component eq[{num_pairs}];")
    for idx in range(num_pairs):
        lines.append(f"    eq[{idx}] = IsEqual();")
    lines.append("")
    lines.append("    var pairIdx = 0;")
    lines.append("    for (var i = 0; i < {total_coords}; i++) {")
    lines.append("        for (var j = i+1; j < {total_coords}; j++) {")
    lines.append("            eq[pairIdx].in[0] <== privShipX[i] * 10 + privShipY[i];")
    lines.append("            eq[pairIdx].in[1] <== privShipX[j] * 10 + privShipY[j];")
    lines.append("            eq[pairIdx].out === 0;")
    lines.append("            pairIdx++;")
    lines.append("        }")
    lines.append("    }\n")

    # Ship contiguity checks
    coord_offset = 0
    for s, length in enumerate(ship_lengths):
        lines.append(f"    component ship{s} = ValidShip({length});")
        for k in range(length):
            idx = coord_offset + k
            lines.append(f"    ship{s}.X[{k}] <== privShipX[{idx}];")
            lines.append(f"    ship{s}.Y[{k}] <== privShipY[{idx}];")
        lines.append("")
        coord_offset += length

    # Merkle tree - fixed indexing
    lines.append(f"    signal nodes[{tree_height+1}][{tree_size}];")
    for i in range(tree_size):
        lines.append(f"    nodes[0][{i}] <== leaves[{i}];")
    lines.append("")
    lines.append(f"    component hasher[{num_hashers}];")

    hasher_idx = 0
    for level in range(tree_height):
        num_pairs_at_level = tree_size // (2 << level)   # number of node pairs at this level
        for i in range(num_pairs_at_level):
            left_idx = 2 * i
            right_idx = 2 * i + 1
            lines.append(f"    hasher[{hasher_idx}] = Poseidon(2);")
            lines.append(f"    hasher[{hasher_idx}].inputs[0] <== nodes[{level}][{left_idx}];")
            lines.append(f"    hasher[{hasher_idx}].inputs[1] <== nodes[{level}][{right_idx}];")
            lines.append(f"    nodes[{level+1}][{i}] <== hasher[{hasher_idx}].out;")
            lines.append("")
            hasher_idx += 1

    lines.append(f"    pubCommitment <== nodes[{tree_height}][0];")
    lines.append("}\n")
    lines.append("component main = BoardSetup();")

    # Replace placeholders
    code = "\n".join(lines)
    code = code.replace("{total_coords}", str(total_coords))
    code = code.replace("{tree_size}", str(tree_size))
    return code

def run(ship_lengths, idx):
    circom_code = generate_circuit(ship_lengths)
    with open(f"autogen_circuit{idx}.circom", "w") as f:
        f.write(circom_code)
    print(f"Generated autogen_circuit{idx}.circom")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ship-lengths", nargs="+", type=int, required=True,
                        help="Ship lengths, e.g. --ship-lengths 2 2 3")
    parser.add_argument("--output", type=str, default="compact_board.circom")
    args = parser.parse_args()

    circom_code = generate_circuit(args.ship_lengths)
    with open(args.output, "w") as f:
        f.write(circom_code)
    print(f"Generated {args.output}")

if __name__ == "__main__":
    main()
