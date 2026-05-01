pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";

// N is the total number of coordinates occupied by all ships combined
template BattleshipHit(N) {

    // public inputs
    signal input pubGuessX;        
    signal input pubGuessY;        
    signal input pubCommitment;    
    signal input pubReportedHit;   // 1 (Hit) or 0 (Miss)

    // private inputs (Arrays of length N)
    signal input privShipX[N];        
    signal input privShipY[N];        
    signal input privSalt;   

    // 1. Prove they didn't alter the board
    // We hash all X coordinates, all Y coordinates, and the salt.
    component hasher = Poseidon(2 * N + 1);
    for (var i = 0; i < N; i++) {
        hasher.inputs[i] <== privShipX[i];
        hasher.inputs[i + N] <== privShipY[i];
    }
    hasher.inputs[2 * N] <== privSalt;  
    pubCommitment === hasher.out; 
    
    // 2. Check if the guess hits ANY of the coordinates
    component eqX[N];
    component eqY[N];
    signal hitMatch[N];
    
    // In Circom, signals cannot be reassigned (no `sum += x`). 
    // We must use an array to accumulate the total hits.
    signal hitAccumulator[N + 1];
    hitAccumulator[0] <== 0;

    for (var i = 0; i < N; i++) {
        // Check if X matches
        eqX[i] = IsEqual();
        eqX[i].in[0] <== pubGuessX;
        eqX[i].in[1] <== privShipX[i];

        // Check if Y matches
        eqY[i] = IsEqual();
        eqY[i].in[0] <== pubGuessY;
        eqY[i].in[1] <== privShipY[i];

        // 1 if this specific cell is a hit, 0 otherwise
        hitMatch[i] <== eqX[i].out * eqY[i].out;
        
        // Add current match to the running total
        hitAccumulator[i + 1] <== hitAccumulator[i] + hitMatch[i];
    }

    // Since a valid board has no overlapping ships, 
    // hitAccumulator[N] will be exactly 1 (if hit) or 0 (if miss).
    pubReportedHit === hitAccumulator[N];
}

// Example: A game with 3 total occupied ship cells
component main {public [pubGuessX, pubGuessY, pubCommitment, pubReportedHit]} = BattleshipHit(7);

/* INPUT = {
    "pubGuessX": "4",
    "pubGuessY": "5",
    "pubCommitment": "7497406861119332796509135565682586407117661626840105767385372856208068397085",
    "pubReportedHit": "1",
    "privShipX": ["0", "1", "3", "4", "6", "7", "8"], 
    "privShipY": ["5", "5", "5", "5", "5", "5", "5"],
    "privSalt": "3"
} */