pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";

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

    for (var i = 0; i < L - 1; i++) {
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

template BoardSetup(N) {
    signal input privShipX[N];
    signal input privShipY[N];
    signal input privSalt;

    signal output pubCommitment;

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
    }

    component eqX[N][N];
    component eqY[N][N];

    for (var i = 0; i < N; i++) {
        for (var j = i + 1; j < N; j++) {
            eqX[i][j] = IsEqual();
            eqX[i][j].in[0] <== privShipX[i];
            eqX[i][j].in[1] <== privShipX[j];

            eqY[i][j] = IsEqual();
            eqY[i][j].in[0] <== privShipY[i];
            eqY[i][j].in[1] <== privShipY[j];

            eqX[i][j].out * eqY[i][j].out === 0;
        }
    }

    component ship = ValidShip(N);

    for (var i = 0; i < N; i++) {
        ship.X[i] <== privShipX[i];
        ship.Y[i] <== privShipY[i];
    }

    component hasher = Poseidon(2 * N + 1);
    
    for (var i = 0; i < N; i++) {
        hasher.inputs[i] <== privShipX[i];
        hasher.inputs[i + N] <== privShipY[i];
    }

    hasher.inputs[2 * N] <== privSalt;
    pubCommitment <== hasher.out;
}

component main = BoardSetup(6);
