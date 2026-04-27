pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

template BattleshipHit() {
    signal input pubGuessX;
    signal input pubGuessY;
    signal input pubCommitment;
    signal input pubReportedHit;

    signal input privShipX;
    signal input privShipY;
    signal input privSalt;

    component hasher = Poseidon(3);
    hasher.inputs[0] <== privShipX;
    hasher.inputs[1] <== privShipY;
    hasher.inputs[2] <== privSalt;
    pubCommitment === hasher.out;

    component eqX = IsEqual();
    eqX.in[0] <== pubGuessX;
    eqX.in[1] <== privShipX;

    component eqY = IsEqual();
    eqY.in[0] <== pubGuessY;
    eqY.in[1] <== privShipY;

    signal actualOutcome <== eqX.out * eqY.out;
    pubReportedHit === actualOutcome;
}

component main { public [pubGuessX, pubGuessY, pubCommitment, pubReportedHit] } = BattleshipHit();
