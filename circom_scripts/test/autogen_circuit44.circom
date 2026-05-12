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
    signal input privShipX[44];
    signal input privShipY[44];
    signal input privSalt;
    signal output pubCommitment;

    signal leaves[64];

    component lessX[44];
    component lessY[44];

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

    lessX[17] = LessThan(4);
    lessX[17].in[0] <== privShipX[17];
    lessX[17].in[1] <== 10;
    lessX[17].out === 1;

    lessY[17] = LessThan(4);
    lessY[17].in[0] <== privShipY[17];
    lessY[17].in[1] <== 10;
    lessY[17].out === 1;

    leaves[17] <== privShipX[17] * 10 + privShipY[17] + 1;

    lessX[18] = LessThan(4);
    lessX[18].in[0] <== privShipX[18];
    lessX[18].in[1] <== 10;
    lessX[18].out === 1;

    lessY[18] = LessThan(4);
    lessY[18].in[0] <== privShipY[18];
    lessY[18].in[1] <== 10;
    lessY[18].out === 1;

    leaves[18] <== privShipX[18] * 10 + privShipY[18] + 1;

    lessX[19] = LessThan(4);
    lessX[19].in[0] <== privShipX[19];
    lessX[19].in[1] <== 10;
    lessX[19].out === 1;

    lessY[19] = LessThan(4);
    lessY[19].in[0] <== privShipY[19];
    lessY[19].in[1] <== 10;
    lessY[19].out === 1;

    leaves[19] <== privShipX[19] * 10 + privShipY[19] + 1;

    lessX[20] = LessThan(4);
    lessX[20].in[0] <== privShipX[20];
    lessX[20].in[1] <== 10;
    lessX[20].out === 1;

    lessY[20] = LessThan(4);
    lessY[20].in[0] <== privShipY[20];
    lessY[20].in[1] <== 10;
    lessY[20].out === 1;

    leaves[20] <== privShipX[20] * 10 + privShipY[20] + 1;

    lessX[21] = LessThan(4);
    lessX[21].in[0] <== privShipX[21];
    lessX[21].in[1] <== 10;
    lessX[21].out === 1;

    lessY[21] = LessThan(4);
    lessY[21].in[0] <== privShipY[21];
    lessY[21].in[1] <== 10;
    lessY[21].out === 1;

    leaves[21] <== privShipX[21] * 10 + privShipY[21] + 1;

    lessX[22] = LessThan(4);
    lessX[22].in[0] <== privShipX[22];
    lessX[22].in[1] <== 10;
    lessX[22].out === 1;

    lessY[22] = LessThan(4);
    lessY[22].in[0] <== privShipY[22];
    lessY[22].in[1] <== 10;
    lessY[22].out === 1;

    leaves[22] <== privShipX[22] * 10 + privShipY[22] + 1;

    lessX[23] = LessThan(4);
    lessX[23].in[0] <== privShipX[23];
    lessX[23].in[1] <== 10;
    lessX[23].out === 1;

    lessY[23] = LessThan(4);
    lessY[23].in[0] <== privShipY[23];
    lessY[23].in[1] <== 10;
    lessY[23].out === 1;

    leaves[23] <== privShipX[23] * 10 + privShipY[23] + 1;

    lessX[24] = LessThan(4);
    lessX[24].in[0] <== privShipX[24];
    lessX[24].in[1] <== 10;
    lessX[24].out === 1;

    lessY[24] = LessThan(4);
    lessY[24].in[0] <== privShipY[24];
    lessY[24].in[1] <== 10;
    lessY[24].out === 1;

    leaves[24] <== privShipX[24] * 10 + privShipY[24] + 1;

    lessX[25] = LessThan(4);
    lessX[25].in[0] <== privShipX[25];
    lessX[25].in[1] <== 10;
    lessX[25].out === 1;

    lessY[25] = LessThan(4);
    lessY[25].in[0] <== privShipY[25];
    lessY[25].in[1] <== 10;
    lessY[25].out === 1;

    leaves[25] <== privShipX[25] * 10 + privShipY[25] + 1;

    lessX[26] = LessThan(4);
    lessX[26].in[0] <== privShipX[26];
    lessX[26].in[1] <== 10;
    lessX[26].out === 1;

    lessY[26] = LessThan(4);
    lessY[26].in[0] <== privShipY[26];
    lessY[26].in[1] <== 10;
    lessY[26].out === 1;

    leaves[26] <== privShipX[26] * 10 + privShipY[26] + 1;

    lessX[27] = LessThan(4);
    lessX[27].in[0] <== privShipX[27];
    lessX[27].in[1] <== 10;
    lessX[27].out === 1;

    lessY[27] = LessThan(4);
    lessY[27].in[0] <== privShipY[27];
    lessY[27].in[1] <== 10;
    lessY[27].out === 1;

    leaves[27] <== privShipX[27] * 10 + privShipY[27] + 1;

    lessX[28] = LessThan(4);
    lessX[28].in[0] <== privShipX[28];
    lessX[28].in[1] <== 10;
    lessX[28].out === 1;

    lessY[28] = LessThan(4);
    lessY[28].in[0] <== privShipY[28];
    lessY[28].in[1] <== 10;
    lessY[28].out === 1;

    leaves[28] <== privShipX[28] * 10 + privShipY[28] + 1;

    lessX[29] = LessThan(4);
    lessX[29].in[0] <== privShipX[29];
    lessX[29].in[1] <== 10;
    lessX[29].out === 1;

    lessY[29] = LessThan(4);
    lessY[29].in[0] <== privShipY[29];
    lessY[29].in[1] <== 10;
    lessY[29].out === 1;

    leaves[29] <== privShipX[29] * 10 + privShipY[29] + 1;

    lessX[30] = LessThan(4);
    lessX[30].in[0] <== privShipX[30];
    lessX[30].in[1] <== 10;
    lessX[30].out === 1;

    lessY[30] = LessThan(4);
    lessY[30].in[0] <== privShipY[30];
    lessY[30].in[1] <== 10;
    lessY[30].out === 1;

    leaves[30] <== privShipX[30] * 10 + privShipY[30] + 1;

    lessX[31] = LessThan(4);
    lessX[31].in[0] <== privShipX[31];
    lessX[31].in[1] <== 10;
    lessX[31].out === 1;

    lessY[31] = LessThan(4);
    lessY[31].in[0] <== privShipY[31];
    lessY[31].in[1] <== 10;
    lessY[31].out === 1;

    leaves[31] <== privShipX[31] * 10 + privShipY[31] + 1;

    lessX[32] = LessThan(4);
    lessX[32].in[0] <== privShipX[32];
    lessX[32].in[1] <== 10;
    lessX[32].out === 1;

    lessY[32] = LessThan(4);
    lessY[32].in[0] <== privShipY[32];
    lessY[32].in[1] <== 10;
    lessY[32].out === 1;

    leaves[32] <== privShipX[32] * 10 + privShipY[32] + 1;

    lessX[33] = LessThan(4);
    lessX[33].in[0] <== privShipX[33];
    lessX[33].in[1] <== 10;
    lessX[33].out === 1;

    lessY[33] = LessThan(4);
    lessY[33].in[0] <== privShipY[33];
    lessY[33].in[1] <== 10;
    lessY[33].out === 1;

    leaves[33] <== privShipX[33] * 10 + privShipY[33] + 1;

    lessX[34] = LessThan(4);
    lessX[34].in[0] <== privShipX[34];
    lessX[34].in[1] <== 10;
    lessX[34].out === 1;

    lessY[34] = LessThan(4);
    lessY[34].in[0] <== privShipY[34];
    lessY[34].in[1] <== 10;
    lessY[34].out === 1;

    leaves[34] <== privShipX[34] * 10 + privShipY[34] + 1;

    lessX[35] = LessThan(4);
    lessX[35].in[0] <== privShipX[35];
    lessX[35].in[1] <== 10;
    lessX[35].out === 1;

    lessY[35] = LessThan(4);
    lessY[35].in[0] <== privShipY[35];
    lessY[35].in[1] <== 10;
    lessY[35].out === 1;

    leaves[35] <== privShipX[35] * 10 + privShipY[35] + 1;

    lessX[36] = LessThan(4);
    lessX[36].in[0] <== privShipX[36];
    lessX[36].in[1] <== 10;
    lessX[36].out === 1;

    lessY[36] = LessThan(4);
    lessY[36].in[0] <== privShipY[36];
    lessY[36].in[1] <== 10;
    lessY[36].out === 1;

    leaves[36] <== privShipX[36] * 10 + privShipY[36] + 1;

    lessX[37] = LessThan(4);
    lessX[37].in[0] <== privShipX[37];
    lessX[37].in[1] <== 10;
    lessX[37].out === 1;

    lessY[37] = LessThan(4);
    lessY[37].in[0] <== privShipY[37];
    lessY[37].in[1] <== 10;
    lessY[37].out === 1;

    leaves[37] <== privShipX[37] * 10 + privShipY[37] + 1;

    lessX[38] = LessThan(4);
    lessX[38].in[0] <== privShipX[38];
    lessX[38].in[1] <== 10;
    lessX[38].out === 1;

    lessY[38] = LessThan(4);
    lessY[38].in[0] <== privShipY[38];
    lessY[38].in[1] <== 10;
    lessY[38].out === 1;

    leaves[38] <== privShipX[38] * 10 + privShipY[38] + 1;

    lessX[39] = LessThan(4);
    lessX[39].in[0] <== privShipX[39];
    lessX[39].in[1] <== 10;
    lessX[39].out === 1;

    lessY[39] = LessThan(4);
    lessY[39].in[0] <== privShipY[39];
    lessY[39].in[1] <== 10;
    lessY[39].out === 1;

    leaves[39] <== privShipX[39] * 10 + privShipY[39] + 1;

    lessX[40] = LessThan(4);
    lessX[40].in[0] <== privShipX[40];
    lessX[40].in[1] <== 10;
    lessX[40].out === 1;

    lessY[40] = LessThan(4);
    lessY[40].in[0] <== privShipY[40];
    lessY[40].in[1] <== 10;
    lessY[40].out === 1;

    leaves[40] <== privShipX[40] * 10 + privShipY[40] + 1;

    lessX[41] = LessThan(4);
    lessX[41].in[0] <== privShipX[41];
    lessX[41].in[1] <== 10;
    lessX[41].out === 1;

    lessY[41] = LessThan(4);
    lessY[41].in[0] <== privShipY[41];
    lessY[41].in[1] <== 10;
    lessY[41].out === 1;

    leaves[41] <== privShipX[41] * 10 + privShipY[41] + 1;

    lessX[42] = LessThan(4);
    lessX[42].in[0] <== privShipX[42];
    lessX[42].in[1] <== 10;
    lessX[42].out === 1;

    lessY[42] = LessThan(4);
    lessY[42].in[0] <== privShipY[42];
    lessY[42].in[1] <== 10;
    lessY[42].out === 1;

    leaves[42] <== privShipX[42] * 10 + privShipY[42] + 1;

    lessX[43] = LessThan(4);
    lessX[43].in[0] <== privShipX[43];
    lessX[43].in[1] <== 10;
    lessX[43].out === 1;

    lessY[43] = LessThan(4);
    lessY[43].in[0] <== privShipY[43];
    lessY[43].in[1] <== 10;
    lessY[43].out === 1;

    leaves[43] <== privShipX[43] * 10 + privShipY[43] + 1;

    leaves[44] <== privSalt;

    leaves[45] <== 0;

    leaves[46] <== 0;

    leaves[47] <== 0;

    leaves[48] <== 0;

    leaves[49] <== 0;

    leaves[50] <== 0;

    leaves[51] <== 0;

    leaves[52] <== 0;

    leaves[53] <== 0;

    leaves[54] <== 0;

    leaves[55] <== 0;

    leaves[56] <== 0;

    leaves[57] <== 0;

    leaves[58] <== 0;

    leaves[59] <== 0;

    leaves[60] <== 0;

    leaves[61] <== 0;

    leaves[62] <== 0;

    leaves[63] <== 0;

    component eq[946];
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
    eq[15] = IsEqual();
    eq[16] = IsEqual();
    eq[17] = IsEqual();
    eq[18] = IsEqual();
    eq[19] = IsEqual();
    eq[20] = IsEqual();
    eq[21] = IsEqual();
    eq[22] = IsEqual();
    eq[23] = IsEqual();
    eq[24] = IsEqual();
    eq[25] = IsEqual();
    eq[26] = IsEqual();
    eq[27] = IsEqual();
    eq[28] = IsEqual();
    eq[29] = IsEqual();
    eq[30] = IsEqual();
    eq[31] = IsEqual();
    eq[32] = IsEqual();
    eq[33] = IsEqual();
    eq[34] = IsEqual();
    eq[35] = IsEqual();
    eq[36] = IsEqual();
    eq[37] = IsEqual();
    eq[38] = IsEqual();
    eq[39] = IsEqual();
    eq[40] = IsEqual();
    eq[41] = IsEqual();
    eq[42] = IsEqual();
    eq[43] = IsEqual();
    eq[44] = IsEqual();
    eq[45] = IsEqual();
    eq[46] = IsEqual();
    eq[47] = IsEqual();
    eq[48] = IsEqual();
    eq[49] = IsEqual();
    eq[50] = IsEqual();
    eq[51] = IsEqual();
    eq[52] = IsEqual();
    eq[53] = IsEqual();
    eq[54] = IsEqual();
    eq[55] = IsEqual();
    eq[56] = IsEqual();
    eq[57] = IsEqual();
    eq[58] = IsEqual();
    eq[59] = IsEqual();
    eq[60] = IsEqual();
    eq[61] = IsEqual();
    eq[62] = IsEqual();
    eq[63] = IsEqual();
    eq[64] = IsEqual();
    eq[65] = IsEqual();
    eq[66] = IsEqual();
    eq[67] = IsEqual();
    eq[68] = IsEqual();
    eq[69] = IsEqual();
    eq[70] = IsEqual();
    eq[71] = IsEqual();
    eq[72] = IsEqual();
    eq[73] = IsEqual();
    eq[74] = IsEqual();
    eq[75] = IsEqual();
    eq[76] = IsEqual();
    eq[77] = IsEqual();
    eq[78] = IsEqual();
    eq[79] = IsEqual();
    eq[80] = IsEqual();
    eq[81] = IsEqual();
    eq[82] = IsEqual();
    eq[83] = IsEqual();
    eq[84] = IsEqual();
    eq[85] = IsEqual();
    eq[86] = IsEqual();
    eq[87] = IsEqual();
    eq[88] = IsEqual();
    eq[89] = IsEqual();
    eq[90] = IsEqual();
    eq[91] = IsEqual();
    eq[92] = IsEqual();
    eq[93] = IsEqual();
    eq[94] = IsEqual();
    eq[95] = IsEqual();
    eq[96] = IsEqual();
    eq[97] = IsEqual();
    eq[98] = IsEqual();
    eq[99] = IsEqual();
    eq[100] = IsEqual();
    eq[101] = IsEqual();
    eq[102] = IsEqual();
    eq[103] = IsEqual();
    eq[104] = IsEqual();
    eq[105] = IsEqual();
    eq[106] = IsEqual();
    eq[107] = IsEqual();
    eq[108] = IsEqual();
    eq[109] = IsEqual();
    eq[110] = IsEqual();
    eq[111] = IsEqual();
    eq[112] = IsEqual();
    eq[113] = IsEqual();
    eq[114] = IsEqual();
    eq[115] = IsEqual();
    eq[116] = IsEqual();
    eq[117] = IsEqual();
    eq[118] = IsEqual();
    eq[119] = IsEqual();
    eq[120] = IsEqual();
    eq[121] = IsEqual();
    eq[122] = IsEqual();
    eq[123] = IsEqual();
    eq[124] = IsEqual();
    eq[125] = IsEqual();
    eq[126] = IsEqual();
    eq[127] = IsEqual();
    eq[128] = IsEqual();
    eq[129] = IsEqual();
    eq[130] = IsEqual();
    eq[131] = IsEqual();
    eq[132] = IsEqual();
    eq[133] = IsEqual();
    eq[134] = IsEqual();
    eq[135] = IsEqual();
    eq[136] = IsEqual();
    eq[137] = IsEqual();
    eq[138] = IsEqual();
    eq[139] = IsEqual();
    eq[140] = IsEqual();
    eq[141] = IsEqual();
    eq[142] = IsEqual();
    eq[143] = IsEqual();
    eq[144] = IsEqual();
    eq[145] = IsEqual();
    eq[146] = IsEqual();
    eq[147] = IsEqual();
    eq[148] = IsEqual();
    eq[149] = IsEqual();
    eq[150] = IsEqual();
    eq[151] = IsEqual();
    eq[152] = IsEqual();
    eq[153] = IsEqual();
    eq[154] = IsEqual();
    eq[155] = IsEqual();
    eq[156] = IsEqual();
    eq[157] = IsEqual();
    eq[158] = IsEqual();
    eq[159] = IsEqual();
    eq[160] = IsEqual();
    eq[161] = IsEqual();
    eq[162] = IsEqual();
    eq[163] = IsEqual();
    eq[164] = IsEqual();
    eq[165] = IsEqual();
    eq[166] = IsEqual();
    eq[167] = IsEqual();
    eq[168] = IsEqual();
    eq[169] = IsEqual();
    eq[170] = IsEqual();
    eq[171] = IsEqual();
    eq[172] = IsEqual();
    eq[173] = IsEqual();
    eq[174] = IsEqual();
    eq[175] = IsEqual();
    eq[176] = IsEqual();
    eq[177] = IsEqual();
    eq[178] = IsEqual();
    eq[179] = IsEqual();
    eq[180] = IsEqual();
    eq[181] = IsEqual();
    eq[182] = IsEqual();
    eq[183] = IsEqual();
    eq[184] = IsEqual();
    eq[185] = IsEqual();
    eq[186] = IsEqual();
    eq[187] = IsEqual();
    eq[188] = IsEqual();
    eq[189] = IsEqual();
    eq[190] = IsEqual();
    eq[191] = IsEqual();
    eq[192] = IsEqual();
    eq[193] = IsEqual();
    eq[194] = IsEqual();
    eq[195] = IsEqual();
    eq[196] = IsEqual();
    eq[197] = IsEqual();
    eq[198] = IsEqual();
    eq[199] = IsEqual();
    eq[200] = IsEqual();
    eq[201] = IsEqual();
    eq[202] = IsEqual();
    eq[203] = IsEqual();
    eq[204] = IsEqual();
    eq[205] = IsEqual();
    eq[206] = IsEqual();
    eq[207] = IsEqual();
    eq[208] = IsEqual();
    eq[209] = IsEqual();
    eq[210] = IsEqual();
    eq[211] = IsEqual();
    eq[212] = IsEqual();
    eq[213] = IsEqual();
    eq[214] = IsEqual();
    eq[215] = IsEqual();
    eq[216] = IsEqual();
    eq[217] = IsEqual();
    eq[218] = IsEqual();
    eq[219] = IsEqual();
    eq[220] = IsEqual();
    eq[221] = IsEqual();
    eq[222] = IsEqual();
    eq[223] = IsEqual();
    eq[224] = IsEqual();
    eq[225] = IsEqual();
    eq[226] = IsEqual();
    eq[227] = IsEqual();
    eq[228] = IsEqual();
    eq[229] = IsEqual();
    eq[230] = IsEqual();
    eq[231] = IsEqual();
    eq[232] = IsEqual();
    eq[233] = IsEqual();
    eq[234] = IsEqual();
    eq[235] = IsEqual();
    eq[236] = IsEqual();
    eq[237] = IsEqual();
    eq[238] = IsEqual();
    eq[239] = IsEqual();
    eq[240] = IsEqual();
    eq[241] = IsEqual();
    eq[242] = IsEqual();
    eq[243] = IsEqual();
    eq[244] = IsEqual();
    eq[245] = IsEqual();
    eq[246] = IsEqual();
    eq[247] = IsEqual();
    eq[248] = IsEqual();
    eq[249] = IsEqual();
    eq[250] = IsEqual();
    eq[251] = IsEqual();
    eq[252] = IsEqual();
    eq[253] = IsEqual();
    eq[254] = IsEqual();
    eq[255] = IsEqual();
    eq[256] = IsEqual();
    eq[257] = IsEqual();
    eq[258] = IsEqual();
    eq[259] = IsEqual();
    eq[260] = IsEqual();
    eq[261] = IsEqual();
    eq[262] = IsEqual();
    eq[263] = IsEqual();
    eq[264] = IsEqual();
    eq[265] = IsEqual();
    eq[266] = IsEqual();
    eq[267] = IsEqual();
    eq[268] = IsEqual();
    eq[269] = IsEqual();
    eq[270] = IsEqual();
    eq[271] = IsEqual();
    eq[272] = IsEqual();
    eq[273] = IsEqual();
    eq[274] = IsEqual();
    eq[275] = IsEqual();
    eq[276] = IsEqual();
    eq[277] = IsEqual();
    eq[278] = IsEqual();
    eq[279] = IsEqual();
    eq[280] = IsEqual();
    eq[281] = IsEqual();
    eq[282] = IsEqual();
    eq[283] = IsEqual();
    eq[284] = IsEqual();
    eq[285] = IsEqual();
    eq[286] = IsEqual();
    eq[287] = IsEqual();
    eq[288] = IsEqual();
    eq[289] = IsEqual();
    eq[290] = IsEqual();
    eq[291] = IsEqual();
    eq[292] = IsEqual();
    eq[293] = IsEqual();
    eq[294] = IsEqual();
    eq[295] = IsEqual();
    eq[296] = IsEqual();
    eq[297] = IsEqual();
    eq[298] = IsEqual();
    eq[299] = IsEqual();
    eq[300] = IsEqual();
    eq[301] = IsEqual();
    eq[302] = IsEqual();
    eq[303] = IsEqual();
    eq[304] = IsEqual();
    eq[305] = IsEqual();
    eq[306] = IsEqual();
    eq[307] = IsEqual();
    eq[308] = IsEqual();
    eq[309] = IsEqual();
    eq[310] = IsEqual();
    eq[311] = IsEqual();
    eq[312] = IsEqual();
    eq[313] = IsEqual();
    eq[314] = IsEqual();
    eq[315] = IsEqual();
    eq[316] = IsEqual();
    eq[317] = IsEqual();
    eq[318] = IsEqual();
    eq[319] = IsEqual();
    eq[320] = IsEqual();
    eq[321] = IsEqual();
    eq[322] = IsEqual();
    eq[323] = IsEqual();
    eq[324] = IsEqual();
    eq[325] = IsEqual();
    eq[326] = IsEqual();
    eq[327] = IsEqual();
    eq[328] = IsEqual();
    eq[329] = IsEqual();
    eq[330] = IsEqual();
    eq[331] = IsEqual();
    eq[332] = IsEqual();
    eq[333] = IsEqual();
    eq[334] = IsEqual();
    eq[335] = IsEqual();
    eq[336] = IsEqual();
    eq[337] = IsEqual();
    eq[338] = IsEqual();
    eq[339] = IsEqual();
    eq[340] = IsEqual();
    eq[341] = IsEqual();
    eq[342] = IsEqual();
    eq[343] = IsEqual();
    eq[344] = IsEqual();
    eq[345] = IsEqual();
    eq[346] = IsEqual();
    eq[347] = IsEqual();
    eq[348] = IsEqual();
    eq[349] = IsEqual();
    eq[350] = IsEqual();
    eq[351] = IsEqual();
    eq[352] = IsEqual();
    eq[353] = IsEqual();
    eq[354] = IsEqual();
    eq[355] = IsEqual();
    eq[356] = IsEqual();
    eq[357] = IsEqual();
    eq[358] = IsEqual();
    eq[359] = IsEqual();
    eq[360] = IsEqual();
    eq[361] = IsEqual();
    eq[362] = IsEqual();
    eq[363] = IsEqual();
    eq[364] = IsEqual();
    eq[365] = IsEqual();
    eq[366] = IsEqual();
    eq[367] = IsEqual();
    eq[368] = IsEqual();
    eq[369] = IsEqual();
    eq[370] = IsEqual();
    eq[371] = IsEqual();
    eq[372] = IsEqual();
    eq[373] = IsEqual();
    eq[374] = IsEqual();
    eq[375] = IsEqual();
    eq[376] = IsEqual();
    eq[377] = IsEqual();
    eq[378] = IsEqual();
    eq[379] = IsEqual();
    eq[380] = IsEqual();
    eq[381] = IsEqual();
    eq[382] = IsEqual();
    eq[383] = IsEqual();
    eq[384] = IsEqual();
    eq[385] = IsEqual();
    eq[386] = IsEqual();
    eq[387] = IsEqual();
    eq[388] = IsEqual();
    eq[389] = IsEqual();
    eq[390] = IsEqual();
    eq[391] = IsEqual();
    eq[392] = IsEqual();
    eq[393] = IsEqual();
    eq[394] = IsEqual();
    eq[395] = IsEqual();
    eq[396] = IsEqual();
    eq[397] = IsEqual();
    eq[398] = IsEqual();
    eq[399] = IsEqual();
    eq[400] = IsEqual();
    eq[401] = IsEqual();
    eq[402] = IsEqual();
    eq[403] = IsEqual();
    eq[404] = IsEqual();
    eq[405] = IsEqual();
    eq[406] = IsEqual();
    eq[407] = IsEqual();
    eq[408] = IsEqual();
    eq[409] = IsEqual();
    eq[410] = IsEqual();
    eq[411] = IsEqual();
    eq[412] = IsEqual();
    eq[413] = IsEqual();
    eq[414] = IsEqual();
    eq[415] = IsEqual();
    eq[416] = IsEqual();
    eq[417] = IsEqual();
    eq[418] = IsEqual();
    eq[419] = IsEqual();
    eq[420] = IsEqual();
    eq[421] = IsEqual();
    eq[422] = IsEqual();
    eq[423] = IsEqual();
    eq[424] = IsEqual();
    eq[425] = IsEqual();
    eq[426] = IsEqual();
    eq[427] = IsEqual();
    eq[428] = IsEqual();
    eq[429] = IsEqual();
    eq[430] = IsEqual();
    eq[431] = IsEqual();
    eq[432] = IsEqual();
    eq[433] = IsEqual();
    eq[434] = IsEqual();
    eq[435] = IsEqual();
    eq[436] = IsEqual();
    eq[437] = IsEqual();
    eq[438] = IsEqual();
    eq[439] = IsEqual();
    eq[440] = IsEqual();
    eq[441] = IsEqual();
    eq[442] = IsEqual();
    eq[443] = IsEqual();
    eq[444] = IsEqual();
    eq[445] = IsEqual();
    eq[446] = IsEqual();
    eq[447] = IsEqual();
    eq[448] = IsEqual();
    eq[449] = IsEqual();
    eq[450] = IsEqual();
    eq[451] = IsEqual();
    eq[452] = IsEqual();
    eq[453] = IsEqual();
    eq[454] = IsEqual();
    eq[455] = IsEqual();
    eq[456] = IsEqual();
    eq[457] = IsEqual();
    eq[458] = IsEqual();
    eq[459] = IsEqual();
    eq[460] = IsEqual();
    eq[461] = IsEqual();
    eq[462] = IsEqual();
    eq[463] = IsEqual();
    eq[464] = IsEqual();
    eq[465] = IsEqual();
    eq[466] = IsEqual();
    eq[467] = IsEqual();
    eq[468] = IsEqual();
    eq[469] = IsEqual();
    eq[470] = IsEqual();
    eq[471] = IsEqual();
    eq[472] = IsEqual();
    eq[473] = IsEqual();
    eq[474] = IsEqual();
    eq[475] = IsEqual();
    eq[476] = IsEqual();
    eq[477] = IsEqual();
    eq[478] = IsEqual();
    eq[479] = IsEqual();
    eq[480] = IsEqual();
    eq[481] = IsEqual();
    eq[482] = IsEqual();
    eq[483] = IsEqual();
    eq[484] = IsEqual();
    eq[485] = IsEqual();
    eq[486] = IsEqual();
    eq[487] = IsEqual();
    eq[488] = IsEqual();
    eq[489] = IsEqual();
    eq[490] = IsEqual();
    eq[491] = IsEqual();
    eq[492] = IsEqual();
    eq[493] = IsEqual();
    eq[494] = IsEqual();
    eq[495] = IsEqual();
    eq[496] = IsEqual();
    eq[497] = IsEqual();
    eq[498] = IsEqual();
    eq[499] = IsEqual();
    eq[500] = IsEqual();
    eq[501] = IsEqual();
    eq[502] = IsEqual();
    eq[503] = IsEqual();
    eq[504] = IsEqual();
    eq[505] = IsEqual();
    eq[506] = IsEqual();
    eq[507] = IsEqual();
    eq[508] = IsEqual();
    eq[509] = IsEqual();
    eq[510] = IsEqual();
    eq[511] = IsEqual();
    eq[512] = IsEqual();
    eq[513] = IsEqual();
    eq[514] = IsEqual();
    eq[515] = IsEqual();
    eq[516] = IsEqual();
    eq[517] = IsEqual();
    eq[518] = IsEqual();
    eq[519] = IsEqual();
    eq[520] = IsEqual();
    eq[521] = IsEqual();
    eq[522] = IsEqual();
    eq[523] = IsEqual();
    eq[524] = IsEqual();
    eq[525] = IsEqual();
    eq[526] = IsEqual();
    eq[527] = IsEqual();
    eq[528] = IsEqual();
    eq[529] = IsEqual();
    eq[530] = IsEqual();
    eq[531] = IsEqual();
    eq[532] = IsEqual();
    eq[533] = IsEqual();
    eq[534] = IsEqual();
    eq[535] = IsEqual();
    eq[536] = IsEqual();
    eq[537] = IsEqual();
    eq[538] = IsEqual();
    eq[539] = IsEqual();
    eq[540] = IsEqual();
    eq[541] = IsEqual();
    eq[542] = IsEqual();
    eq[543] = IsEqual();
    eq[544] = IsEqual();
    eq[545] = IsEqual();
    eq[546] = IsEqual();
    eq[547] = IsEqual();
    eq[548] = IsEqual();
    eq[549] = IsEqual();
    eq[550] = IsEqual();
    eq[551] = IsEqual();
    eq[552] = IsEqual();
    eq[553] = IsEqual();
    eq[554] = IsEqual();
    eq[555] = IsEqual();
    eq[556] = IsEqual();
    eq[557] = IsEqual();
    eq[558] = IsEqual();
    eq[559] = IsEqual();
    eq[560] = IsEqual();
    eq[561] = IsEqual();
    eq[562] = IsEqual();
    eq[563] = IsEqual();
    eq[564] = IsEqual();
    eq[565] = IsEqual();
    eq[566] = IsEqual();
    eq[567] = IsEqual();
    eq[568] = IsEqual();
    eq[569] = IsEqual();
    eq[570] = IsEqual();
    eq[571] = IsEqual();
    eq[572] = IsEqual();
    eq[573] = IsEqual();
    eq[574] = IsEqual();
    eq[575] = IsEqual();
    eq[576] = IsEqual();
    eq[577] = IsEqual();
    eq[578] = IsEqual();
    eq[579] = IsEqual();
    eq[580] = IsEqual();
    eq[581] = IsEqual();
    eq[582] = IsEqual();
    eq[583] = IsEqual();
    eq[584] = IsEqual();
    eq[585] = IsEqual();
    eq[586] = IsEqual();
    eq[587] = IsEqual();
    eq[588] = IsEqual();
    eq[589] = IsEqual();
    eq[590] = IsEqual();
    eq[591] = IsEqual();
    eq[592] = IsEqual();
    eq[593] = IsEqual();
    eq[594] = IsEqual();
    eq[595] = IsEqual();
    eq[596] = IsEqual();
    eq[597] = IsEqual();
    eq[598] = IsEqual();
    eq[599] = IsEqual();
    eq[600] = IsEqual();
    eq[601] = IsEqual();
    eq[602] = IsEqual();
    eq[603] = IsEqual();
    eq[604] = IsEqual();
    eq[605] = IsEqual();
    eq[606] = IsEqual();
    eq[607] = IsEqual();
    eq[608] = IsEqual();
    eq[609] = IsEqual();
    eq[610] = IsEqual();
    eq[611] = IsEqual();
    eq[612] = IsEqual();
    eq[613] = IsEqual();
    eq[614] = IsEqual();
    eq[615] = IsEqual();
    eq[616] = IsEqual();
    eq[617] = IsEqual();
    eq[618] = IsEqual();
    eq[619] = IsEqual();
    eq[620] = IsEqual();
    eq[621] = IsEqual();
    eq[622] = IsEqual();
    eq[623] = IsEqual();
    eq[624] = IsEqual();
    eq[625] = IsEqual();
    eq[626] = IsEqual();
    eq[627] = IsEqual();
    eq[628] = IsEqual();
    eq[629] = IsEqual();
    eq[630] = IsEqual();
    eq[631] = IsEqual();
    eq[632] = IsEqual();
    eq[633] = IsEqual();
    eq[634] = IsEqual();
    eq[635] = IsEqual();
    eq[636] = IsEqual();
    eq[637] = IsEqual();
    eq[638] = IsEqual();
    eq[639] = IsEqual();
    eq[640] = IsEqual();
    eq[641] = IsEqual();
    eq[642] = IsEqual();
    eq[643] = IsEqual();
    eq[644] = IsEqual();
    eq[645] = IsEqual();
    eq[646] = IsEqual();
    eq[647] = IsEqual();
    eq[648] = IsEqual();
    eq[649] = IsEqual();
    eq[650] = IsEqual();
    eq[651] = IsEqual();
    eq[652] = IsEqual();
    eq[653] = IsEqual();
    eq[654] = IsEqual();
    eq[655] = IsEqual();
    eq[656] = IsEqual();
    eq[657] = IsEqual();
    eq[658] = IsEqual();
    eq[659] = IsEqual();
    eq[660] = IsEqual();
    eq[661] = IsEqual();
    eq[662] = IsEqual();
    eq[663] = IsEqual();
    eq[664] = IsEqual();
    eq[665] = IsEqual();
    eq[666] = IsEqual();
    eq[667] = IsEqual();
    eq[668] = IsEqual();
    eq[669] = IsEqual();
    eq[670] = IsEqual();
    eq[671] = IsEqual();
    eq[672] = IsEqual();
    eq[673] = IsEqual();
    eq[674] = IsEqual();
    eq[675] = IsEqual();
    eq[676] = IsEqual();
    eq[677] = IsEqual();
    eq[678] = IsEqual();
    eq[679] = IsEqual();
    eq[680] = IsEqual();
    eq[681] = IsEqual();
    eq[682] = IsEqual();
    eq[683] = IsEqual();
    eq[684] = IsEqual();
    eq[685] = IsEqual();
    eq[686] = IsEqual();
    eq[687] = IsEqual();
    eq[688] = IsEqual();
    eq[689] = IsEqual();
    eq[690] = IsEqual();
    eq[691] = IsEqual();
    eq[692] = IsEqual();
    eq[693] = IsEqual();
    eq[694] = IsEqual();
    eq[695] = IsEqual();
    eq[696] = IsEqual();
    eq[697] = IsEqual();
    eq[698] = IsEqual();
    eq[699] = IsEqual();
    eq[700] = IsEqual();
    eq[701] = IsEqual();
    eq[702] = IsEqual();
    eq[703] = IsEqual();
    eq[704] = IsEqual();
    eq[705] = IsEqual();
    eq[706] = IsEqual();
    eq[707] = IsEqual();
    eq[708] = IsEqual();
    eq[709] = IsEqual();
    eq[710] = IsEqual();
    eq[711] = IsEqual();
    eq[712] = IsEqual();
    eq[713] = IsEqual();
    eq[714] = IsEqual();
    eq[715] = IsEqual();
    eq[716] = IsEqual();
    eq[717] = IsEqual();
    eq[718] = IsEqual();
    eq[719] = IsEqual();
    eq[720] = IsEqual();
    eq[721] = IsEqual();
    eq[722] = IsEqual();
    eq[723] = IsEqual();
    eq[724] = IsEqual();
    eq[725] = IsEqual();
    eq[726] = IsEqual();
    eq[727] = IsEqual();
    eq[728] = IsEqual();
    eq[729] = IsEqual();
    eq[730] = IsEqual();
    eq[731] = IsEqual();
    eq[732] = IsEqual();
    eq[733] = IsEqual();
    eq[734] = IsEqual();
    eq[735] = IsEqual();
    eq[736] = IsEqual();
    eq[737] = IsEqual();
    eq[738] = IsEqual();
    eq[739] = IsEqual();
    eq[740] = IsEqual();
    eq[741] = IsEqual();
    eq[742] = IsEqual();
    eq[743] = IsEqual();
    eq[744] = IsEqual();
    eq[745] = IsEqual();
    eq[746] = IsEqual();
    eq[747] = IsEqual();
    eq[748] = IsEqual();
    eq[749] = IsEqual();
    eq[750] = IsEqual();
    eq[751] = IsEqual();
    eq[752] = IsEqual();
    eq[753] = IsEqual();
    eq[754] = IsEqual();
    eq[755] = IsEqual();
    eq[756] = IsEqual();
    eq[757] = IsEqual();
    eq[758] = IsEqual();
    eq[759] = IsEqual();
    eq[760] = IsEqual();
    eq[761] = IsEqual();
    eq[762] = IsEqual();
    eq[763] = IsEqual();
    eq[764] = IsEqual();
    eq[765] = IsEqual();
    eq[766] = IsEqual();
    eq[767] = IsEqual();
    eq[768] = IsEqual();
    eq[769] = IsEqual();
    eq[770] = IsEqual();
    eq[771] = IsEqual();
    eq[772] = IsEqual();
    eq[773] = IsEqual();
    eq[774] = IsEqual();
    eq[775] = IsEqual();
    eq[776] = IsEqual();
    eq[777] = IsEqual();
    eq[778] = IsEqual();
    eq[779] = IsEqual();
    eq[780] = IsEqual();
    eq[781] = IsEqual();
    eq[782] = IsEqual();
    eq[783] = IsEqual();
    eq[784] = IsEqual();
    eq[785] = IsEqual();
    eq[786] = IsEqual();
    eq[787] = IsEqual();
    eq[788] = IsEqual();
    eq[789] = IsEqual();
    eq[790] = IsEqual();
    eq[791] = IsEqual();
    eq[792] = IsEqual();
    eq[793] = IsEqual();
    eq[794] = IsEqual();
    eq[795] = IsEqual();
    eq[796] = IsEqual();
    eq[797] = IsEqual();
    eq[798] = IsEqual();
    eq[799] = IsEqual();
    eq[800] = IsEqual();
    eq[801] = IsEqual();
    eq[802] = IsEqual();
    eq[803] = IsEqual();
    eq[804] = IsEqual();
    eq[805] = IsEqual();
    eq[806] = IsEqual();
    eq[807] = IsEqual();
    eq[808] = IsEqual();
    eq[809] = IsEqual();
    eq[810] = IsEqual();
    eq[811] = IsEqual();
    eq[812] = IsEqual();
    eq[813] = IsEqual();
    eq[814] = IsEqual();
    eq[815] = IsEqual();
    eq[816] = IsEqual();
    eq[817] = IsEqual();
    eq[818] = IsEqual();
    eq[819] = IsEqual();
    eq[820] = IsEqual();
    eq[821] = IsEqual();
    eq[822] = IsEqual();
    eq[823] = IsEqual();
    eq[824] = IsEqual();
    eq[825] = IsEqual();
    eq[826] = IsEqual();
    eq[827] = IsEqual();
    eq[828] = IsEqual();
    eq[829] = IsEqual();
    eq[830] = IsEqual();
    eq[831] = IsEqual();
    eq[832] = IsEqual();
    eq[833] = IsEqual();
    eq[834] = IsEqual();
    eq[835] = IsEqual();
    eq[836] = IsEqual();
    eq[837] = IsEqual();
    eq[838] = IsEqual();
    eq[839] = IsEqual();
    eq[840] = IsEqual();
    eq[841] = IsEqual();
    eq[842] = IsEqual();
    eq[843] = IsEqual();
    eq[844] = IsEqual();
    eq[845] = IsEqual();
    eq[846] = IsEqual();
    eq[847] = IsEqual();
    eq[848] = IsEqual();
    eq[849] = IsEqual();
    eq[850] = IsEqual();
    eq[851] = IsEqual();
    eq[852] = IsEqual();
    eq[853] = IsEqual();
    eq[854] = IsEqual();
    eq[855] = IsEqual();
    eq[856] = IsEqual();
    eq[857] = IsEqual();
    eq[858] = IsEqual();
    eq[859] = IsEqual();
    eq[860] = IsEqual();
    eq[861] = IsEqual();
    eq[862] = IsEqual();
    eq[863] = IsEqual();
    eq[864] = IsEqual();
    eq[865] = IsEqual();
    eq[866] = IsEqual();
    eq[867] = IsEqual();
    eq[868] = IsEqual();
    eq[869] = IsEqual();
    eq[870] = IsEqual();
    eq[871] = IsEqual();
    eq[872] = IsEqual();
    eq[873] = IsEqual();
    eq[874] = IsEqual();
    eq[875] = IsEqual();
    eq[876] = IsEqual();
    eq[877] = IsEqual();
    eq[878] = IsEqual();
    eq[879] = IsEqual();
    eq[880] = IsEqual();
    eq[881] = IsEqual();
    eq[882] = IsEqual();
    eq[883] = IsEqual();
    eq[884] = IsEqual();
    eq[885] = IsEqual();
    eq[886] = IsEqual();
    eq[887] = IsEqual();
    eq[888] = IsEqual();
    eq[889] = IsEqual();
    eq[890] = IsEqual();
    eq[891] = IsEqual();
    eq[892] = IsEqual();
    eq[893] = IsEqual();
    eq[894] = IsEqual();
    eq[895] = IsEqual();
    eq[896] = IsEqual();
    eq[897] = IsEqual();
    eq[898] = IsEqual();
    eq[899] = IsEqual();
    eq[900] = IsEqual();
    eq[901] = IsEqual();
    eq[902] = IsEqual();
    eq[903] = IsEqual();
    eq[904] = IsEqual();
    eq[905] = IsEqual();
    eq[906] = IsEqual();
    eq[907] = IsEqual();
    eq[908] = IsEqual();
    eq[909] = IsEqual();
    eq[910] = IsEqual();
    eq[911] = IsEqual();
    eq[912] = IsEqual();
    eq[913] = IsEqual();
    eq[914] = IsEqual();
    eq[915] = IsEqual();
    eq[916] = IsEqual();
    eq[917] = IsEqual();
    eq[918] = IsEqual();
    eq[919] = IsEqual();
    eq[920] = IsEqual();
    eq[921] = IsEqual();
    eq[922] = IsEqual();
    eq[923] = IsEqual();
    eq[924] = IsEqual();
    eq[925] = IsEqual();
    eq[926] = IsEqual();
    eq[927] = IsEqual();
    eq[928] = IsEqual();
    eq[929] = IsEqual();
    eq[930] = IsEqual();
    eq[931] = IsEqual();
    eq[932] = IsEqual();
    eq[933] = IsEqual();
    eq[934] = IsEqual();
    eq[935] = IsEqual();
    eq[936] = IsEqual();
    eq[937] = IsEqual();
    eq[938] = IsEqual();
    eq[939] = IsEqual();
    eq[940] = IsEqual();
    eq[941] = IsEqual();
    eq[942] = IsEqual();
    eq[943] = IsEqual();
    eq[944] = IsEqual();
    eq[945] = IsEqual();

    var pairIdx = 0;
    for (var i = 0; i < 44; i++) {
        for (var j = i+1; j < 44; j++) {
            eq[pairIdx].in[0] <== privShipX[i] * 10 + privShipY[i];
            eq[pairIdx].in[1] <== privShipX[j] * 10 + privShipY[j];
            eq[pairIdx].out === 0;
            pairIdx++;
        }
    }

    component ship0 = ValidShip(10);
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
    ship0.X[6] <== privShipX[6];
    ship0.Y[6] <== privShipY[6];
    ship0.X[7] <== privShipX[7];
    ship0.Y[7] <== privShipY[7];
    ship0.X[8] <== privShipX[8];
    ship0.Y[8] <== privShipY[8];
    ship0.X[9] <== privShipX[9];
    ship0.Y[9] <== privShipY[9];

    component ship1 = ValidShip(10);
    ship1.X[0] <== privShipX[10];
    ship1.Y[0] <== privShipY[10];
    ship1.X[1] <== privShipX[11];
    ship1.Y[1] <== privShipY[11];
    ship1.X[2] <== privShipX[12];
    ship1.Y[2] <== privShipY[12];
    ship1.X[3] <== privShipX[13];
    ship1.Y[3] <== privShipY[13];
    ship1.X[4] <== privShipX[14];
    ship1.Y[4] <== privShipY[14];
    ship1.X[5] <== privShipX[15];
    ship1.Y[5] <== privShipY[15];
    ship1.X[6] <== privShipX[16];
    ship1.Y[6] <== privShipY[16];
    ship1.X[7] <== privShipX[17];
    ship1.Y[7] <== privShipY[17];
    ship1.X[8] <== privShipX[18];
    ship1.Y[8] <== privShipY[18];
    ship1.X[9] <== privShipX[19];
    ship1.Y[9] <== privShipY[19];

    component ship2 = ValidShip(10);
    ship2.X[0] <== privShipX[20];
    ship2.Y[0] <== privShipY[20];
    ship2.X[1] <== privShipX[21];
    ship2.Y[1] <== privShipY[21];
    ship2.X[2] <== privShipX[22];
    ship2.Y[2] <== privShipY[22];
    ship2.X[3] <== privShipX[23];
    ship2.Y[3] <== privShipY[23];
    ship2.X[4] <== privShipX[24];
    ship2.Y[4] <== privShipY[24];
    ship2.X[5] <== privShipX[25];
    ship2.Y[5] <== privShipY[25];
    ship2.X[6] <== privShipX[26];
    ship2.Y[6] <== privShipY[26];
    ship2.X[7] <== privShipX[27];
    ship2.Y[7] <== privShipY[27];
    ship2.X[8] <== privShipX[28];
    ship2.Y[8] <== privShipY[28];
    ship2.X[9] <== privShipX[29];
    ship2.Y[9] <== privShipY[29];

    component ship3 = ValidShip(10);
    ship3.X[0] <== privShipX[30];
    ship3.Y[0] <== privShipY[30];
    ship3.X[1] <== privShipX[31];
    ship3.Y[1] <== privShipY[31];
    ship3.X[2] <== privShipX[32];
    ship3.Y[2] <== privShipY[32];
    ship3.X[3] <== privShipX[33];
    ship3.Y[3] <== privShipY[33];
    ship3.X[4] <== privShipX[34];
    ship3.Y[4] <== privShipY[34];
    ship3.X[5] <== privShipX[35];
    ship3.Y[5] <== privShipY[35];
    ship3.X[6] <== privShipX[36];
    ship3.Y[6] <== privShipY[36];
    ship3.X[7] <== privShipX[37];
    ship3.Y[7] <== privShipY[37];
    ship3.X[8] <== privShipX[38];
    ship3.Y[8] <== privShipY[38];
    ship3.X[9] <== privShipX[39];
    ship3.Y[9] <== privShipY[39];

    component ship4 = ValidShip(4);
    ship4.X[0] <== privShipX[40];
    ship4.Y[0] <== privShipY[40];
    ship4.X[1] <== privShipX[41];
    ship4.Y[1] <== privShipY[41];
    ship4.X[2] <== privShipX[42];
    ship4.Y[2] <== privShipY[42];
    ship4.X[3] <== privShipX[43];
    ship4.Y[3] <== privShipY[43];

    signal nodes[7][64];
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
    nodes[0][32] <== leaves[32];
    nodes[0][33] <== leaves[33];
    nodes[0][34] <== leaves[34];
    nodes[0][35] <== leaves[35];
    nodes[0][36] <== leaves[36];
    nodes[0][37] <== leaves[37];
    nodes[0][38] <== leaves[38];
    nodes[0][39] <== leaves[39];
    nodes[0][40] <== leaves[40];
    nodes[0][41] <== leaves[41];
    nodes[0][42] <== leaves[42];
    nodes[0][43] <== leaves[43];
    nodes[0][44] <== leaves[44];
    nodes[0][45] <== leaves[45];
    nodes[0][46] <== leaves[46];
    nodes[0][47] <== leaves[47];
    nodes[0][48] <== leaves[48];
    nodes[0][49] <== leaves[49];
    nodes[0][50] <== leaves[50];
    nodes[0][51] <== leaves[51];
    nodes[0][52] <== leaves[52];
    nodes[0][53] <== leaves[53];
    nodes[0][54] <== leaves[54];
    nodes[0][55] <== leaves[55];
    nodes[0][56] <== leaves[56];
    nodes[0][57] <== leaves[57];
    nodes[0][58] <== leaves[58];
    nodes[0][59] <== leaves[59];
    nodes[0][60] <== leaves[60];
    nodes[0][61] <== leaves[61];
    nodes[0][62] <== leaves[62];
    nodes[0][63] <== leaves[63];

    component hasher[63];
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
    hasher[16].inputs[0] <== nodes[0][32];
    hasher[16].inputs[1] <== nodes[0][33];
    nodes[1][16] <== hasher[16].out;

    hasher[17] = Poseidon(2);
    hasher[17].inputs[0] <== nodes[0][34];
    hasher[17].inputs[1] <== nodes[0][35];
    nodes[1][17] <== hasher[17].out;

    hasher[18] = Poseidon(2);
    hasher[18].inputs[0] <== nodes[0][36];
    hasher[18].inputs[1] <== nodes[0][37];
    nodes[1][18] <== hasher[18].out;

    hasher[19] = Poseidon(2);
    hasher[19].inputs[0] <== nodes[0][38];
    hasher[19].inputs[1] <== nodes[0][39];
    nodes[1][19] <== hasher[19].out;

    hasher[20] = Poseidon(2);
    hasher[20].inputs[0] <== nodes[0][40];
    hasher[20].inputs[1] <== nodes[0][41];
    nodes[1][20] <== hasher[20].out;

    hasher[21] = Poseidon(2);
    hasher[21].inputs[0] <== nodes[0][42];
    hasher[21].inputs[1] <== nodes[0][43];
    nodes[1][21] <== hasher[21].out;

    hasher[22] = Poseidon(2);
    hasher[22].inputs[0] <== nodes[0][44];
    hasher[22].inputs[1] <== nodes[0][45];
    nodes[1][22] <== hasher[22].out;

    hasher[23] = Poseidon(2);
    hasher[23].inputs[0] <== nodes[0][46];
    hasher[23].inputs[1] <== nodes[0][47];
    nodes[1][23] <== hasher[23].out;

    hasher[24] = Poseidon(2);
    hasher[24].inputs[0] <== nodes[0][48];
    hasher[24].inputs[1] <== nodes[0][49];
    nodes[1][24] <== hasher[24].out;

    hasher[25] = Poseidon(2);
    hasher[25].inputs[0] <== nodes[0][50];
    hasher[25].inputs[1] <== nodes[0][51];
    nodes[1][25] <== hasher[25].out;

    hasher[26] = Poseidon(2);
    hasher[26].inputs[0] <== nodes[0][52];
    hasher[26].inputs[1] <== nodes[0][53];
    nodes[1][26] <== hasher[26].out;

    hasher[27] = Poseidon(2);
    hasher[27].inputs[0] <== nodes[0][54];
    hasher[27].inputs[1] <== nodes[0][55];
    nodes[1][27] <== hasher[27].out;

    hasher[28] = Poseidon(2);
    hasher[28].inputs[0] <== nodes[0][56];
    hasher[28].inputs[1] <== nodes[0][57];
    nodes[1][28] <== hasher[28].out;

    hasher[29] = Poseidon(2);
    hasher[29].inputs[0] <== nodes[0][58];
    hasher[29].inputs[1] <== nodes[0][59];
    nodes[1][29] <== hasher[29].out;

    hasher[30] = Poseidon(2);
    hasher[30].inputs[0] <== nodes[0][60];
    hasher[30].inputs[1] <== nodes[0][61];
    nodes[1][30] <== hasher[30].out;

    hasher[31] = Poseidon(2);
    hasher[31].inputs[0] <== nodes[0][62];
    hasher[31].inputs[1] <== nodes[0][63];
    nodes[1][31] <== hasher[31].out;

    hasher[32] = Poseidon(2);
    hasher[32].inputs[0] <== nodes[1][0];
    hasher[32].inputs[1] <== nodes[1][1];
    nodes[2][0] <== hasher[32].out;

    hasher[33] = Poseidon(2);
    hasher[33].inputs[0] <== nodes[1][2];
    hasher[33].inputs[1] <== nodes[1][3];
    nodes[2][1] <== hasher[33].out;

    hasher[34] = Poseidon(2);
    hasher[34].inputs[0] <== nodes[1][4];
    hasher[34].inputs[1] <== nodes[1][5];
    nodes[2][2] <== hasher[34].out;

    hasher[35] = Poseidon(2);
    hasher[35].inputs[0] <== nodes[1][6];
    hasher[35].inputs[1] <== nodes[1][7];
    nodes[2][3] <== hasher[35].out;

    hasher[36] = Poseidon(2);
    hasher[36].inputs[0] <== nodes[1][8];
    hasher[36].inputs[1] <== nodes[1][9];
    nodes[2][4] <== hasher[36].out;

    hasher[37] = Poseidon(2);
    hasher[37].inputs[0] <== nodes[1][10];
    hasher[37].inputs[1] <== nodes[1][11];
    nodes[2][5] <== hasher[37].out;

    hasher[38] = Poseidon(2);
    hasher[38].inputs[0] <== nodes[1][12];
    hasher[38].inputs[1] <== nodes[1][13];
    nodes[2][6] <== hasher[38].out;

    hasher[39] = Poseidon(2);
    hasher[39].inputs[0] <== nodes[1][14];
    hasher[39].inputs[1] <== nodes[1][15];
    nodes[2][7] <== hasher[39].out;

    hasher[40] = Poseidon(2);
    hasher[40].inputs[0] <== nodes[1][16];
    hasher[40].inputs[1] <== nodes[1][17];
    nodes[2][8] <== hasher[40].out;

    hasher[41] = Poseidon(2);
    hasher[41].inputs[0] <== nodes[1][18];
    hasher[41].inputs[1] <== nodes[1][19];
    nodes[2][9] <== hasher[41].out;

    hasher[42] = Poseidon(2);
    hasher[42].inputs[0] <== nodes[1][20];
    hasher[42].inputs[1] <== nodes[1][21];
    nodes[2][10] <== hasher[42].out;

    hasher[43] = Poseidon(2);
    hasher[43].inputs[0] <== nodes[1][22];
    hasher[43].inputs[1] <== nodes[1][23];
    nodes[2][11] <== hasher[43].out;

    hasher[44] = Poseidon(2);
    hasher[44].inputs[0] <== nodes[1][24];
    hasher[44].inputs[1] <== nodes[1][25];
    nodes[2][12] <== hasher[44].out;

    hasher[45] = Poseidon(2);
    hasher[45].inputs[0] <== nodes[1][26];
    hasher[45].inputs[1] <== nodes[1][27];
    nodes[2][13] <== hasher[45].out;

    hasher[46] = Poseidon(2);
    hasher[46].inputs[0] <== nodes[1][28];
    hasher[46].inputs[1] <== nodes[1][29];
    nodes[2][14] <== hasher[46].out;

    hasher[47] = Poseidon(2);
    hasher[47].inputs[0] <== nodes[1][30];
    hasher[47].inputs[1] <== nodes[1][31];
    nodes[2][15] <== hasher[47].out;

    hasher[48] = Poseidon(2);
    hasher[48].inputs[0] <== nodes[2][0];
    hasher[48].inputs[1] <== nodes[2][1];
    nodes[3][0] <== hasher[48].out;

    hasher[49] = Poseidon(2);
    hasher[49].inputs[0] <== nodes[2][2];
    hasher[49].inputs[1] <== nodes[2][3];
    nodes[3][1] <== hasher[49].out;

    hasher[50] = Poseidon(2);
    hasher[50].inputs[0] <== nodes[2][4];
    hasher[50].inputs[1] <== nodes[2][5];
    nodes[3][2] <== hasher[50].out;

    hasher[51] = Poseidon(2);
    hasher[51].inputs[0] <== nodes[2][6];
    hasher[51].inputs[1] <== nodes[2][7];
    nodes[3][3] <== hasher[51].out;

    hasher[52] = Poseidon(2);
    hasher[52].inputs[0] <== nodes[2][8];
    hasher[52].inputs[1] <== nodes[2][9];
    nodes[3][4] <== hasher[52].out;

    hasher[53] = Poseidon(2);
    hasher[53].inputs[0] <== nodes[2][10];
    hasher[53].inputs[1] <== nodes[2][11];
    nodes[3][5] <== hasher[53].out;

    hasher[54] = Poseidon(2);
    hasher[54].inputs[0] <== nodes[2][12];
    hasher[54].inputs[1] <== nodes[2][13];
    nodes[3][6] <== hasher[54].out;

    hasher[55] = Poseidon(2);
    hasher[55].inputs[0] <== nodes[2][14];
    hasher[55].inputs[1] <== nodes[2][15];
    nodes[3][7] <== hasher[55].out;

    hasher[56] = Poseidon(2);
    hasher[56].inputs[0] <== nodes[3][0];
    hasher[56].inputs[1] <== nodes[3][1];
    nodes[4][0] <== hasher[56].out;

    hasher[57] = Poseidon(2);
    hasher[57].inputs[0] <== nodes[3][2];
    hasher[57].inputs[1] <== nodes[3][3];
    nodes[4][1] <== hasher[57].out;

    hasher[58] = Poseidon(2);
    hasher[58].inputs[0] <== nodes[3][4];
    hasher[58].inputs[1] <== nodes[3][5];
    nodes[4][2] <== hasher[58].out;

    hasher[59] = Poseidon(2);
    hasher[59].inputs[0] <== nodes[3][6];
    hasher[59].inputs[1] <== nodes[3][7];
    nodes[4][3] <== hasher[59].out;

    hasher[60] = Poseidon(2);
    hasher[60].inputs[0] <== nodes[4][0];
    hasher[60].inputs[1] <== nodes[4][1];
    nodes[5][0] <== hasher[60].out;

    hasher[61] = Poseidon(2);
    hasher[61].inputs[0] <== nodes[4][2];
    hasher[61].inputs[1] <== nodes[4][3];
    nodes[5][1] <== hasher[61].out;

    hasher[62] = Poseidon(2);
    hasher[62].inputs[0] <== nodes[5][0];
    hasher[62].inputs[1] <== nodes[5][1];
    nodes[6][0] <== hasher[62].out;

    pubCommitment <== nodes[6][0];
}

component main = BoardSetup();