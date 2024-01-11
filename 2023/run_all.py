import os
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
print("- `Math::Cartesian::Product`")
print("- `Math::Matrix`")
print("- `Math::BigFloat`")
print("- `Algorithm::GaussianElimination::GF2`")
print("- `List::MoreUtils`")
print("- `Memoize`")

print()
print("### Timing")

print("\n|Day|Execution Time|")
print("|-|-|")
total_time = 0
total_error_sq = 0
for idx, day in enumerate(sorted(glob("./days/day-*"))):
    if not os.path.exists(f"{day}/task.pl"):
        continue

    time = extract_time(day)
    total_time += time
    print(f"|Day {idx+1}  | ~{time:.4e}s|")

print(f"|**Total** | **~{total_time:.4e}s **|")
