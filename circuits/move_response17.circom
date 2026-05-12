pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/comparators.circom";

template BattleshipHit(N) {
    signal input pubGuessX;
    signal input pubGuessY;
    signal input pubCommitment;
    signal input pubReportedHit; // 1 (Hit) or 0 (Miss)

    signal input privShipX[N];
    signal input privShipY[N];
    signal input privSalt;
    
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
    
    signal leaves[32];
    component lessX[17];
    component lessY[17];

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

    lessX[6] = LessThan(4);
    lessX[6].in[0] <== privShipX[6];
    lessX[6].in[1] <== 10;
    lessX[6].out === 1;

    lessY[6] = LessThan(4);
    lessY[6].in[0] <== privShipY[6];
    lessY[6].in[1] <== 10;
    lessY[6].out === 1;

    leaves[6] <== privShipX[6] * 10 + privShipY[6] + 1;

    lessX[7] = LessThan(4);
    lessX[7].in[0] <== privShipX[7];
    lessX[7].in[1] <== 10;
    lessX[7].out === 1;

    lessY[7] = LessThan(4);
    lessY[7].in[0] <== privShipY[7];
    lessY[7].in[1] <== 10;
    lessY[7].out === 1;

    leaves[7] <== privShipX[7] * 10 + privShipY[7] + 1;

    lessX[8] = LessThan(4);
    lessX[8].in[0] <== privShipX[8];
    lessX[8].in[1] <== 10;
    lessX[8].out === 1;

    lessY[8] = LessThan(4);
    lessY[8].in[0] <== privShipY[8];
    lessY[8].in[1] <== 10;
    lessY[8].out === 1;

    leaves[8] <== privShipX[8] * 10 + privShipY[8] + 1;

    lessX[9] = LessThan(4);
    lessX[9].in[0] <== privShipX[9];
    lessX[9].in[1] <== 10;
    lessX[9].out === 1;

    lessY[9] = LessThan(4);
    lessY[9].in[0] <== privShipY[9];
    lessY[9].in[1] <== 10;
    lessY[9].out === 1;

    leaves[9] <== privShipX[9] * 10 + privShipY[9] + 1;

    lessX[10] = LessThan(4);
    lessX[10].in[0] <== privShipX[10];
    lessX[10].in[1] <== 10;
    lessX[10].out === 1;

    lessY[10] = LessThan(4);
    lessY[10].in[0] <== privShipY[10];
    lessY[10].in[1] <== 10;
    lessY[10].out === 1;

    leaves[10] <== privShipX[10] * 10 + privShipY[10] + 1;

    lessX[11] = LessThan(4);
    lessX[11].in[0] <== privShipX[11];
    lessX[11].in[1] <== 10;
    lessX[11].out === 1;

    lessY[11] = LessThan(4);
    lessY[11].in[0] <== privShipY[11];
    lessY[11].in[1] <== 10;
    lessY[11].out === 1;

    leaves[11] <== privShipX[11] * 10 + privShipY[11] + 1;

    lessX[12] = LessThan(4);
    lessX[12].in[0] <== privShipX[12];
    lessX[12].in[1] <== 10;
    lessX[12].out === 1;

    lessY[12] = LessThan(4);
    lessY[12].in[0] <== privShipY[12];
    lessY[12].in[1] <== 10;
    lessY[12].out === 1;

    leaves[12] <== privShipX[12] * 10 + privShipY[12] + 1;

    lessX[13] = LessThan(4);
    lessX[13].in[0] <== privShipX[13];
    lessX[13].in[1] <== 10;
    lessX[13].out === 1;

    lessY[13] = LessThan(4);
    lessY[13].in[0] <== privShipY[13];
    lessY[13].in[1] <== 10;
    lessY[13].out === 1;

    leaves[13] <== privShipX[13] * 10 + privShipY[13] + 1;

    lessX[14] = LessThan(4);
    lessX[14].in[0] <== privShipX[14];
    lessX[14].in[1] <== 10;
    lessX[14].out === 1;

    lessY[14] = LessThan(4);
    lessY[14].in[0] <== privShipY[14];
    lessY[14].in[1] <== 10;
    lessY[14].out === 1;

    leaves[14] <== privShipX[14] * 10 + privShipY[14] + 1;

    lessX[15] = LessThan(4);
    lessX[15].in[0] <== privShipX[15];
    lessX[15].in[1] <== 10;
    lessX[15].out === 1;

    lessY[15] = LessThan(4);
    lessY[15].in[0] <== privShipY[15];
    lessY[15].in[1] <== 10;
    lessY[15].out === 1;

    leaves[15] <== privShipX[15] * 10 + privShipY[15] + 1;

    lessX[16] = LessThan(4);
    lessX[16].in[0] <== privShipX[16];
    lessX[16].in[1] <== 10;
    lessX[16].out === 1;

    lessY[16] = LessThan(4);
    lessY[16].in[0] <== privShipY[16];
    lessY[16].in[1] <== 10;
    lessY[16].out === 1;

    leaves[16] <== privShipX[16] * 10 + privShipY[16] + 1;
    leaves[17] <== privSalt;
    leaves[18] <== 0;
    leaves[19] <== 0;
    leaves[20] <== 0;
    leaves[21] <== 0;
    leaves[22] <== 0;
    leaves[23] <== 0;
    leaves[24] <== 0;
    leaves[25] <== 0;
    leaves[26] <== 0;
    leaves[27] <== 0;
    leaves[28] <== 0;
    leaves[29] <== 0;
    leaves[30] <== 0;
    leaves[31] <== 0;

    signal nodes[6][32];
    nodes[0][0] <== leaves[0];
    nodes[0][1] <== leaves[1];
    nodes[0][2] <== leaves[2];
    nodes[0][3] <== leaves[3];
    nodes[0][4] <== leaves[4];
    nodes[0][5] <== leaves[5];
    nodes[0][6] <== leaves[6];
    nodes[0][7] <== leaves[7];
    nodes[0][8] <== leaves[8];
    nodes[0][9] <== leaves[9];
    nodes[0][10] <== leaves[10];
    nodes[0][11] <== leaves[11];
    nodes[0][12] <== leaves[12];
    nodes[0][13] <== leaves[13];
    nodes[0][14] <== leaves[14];
    nodes[0][15] <== leaves[15];
    nodes[0][16] <== leaves[16];
    nodes[0][17] <== leaves[17];
    nodes[0][18] <== leaves[18];
    nodes[0][19] <== leaves[19];
    nodes[0][20] <== leaves[20];
    nodes[0][21] <== leaves[21];
    nodes[0][22] <== leaves[22];
    nodes[0][23] <== leaves[23];
    nodes[0][24] <== leaves[24];
    nodes[0][25] <== leaves[25];
    nodes[0][26] <== leaves[26];
    nodes[0][27] <== leaves[27];
    nodes[0][28] <== leaves[28];
    nodes[0][29] <== leaves[29];
    nodes[0][30] <== leaves[30];
    nodes[0][31] <== leaves[31];

    component hasher[31];
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
    hasher[4].inputs[0] <== nodes[0][8];
    hasher[4].inputs[1] <== nodes[0][9];
    nodes[1][4] <== hasher[4].out;

    hasher[5] = Poseidon(2);
    hasher[5].inputs[0] <== nodes[0][10];
    hasher[5].inputs[1] <== nodes[0][11];
    nodes[1][5] <== hasher[5].out;

    hasher[6] = Poseidon(2);
    hasher[6].inputs[0] <== nodes[0][12];
    hasher[6].inputs[1] <== nodes[0][13];
    nodes[1][6] <== hasher[6].out;

    hasher[7] = Poseidon(2);
    hasher[7].inputs[0] <== nodes[0][14];
    hasher[7].inputs[1] <== nodes[0][15];
    nodes[1][7] <== hasher[7].out;

    hasher[8] = Poseidon(2);
    hasher[8].inputs[0] <== nodes[0][16];
    hasher[8].inputs[1] <== nodes[0][17];
    nodes[1][8] <== hasher[8].out;

    hasher[9] = Poseidon(2);
    hasher[9].inputs[0] <== nodes[0][18];
    hasher[9].inputs[1] <== nodes[0][19];
    nodes[1][9] <== hasher[9].out;

    hasher[10] = Poseidon(2);
    hasher[10].inputs[0] <== nodes[0][20];
    hasher[10].inputs[1] <== nodes[0][21];
    nodes[1][10] <== hasher[10].out;

    hasher[11] = Poseidon(2);
    hasher[11].inputs[0] <== nodes[0][22];
    hasher[11].inputs[1] <== nodes[0][23];
    nodes[1][11] <== hasher[11].out;

    hasher[12] = Poseidon(2);
    hasher[12].inputs[0] <== nodes[0][24];
    hasher[12].inputs[1] <== nodes[0][25];
    nodes[1][12] <== hasher[12].out;

    hasher[13] = Poseidon(2);
    hasher[13].inputs[0] <== nodes[0][26];
    hasher[13].inputs[1] <== nodes[0][27];
    nodes[1][13] <== hasher[13].out;

    hasher[14] = Poseidon(2);
    hasher[14].inputs[0] <== nodes[0][28];
    hasher[14].inputs[1] <== nodes[0][29];
    nodes[1][14] <== hasher[14].out;

    hasher[15] = Poseidon(2);
    hasher[15].inputs[0] <== nodes[0][30];
    hasher[15].inputs[1] <== nodes[0][31];
    nodes[1][15] <== hasher[15].out;

    hasher[16] = Poseidon(2);
    hasher[16].inputs[0] <== nodes[1][0];
    hasher[16].inputs[1] <== nodes[1][1];
    nodes[2][0] <== hasher[16].out;

    hasher[17] = Poseidon(2);
    hasher[17].inputs[0] <== nodes[1][2];
    hasher[17].inputs[1] <== nodes[1][3];
    nodes[2][1] <== hasher[17].out;

    hasher[18] = Poseidon(2);
    hasher[18].inputs[0] <== nodes[1][4];
    hasher[18].inputs[1] <== nodes[1][5];
    nodes[2][2] <== hasher[18].out;

    hasher[19] = Poseidon(2);
    hasher[19].inputs[0] <== nodes[1][6];
    hasher[19].inputs[1] <== nodes[1][7];
    nodes[2][3] <== hasher[19].out;

    hasher[20] = Poseidon(2);
    hasher[20].inputs[0] <== nodes[1][8];
    hasher[20].inputs[1] <== nodes[1][9];
    nodes[2][4] <== hasher[20].out;

    hasher[21] = Poseidon(2);
    hasher[21].inputs[0] <== nodes[1][10];
    hasher[21].inputs[1] <== nodes[1][11];
    nodes[2][5] <== hasher[21].out;

    hasher[22] = Poseidon(2);
    hasher[22].inputs[0] <== nodes[1][12];
    hasher[22].inputs[1] <== nodes[1][13];
    nodes[2][6] <== hasher[22].out;

    hasher[23] = Poseidon(2);
    hasher[23].inputs[0] <== nodes[1][14];
    hasher[23].inputs[1] <== nodes[1][15];
    nodes[2][7] <== hasher[23].out;

    hasher[24] = Poseidon(2);
    hasher[24].inputs[0] <== nodes[2][0];
    hasher[24].inputs[1] <== nodes[2][1];
    nodes[3][0] <== hasher[24].out;

    hasher[25] = Poseidon(2);
    hasher[25].inputs[0] <== nodes[2][2];
    hasher[25].inputs[1] <== nodes[2][3];
    nodes[3][1] <== hasher[25].out;

    hasher[26] = Poseidon(2);
    hasher[26].inputs[0] <== nodes[2][4];
    hasher[26].inputs[1] <== nodes[2][5];
    nodes[3][2] <== hasher[26].out;

    hasher[27] = Poseidon(2);
    hasher[27].inputs[0] <== nodes[2][6];
    hasher[27].inputs[1] <== nodes[2][7];
    nodes[3][3] <== hasher[27].out;

    hasher[28] = Poseidon(2);
    hasher[28].inputs[0] <== nodes[3][0];
    hasher[28].inputs[1] <== nodes[3][1];
    nodes[4][0] <== hasher[28].out;

    hasher[29] = Poseidon(2);
    hasher[29].inputs[0] <== nodes[3][2];
    hasher[29].inputs[1] <== nodes[3][3];
    nodes[4][1] <== hasher[29].out;

    hasher[30] = Poseidon(2);
    hasher[30].inputs[0] <== nodes[4][0];
    hasher[30].inputs[1] <== nodes[4][1];
    nodes[5][0] <== hasher[30].out;

    pubCommitment === nodes[5][0];
}

component main {public [pubGuessX, pubGuessY, pubCommitment, pubReportedHit]} = BattleshipHit(17);
