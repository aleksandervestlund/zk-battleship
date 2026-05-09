pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

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

template BoardSetup() {
    signal input privShipX[6];
    signal input privShipY[6];
    signal input privSalt;
    signal output pubCommitment;

    signal leaves[8];

    component lessX[6];
    component lessY[6];

    lessX[0] = LessThan(4);
    lessX[0].in[0] <== privShipX[0];
    lessX[0].in[1] <== 10;
    lessX[0].out === 1;

    lessY[0] = LessThan(4);
    lessY[0].in[0] <== privShipY[0];
    lessY[0].in[1] <== 10;
    lessY[0].out === 1;

    leaves[0] <== privShipX[0] * 10 + privShipY[0] + 1;

    lessX[1] = LessThan(4);
    lessX[1].in[0] <== privShipX[1];
    lessX[1].in[1] <== 10;
    lessX[1].out === 1;

    lessY[1] = LessThan(4);
    lessY[1].in[0] <== privShipY[1];
    lessY[1].in[1] <== 10;
    lessY[1].out === 1;

    leaves[1] <== privShipX[1] * 10 + privShipY[1] + 1;

    lessX[2] = LessThan(4);
    lessX[2].in[0] <== privShipX[2];
    lessX[2].in[1] <== 10;
    lessX[2].out === 1;

    lessY[2] = LessThan(4);
    lessY[2].in[0] <== privShipY[2];
    lessY[2].in[1] <== 10;
    lessY[2].out === 1;

    leaves[2] <== privShipX[2] * 10 + privShipY[2] + 1;

    lessX[3] = LessThan(4);
    lessX[3].in[0] <== privShipX[3];
    lessX[3].in[1] <== 10;
    lessX[3].out === 1;

    lessY[3] = LessThan(4);
    lessY[3].in[0] <== privShipY[3];
    lessY[3].in[1] <== 10;
    lessY[3].out === 1;

    leaves[3] <== privShipX[3] * 10 + privShipY[3] + 1;

    lessX[4] = LessThan(4);
    lessX[4].in[0] <== privShipX[4];
    lessX[4].in[1] <== 10;
    lessX[4].out === 1;

    lessY[4] = LessThan(4);
    lessY[4].in[0] <== privShipY[4];
    lessY[4].in[1] <== 10;
    lessY[4].out === 1;

    leaves[4] <== privShipX[4] * 10 + privShipY[4] + 1;

    lessX[5] = LessThan(4);
    lessX[5].in[0] <== privShipX[5];
    lessX[5].in[1] <== 10;
    lessX[5].out === 1;

    lessY[5] = LessThan(4);
    lessY[5].in[0] <== privShipY[5];
    lessY[5].in[1] <== 10;
    lessY[5].out === 1;

    leaves[5] <== privShipX[5] * 10 + privShipY[5] + 1;

    leaves[6] <== privSalt;

    leaves[7] <== 0;

    component eq[15];
    eq[0] = IsEqual();
    eq[1] = IsEqual();
    eq[2] = IsEqual();
    eq[3] = IsEqual();
    eq[4] = IsEqual();
    eq[5] = IsEqual();
    eq[6] = IsEqual();
    eq[7] = IsEqual();
    eq[8] = IsEqual();
    eq[9] = IsEqual();
    eq[10] = IsEqual();
    eq[11] = IsEqual();
    eq[12] = IsEqual();
    eq[13] = IsEqual();
    eq[14] = IsEqual();

    var pairIdx = 0;
    for (var i = 0; i < 6; i++) {
        for (var j = i+1; j < 6; j++) {
            eq[pairIdx].in[0] <== privShipX[i] * 10 + privShipY[i];
            eq[pairIdx].in[1] <== privShipX[j] * 10 + privShipY[j];
            eq[pairIdx].out === 0;
            pairIdx++;
        }
    }

    component ship0 = ValidShip(6);
    ship0.X[0] <== privShipX[0];
    ship0.Y[0] <== privShipY[0];
    ship0.X[1] <== privShipX[1];
    ship0.Y[1] <== privShipY[1];
    ship0.X[2] <== privShipX[2];
    ship0.Y[2] <== privShipY[2];
    ship0.X[3] <== privShipX[3];
    ship0.Y[3] <== privShipY[3];
    ship0.X[4] <== privShipX[4];
    ship0.Y[4] <== privShipY[4];
    ship0.X[5] <== privShipX[5];
    ship0.Y[5] <== privShipY[5];

    signal nodes[4][8];
    nodes[0][0] <== leaves[0];
    nodes[0][1] <== leaves[1];
    nodes[0][2] <== leaves[2];
    nodes[0][3] <== leaves[3];
    nodes[0][4] <== leaves[4];
    nodes[0][5] <== leaves[5];
    nodes[0][6] <== leaves[6];
    nodes[0][7] <== leaves[7];

    component hasher[7];
    hasher[0] = Poseidon(2);
    hasher[0].inputs[0] <== nodes[0][0];
    hasher[0].inputs[1] <== nodes[0][1];
    nodes[1][0] <== hasher[0].out;

    hasher[1] = Poseidon(2);
    hasher[1].inputs[0] <== nodes[0][2];
    hasher[1].inputs[1] <== nodes[0][3];
    nodes[1][1] <== hasher[1].out;

    hasher[2] = Poseidon(2);
    hasher[2].inputs[0] <== nodes[0][4];
    hasher[2].inputs[1] <== nodes[0][5];
    nodes[1][2] <== hasher[2].out;

    hasher[3] = Poseidon(2);
    hasher[3].inputs[0] <== nodes[0][6];
    hasher[3].inputs[1] <== nodes[0][7];
    nodes[1][3] <== hasher[3].out;

    hasher[4] = Poseidon(2);
    hasher[4].inputs[0] <== nodes[1][0];
    hasher[4].inputs[1] <== nodes[1][1];
    nodes[2][0] <== hasher[4].out;

    hasher[5] = Poseidon(2);
    hasher[5].inputs[0] <== nodes[1][2];
    hasher[5].inputs[1] <== nodes[1][3];
    nodes[2][1] <== hasher[5].out;

    hasher[6] = Poseidon(2);
    hasher[6].inputs[0] <== nodes[2][0];
    hasher[6].inputs[1] <== nodes[2][1];
    nodes[3][0] <== hasher[6].out;

    pubCommitment <== nodes[3][0];
}

component main = BoardSetup();