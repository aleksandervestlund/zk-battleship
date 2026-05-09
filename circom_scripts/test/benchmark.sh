#!/bin/bash

# Define the output file for the results
OUTPUT_FILE="proving_times2.txt"

if [ ! -f "pot_final.ptau" ]; then
    echo "Downloading Powers of Tau..."
    wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_16.ptau -O pot_final.ptau
fi

> "$OUTPUT_FILE"
echo "Starting strict numerical compilation (Index 2 to 100, with 20x Proof Averaging)..."

# Define how many times we want to run the proof per circuit
RUNS=100

for ((idx=2; idx<=100; idx++)); do
    
    circuit="autogen_circuit${idx}.circom"
    name="autogen_circuit${idx}"
    input_file="circuit_${idx}_input.json"
    
    if [ ! -f "$circuit" ]; then
        echo "⚠️ SKIPPED: $circuit does not exist"
        continue
    fi
    
    echo "-----------------------------------"
    echo "⚙️ Processing: $name (Index: $idx)"
    
    # Notice I added '> /dev/null 2>&1' here to fully silence circom unless it fails
    if ! circom "$circuit" --r1cs --wasm -l node_modules > /dev/null 2>&1; then
        echo "❌ COMPILATION FAILED: Skipping $name"
        echo "$name: Skipped (Compilation Failed)" >> "$OUTPUT_FILE"
        continue 
    fi
    
    echo "🔑 Generating dummy ZKEY..."
    snarkjs groth16 setup "${name}.r1cs" pot_final.ptau "${name}_dummy.zkey" > /dev/null
    
    if [ ! -f "$input_file" ]; then
        echo "⚠️ SKIPPED: Missing $input_file"
        echo "$name: Skipped (Missing Input)" >> "$OUTPUT_FILE"
        continue
    fi
    
    echo "🧮 Generating Witness..."
    node "${name}_js/generate_witness.js" "${name}_js/${name}.wasm" "$input_file" "${name}.wtns" > /dev/null
    
    echo -n "⏱️ Proving $RUNS times: "
    total_time_ns=0
    
    # INNER LOOP: Run the proof RUNS times and calculate total nanoseconds
    for ((i=1; i<=RUNS; i++)); do
        start=$(date +%s%N)
        snarkjs groth16 prove "${name}_dummy.zkey" "${name}.wtns" "${name}_proof.json" "${name}_public.json" > /dev/null
        end=$(date +%s%N)
        
        duration=$((end - start))
        total_time_ns=$((total_time_ns + duration))
        
        # Print a tiny dot so you know it hasn't frozen during the runs
        echo -n "." 
    done
    echo "" # Print a new line after the dots
    
    # Calculate the average (mean) in seconds using awk, rounded to 4 decimal places
    mean_sec=$(echo | awk "{ printf \"%.4f\", ($total_time_ns / $RUNS) / 1000000000 }")
    
    echo "✅ Finished $name - Mean Time: ${mean_sec}s"
    
    # Save JUST the mean to the text file
    echo "$name: ${mean_sec}s (Mean of $RUNS runs)" >> "$OUTPUT_FILE"

done

echo "-----------------------------------"
echo "🎉 All done! Open '$OUTPUT_FILE' to see the average results."
