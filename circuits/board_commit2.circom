pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";

// Helper Template: Proves a ship of length L is a straight, unbroken line
template ValidShip(L) {
    signal input X[L];
    signal input Y[L];

    component isYEq[L-1];
    component isXInc[L-1];
    signal isHorizontal[L];
    signal horizStep[L-1]; // Intermediate signal for horizontal
    isHorizontal[0] <== 1;

    component isXEq[L-1];
    component isYInc[L-1];
    signal isVertical[L];
    signal vertStep[L-1]; // Intermediate signal for vertical
    isVertical[0] <== 1;

    for (var i = 0; i < L - 1; i++) {
        // --- Check Horizontal Path (Y stays same, X increments by 1) ---
        isYEq[i] = IsEqual();
        isYEq[i].in[0] <== Y[i];
        isYEq[i].in[1] <== Y[i+1];

        isXInc[i] = IsEqual();
        isXInc[i].in[0] <== X[i] + 1;
        isXInc[i].in[1] <== X[i+1];

        // FIX: Break A * B * C into two quadratic constraints
        horizStep[i] <== isYEq[i].out * isXInc[i].out;
        isHorizontal[i+1] <== isHorizontal[i] * horizStep[i];

        // --- Check Vertical Path (X stays same, Y increments by 1) ---
        isXEq[i] = IsEqual();
        isXEq[i].in[0] <== X[i];
        isXEq[i].in[1] <== X[i+1];

        isYInc[i] = IsEqual();
        isYInc[i].in[0] <== Y[i] + 1;
        isYInc[i].in[1] <== Y[i+1];

        // FIX: Break A * B * C into two quadratic constraints
        vertStep[i] <== isXEq[i].out * isYInc[i].out;
        isVertical[i+1] <== isVertical[i] * vertStep[i];
    }

    // The ship MUST be either fully horizontal OR fully vertical.
    isHorizontal[L-1] + isVertical[L-1] === 1;
}

// Main Setup Template
template BoardSetup() {
    // 3 ships (1x2, 1x2, 1x3) means 7 total occupied coordinates
    var N = 7; 

    // Private inputs: the player's flat array of coordinates
    signal input privShipX[N];        
    signal input privShipY[N];        
    signal input privSalt;   

    // Public output: the locked-in board hash
    signal output pubCommitment;

    // ---------------------------------------------------------
    // 1. BOUNDS CHECK (Must be between 0 and 9)
    // ---------------------------------------------------------
    component lessX[N];
    component lessY[N];

    for (var i = 0; i < N; i++) {
        lessX[i] = LessThan(4); 
        lessX[i].in[0] <== privShipX[i];
        lessX[i].in[1] <== 10;
        lessX[i].out === 1; // Assert X < 10

        lessY[i] = LessThan(4);
        lessY[i].in[0] <== privShipY[i];
        lessY[i].in[1] <== 10;
        lessY[i].out === 1; // Assert Y < 10
    }

    // ---------------------------------------------------------
    // 2. OVERLAP CHECK (No two cells can be the same)
    // ---------------------------------------------------------
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

            // If X matches AND Y matches, they overlap. 
            eqX[i][j].out * eqY[i][j].out === 0;
        }
    }

    // ---------------------------------------------------------
    // 3. CONTIGUITY CHECK (Wiring specific indices to ships)
    // ---------------------------------------------------------
    // Ship 1: 1x2 (Indices 0, 1)
    component ship1 = ValidShip(2);
    for (var i = 0; i < 2; i++) {
        ship1.X[i] <== privShipX[i];
        ship1.Y[i] <== privShipY[i];
    }

    // Ship 2: 1x2 (Indices 2, 3)
    component ship2 = ValidShip(2);
    for (var i = 0; i < 2; i++) {
        ship2.X[i] <== privShipX[i + 2];
        ship2.Y[i] <== privShipY[i + 2];
    }

    // Ship 3: 1x3 (Indices 4, 5, 6)
    component ship3 = ValidShip(3);
    for (var i = 0; i < 3; i++) {
        ship3.X[i] <== privShipX[i + 4];
        ship3.Y[i] <== privShipY[i + 4];
    }

    // ---------------------------------------------------------
    // 4. COMMITMENT GENERATION
    // ---------------------------------------------------------
    // 7 X's + 7 Y's + 1 Salt = 15 Inputs. Single Poseidon works perfectly.
    component hasher = Poseidon(15);
    
    for (var i = 0; i < N; i++) {
        hasher.inputs[i] <== privShipX[i];
        hasher.inputs[i + N] <== privShipY[i];
    }
    hasher.inputs[2 * N] <== privSalt;  
    
    pubCommitment <== hasher.out;
}

component main = BoardSetup();

/* INPUT = {
    "privShipX": ["0", "1", "3", "4", "6", "7", "8"], 
    "privShipY": ["5", "5", "5", "5", "5", "5", "5"],
    "privSalt": "3"
} */

//    "pubCommitment": "7497406861119332796509135565682586407117661626840105767385372856208068397085",