pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

template BoardCommitment() {
    signal input pubBoardCommitment;
    signal input privStartX[5];
    signal input privStartY[5];
    signal input privDirections[5]; // 0 = H, 1 = V
    signal input privSalt;

    var lengths[5] = [5, 4, 3, 3, 2];

    signal cellsX[17];
    signal cellsY[17];

    var idx = 0;

    component gtStartX[5];
    component ltStartX[5];
    component gtStartY[5];
    component ltStartY[5];
    component gtEndX[5];
    component ltEndX[5];
    component gtEndY[5];
    component ltEndY[5];
    component directionCheck[5];

    signal endX[5];
    signal endY[5];

    for (var i = 0; i < 5; i++) {
        directionCheck[i] = IsEqual();
        directionCheck[i].in[0] <== privDirections[i] * (privDirections[i] - 1);
        directionCheck[i].in[1] <== 0;
        directionCheck[i].out === 1;

        endX[i] <== privStartX[i] + (1 - privDirections[i]) * (lengths[i] - 1);
        endY[i] <== privStartY[i] + privDirections[i] * (lengths[i] - 1);

        gtStartX[i] = GreaterThan(5);
        gtStartX[i].in[0] <== privStartX[i];
        gtStartX[i].in[1] <== 0;
        gtStartX[i].out === 1;

        ltStartX[i] = LessThan(5);
        ltStartX[i].in[0] <== privStartX[i];
        ltStartX[i].in[1] <== 11;
        ltStartX[i].out === 1;

        gtStartY[i] = GreaterThan(5);
        gtStartY[i].in[0] <== privStartY[i];
        gtStartY[i].in[1] <== 0;
        gtStartY[i].out === 1;

        ltStartY[i] = LessThan(5);
        ltStartY[i].in[0] <== privStartY[i];
        ltStartY[i].in[1] <== 11;
        ltStartY[i].out === 1;

        gtEndX[i] = GreaterThan(5);
        gtEndX[i].in[0] <== endX[i];
        gtEndX[i].in[1] <== 0;
        gtEndX[i].out === 1;

        ltEndX[i] = LessThan(5);
        ltEndX[i].in[0] <== endX[i];
        ltEndX[i].in[1] <== 11;
        ltEndX[i].out === 1;

        gtEndY[i] = GreaterThan(5);
        gtEndY[i].in[0] <== endY[i];
        gtEndY[i].in[1] <== 0;
        gtEndY[i].out === 1;

        ltEndY[i] = LessThan(5);
        ltEndY[i].in[0] <== endY[i];
        ltEndY[i].in[1] <== 11;
        ltEndY[i].out === 1;
    }

    for (var i = 0; i < 5; i++) {
        for (var j = 0; j < lengths[i]; j++) {
            cellsX[idx] <== privStartX[i] + (1 - privDirections[i]) * j;
            cellsY[idx] <== privStartY[i] + privDirections[i] * j;
            idx++;
        }
    }

    component eqXFlat[136];
    component eqYFlat[136];
    signal sameFlat[136];
    var pairIdx = 0;

    for (var a = 0; a < 17; a++) {
        for (var b = a + 1; b < 17; b++) {
            eqXFlat[pairIdx] = IsEqual();
            eqXFlat[pairIdx].in[0] <== cellsX[a];
            eqXFlat[pairIdx].in[1] <== cellsX[b];

            eqYFlat[pairIdx] = IsEqual();
            eqYFlat[pairIdx].in[0] <== cellsY[a];
            eqYFlat[pairIdx].in[1] <== cellsY[b];

            sameFlat[pairIdx] <== eqXFlat[pairIdx].out * eqYFlat[pairIdx].out;
            sameFlat[pairIdx] === 0;

            pairIdx++;
        }
    }

    component hasher = Poseidon(16);
    var k = 0;

    for (var i = 0; i < 5; i++) {
        hasher.inputs[k] <== privStartX[i]; k++;
        hasher.inputs[k] <== privStartY[i]; k++;
        hasher.inputs[k] <== privDirections[i]; k++;
    }

    hasher.inputs[k] <== privSalt;
    pubBoardCommitment === hasher.out;
}

component main { public [pubBoardCommitment] } = BoardCommitment();
