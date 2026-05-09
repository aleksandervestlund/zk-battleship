import matplotlib.pyplot as plt
import re
import sys

indices = []
times = []

# Read data from the external file
file_path = 'proving_times.txt'

try:
    with open(file_path, 'r') as file:
        for line in file:
            # Uses regex to find the circuit index and the time in seconds
            match = re.search(r'autogen_circuit(\d+):\s+([\d\.]+)s', line)
            if match:
                indices.append(int(match.group(1)))
                times.append(float(match.group(2)))
except FileNotFoundError:
    print(f"Error: The file '{file_path}' was not found.")
    sys.exit(1)

# Ensure data was actually extracted before doing math
if not times:
    print("Error: No valid circuit data found in the file.")
    sys.exit(1)

# Calculate the overall average across all circuits
overall_mean = sum(times) / len(times)

# 1. Create the figure
plt.figure(figsize=(12, 6))

# 2. Plot the data as a line chart with dots for each circuit
plt.plot(indices, times, marker='o', linestyle='-', color='b', alpha=0.7, label='Mean Proving Time (100 runs)')

# 3. Add a horizontal line representing the overall average
plt.axhline(y=overall_mean, color='r', linestyle='--', label=f'Overall Average ({overall_mean:.4f}s)')

# 4. Format the chart labels and title
plt.title('Groth16 Proving Time per Circuit', fontsize=16)
plt.xlabel('Circuit Index', fontsize=12)
plt.ylabel('Proving Time (Seconds)', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()

# 5. Automatically adjust x-axis ticks to make it readable
# Note: If your file has more than 100 circuits, you might want to dynamically adjust the range
max_index = max(indices) if indices else 100
plt.xticks(range(0, max_index + 1, 5))

# 6. Show the graph in a window
plt.tight_layout()
plt.show()
