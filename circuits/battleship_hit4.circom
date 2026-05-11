pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";

template BattleshipHit(N) {
    signal input pubGuessX;
    signal input pubGuessY;
    signal input pubCommitment;
    signal input pubReportedHit; // 1 (Hit) or 0 (Miss)

    signal input privShipX[N];
    signal input privShipY[N];
    signal input privSalt;

    component hasher = Poseidon(2 * N + 1);

    for (var i = 0; i < N; i++) {
        hasher.inputs[i] <== privShipX[i];
        hasher.inputs[i + N] <== privShipY[i];
    }

    hasher.inputs[2 * N] <== privSalt;
    pubCommitment === hasher.out;
    
    component eqX[N];
    component eqY[N];
    signal hitMatch[N];
    
    signal hitAccumulator[N + 1];
    hitAccumulator[0] <== 0;

    for (var i = 0; i < N; i++) {
        eqX[i] = IsEqual();
        eqX[i].in[0] <== pubGuessX;
        eqX[i].in[1] <== privShipX[i];

        eqY[i] = IsEqual();
        eqY[i].in[0] <== pubGuessY;
        eqY[i].in[1] <== privShipY[i];

        hitMatch[i] <== eqX[i].out * eqY[i].out;
        hitAccumulator[i + 1] <== hitAccumulator[i] + hitMatch[i];
    }

    pubReportedHit === hitAccumulator[N];
}

component main {public [pubGuessX, pubGuessY, pubCommitment, pubReportedHit]} = BattleshipHit(4);
