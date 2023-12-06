import re
import subprocess
from glob import glob

import numpy as np


def extract_time(day):
    out = subprocess.check_output(f"perl {day}/task.pl {day}/input.txt", shell=True).decode()
    return float(re.search("Elapsed time ([\d.]+)s", out).group(1))


print("# Advent of Code 2023")
print()
print("Solving in Perl.")
print()
print("### Requirements")
print("- `String::Util`")
print("- `Test::Assertions`")

print()
print("### Timing")

print("\n|Day|Execution Time|")
print("|-|-|")
total_time = 0
total_error_sq = 0
for idx, day in enumerate(sorted(glob("./days/day-*"))):
    times = [extract_time(day) for _ in range(5)]
    mean, std = np.mean(times), np.std(times)
    total_time += mean
    total_error_sq += std**2
    print(f"|Day {idx+1}  | {mean:.4e}s ± {std:.4e}s|")

print(f"|**Total** | **{total_time:.4e}s ± {(total_error_sq**0.5):.4e}s**|")
