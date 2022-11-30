"""
- accepts year and day
- creates a directory
- creates a notebook with some template
- download input data (example: https://adventofcode.com/2022/day/1/input)
"""

import os
import re
import subprocess

import click

AOC_PATH, _ = os.path.split(os.path.realpath(__file__))
URL_BASE = "https://adventofcode.com/"


@click.command()
@click.option("--year", type=int, help="Year of Advend of Code event.")
@click.option("--day", type=int, help="Day of Advent of Code event.")
def main(year, day):
    if year is None or day is None:
        with click.Context(main) as ctx:
            click.echo(ctx.get_help())
        return

    # create directory
    path = os.path.join(AOC_PATH, str(year), f"day-{day:02d}")
    os.makedirs(path, exist_ok=True)

    # create templated notebook
    notebook_content = open(os.path.join(AOC_PATH, "notebook_template.ipynb"), "r").read()
    notebook_content = re.sub(r"<DAY>", str(day), notebook_content)
    notebook_content = re.sub(r"<YEAR>", str(year), notebook_content)

    # save notebook
    with open(os.path.join(path, "task.ipynb"), "w") as fp:
        fp.write(notebook_content)

    # open notebook
    subprocess.run(f'code {os.path.join(AOC_PATH, "advent-of-code.code-workspace")}', shell=True)
    subprocess.run(f'code {os.path.join(path, "task.ipynb")}', shell=True)


if __name__ == "__main__":
    main()
