from glob import glob
import subprocess
import re
import numpy as np


def extract_time(day):
    out = subprocess.check_output(f"perl {day}/task.pl {day}/input.txt", shell=True).decode()
    return float(re.search("Elapsed time ([\d.]+)s", out).group(1))


print("# Advent of Code 2023")
print()
print("Solving in Perl.")
print("\n")


days = glob("./days/day-*")
total_time = 0
total_error_sq = 0
for idx, day in enumerate(days):
    times = [extract_time(day) for _ in range(20)]
    mean, std = np.mean(times), np.std(times)
    total_time += mean
    total_error_sq += std**2
    print(f"Day {idx+1} Execution Time: {mean:.2e}s ± {std:.2e}s")

print("-------------")
print(f"Total Execution Time: {total_time:.2e}s ± {(total_error_sq**0.5):.2e}s")
