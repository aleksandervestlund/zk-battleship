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
        isYEq[i] = IsEqual();
        isYEq[i].in[0] <== Y[i];
        isYEq[i].in[1] <== Y[i+1];

        isXInc[i] = IsEqual();
        isXInc[i].in[0] <== X[i] + 1;
        isXInc[i].in[1] <== X[i+1];

        horizStep[i] <== isYEq[i].out * isXInc[i].out;
        isHorizontal[i+1] <== isHorizontal[i] * horizStep[i];

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
    var N = 17;

    signal input privShipX[N];
    signal input privShipY[N];
    signal input privSalt;
    signal output pubCommitment;

    signal leaves[32];

    component lessX[N];
    component lessY[N];

    for (var i = 0; i < N; i++) {
        lessX[i] = LessThan(4);
        lessX[i].in[0] <== privShipX[i];
        lessX[i].in[1] <== 10;
        lessX[i].out === 1;

        lessY[i] = LessThan(4);
        lessY[i].in[0] <== privShipY[i];
        lessY[i].in[1] <== 10;
        lessY[i].out === 1;

        leaves[i] <== privShipX[i] * 10 + privShipY[i] + 1;
    }

    leaves[N] <== privSalt;

    for (var i = N + 1; i < 32; i++) {
        leaves[i] <== 0;
    }

    var num_pairs = N * (N - 1) / 2;
    component eq[num_pairs];

    for (var k = 0; k < num_pairs; k++) {
        eq[k] = IsEqual();
    }

    var pairIdx = 0;

    for (var i = 0; i < N; i++) {
        for (var j = i+1; j < N; j++) {
            eq[pairIdx].in[0] <== privShipX[i] * 10 + privShipY[i];
            eq[pairIdx].in[1] <== privShipX[j] * 10 + privShipY[j];
            eq[pairIdx].out === 0;
            pairIdx++;
        }
    }

    component ship0 = ValidShip(5);
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

    component ship1 = ValidShip(4);
    ship1.X[0] <== privShipX[5];
    ship1.Y[0] <== privShipY[5];
    ship1.X[1] <== privShipX[6];
    ship1.Y[1] <== privShipY[6];
    ship1.X[2] <== privShipX[7];
    ship1.Y[2] <== privShipY[7];
    ship1.X[3] <== privShipX[8];
    ship1.Y[3] <== privShipY[8];

    component ship2 = ValidShip(3);
    ship2.X[0] <== privShipX[9];
    ship2.Y[0] <== privShipY[9];
    ship2.X[1] <== privShipX[10];
    ship2.Y[1] <== privShipY[10];
    ship2.X[2] <== privShipX[11];
    ship2.Y[2] <== privShipY[11];

    component ship3 = ValidShip(3);
    ship3.X[0] <== privShipX[12];
    ship3.Y[0] <== privShipY[12];
    ship3.X[1] <== privShipX[13];
    ship3.Y[1] <== privShipY[13];
    ship3.X[2] <== privShipX[14];
    ship3.Y[2] <== privShipY[14];

    component ship4 = ValidShip(2);
    ship4.X[0] <== privShipX[15];
    ship4.Y[0] <== privShipY[15];
    ship4.X[1] <== privShipX[16];
    ship4.Y[1] <== privShipY[16];

    signal nodes[6][32];

    for (var i = 0; i < 32; i++) {
        nodes[0][i] <== leaves[i];
    }

    component hasher[31];
    var hasher_idx = 0;

    for (var level = 0; level < 5; level++) {
        var num_pairs_at_level = 32 / (2 << level);
        for (var i = 0; i < num_pairs_at_level; i++) {
            var left_idx = 2 * i;
            var right_idx = 2 * i + 1;
            hasher[hasher_idx] = Poseidon(2);
            hasher[hasher_idx].inputs[0] <== nodes[level][left_idx];
            hasher[hasher_idx].inputs[1] <== nodes[level][right_idx];
            nodes[level+1][i] <== hasher[hasher_idx].out;
            hasher_idx++;
        }
    }

    pubCommitment <== nodes[5][0];
}

component main = BoardSetup();
