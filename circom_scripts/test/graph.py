import re
import sys

import matplotlib.pyplot as plt

indices: list[int] = []
times: list[float] = []
FILE_PATH = "proving_times2.txt"

try:
    with open(FILE_PATH, "r", encoding="utf-8") as file:
        for line in file:
            if match := re.search(r"autogen_circuit(\d+):\s+([\d\.]+)s", line):
                indices.append(int(match.group(1)))
                times.append(float(match.group(2)))
except FileNotFoundError:
    print(f"Error: The file {FILE_PATH!r} was not found.")
    sys.exit(1)

if not times:
    print("Error: No valid circuit data found in the file.")
    sys.exit(1)

overall_mean = sum(times) / len(times)

plt.figure(figsize=(12, 6))
plt.plot(
    indices,
    times,
    marker="o",
    linestyle="-",
    color="b",
    alpha=0.7,
    label="Mean Proving Time (100 runs)",
)
plt.axhline(
    y=overall_mean,
    color="r",
    linestyle="--",
    label=f"Overall Average ({overall_mean:.4f}s)",
)
plt.title("Groth16 Proving Time per Circuit", fontsize=16)
plt.xlabel("Number of Ship Coordinates", fontsize=12)
plt.ylabel("Proving Time (Seconds)", fontsize=12)
plt.grid(True, linestyle="--", alpha=0.6)
plt.legend()

MAX_IDX = max(indices) if indices else 100
plt.xticks(range(0, MAX_IDX + 1, 5))

plt.tight_layout()
plt.show()
