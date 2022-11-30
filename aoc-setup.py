import os
import re
import subprocess
import sys

import click

AOC_PATH, _ = os.path.split(os.path.realpath(__file__))
URL_BASE = "https://adventofcode.com"


@click.command()
@click.option("--year", type=str, help="Year of Advend of Code event.")
@click.option("--day", type=str, help="Day of Advent of Code event.")
def main(year, day):
    if year is None or day is None:
        with click.Context(main) as ctx:
            click.echo(ctx.get_help())
        return

    # create directory
    path = os.path.join(AOC_PATH, year, f"day-{int(day):02d}")
    os.makedirs(path, exist_ok=True)

    # create templated notebook
    notebook_content = open(os.path.join(AOC_PATH, "notebook_template.ipynb"), "r").read()
    notebook_content = re.sub(r"<DAY>", day, notebook_content)
    notebook_content = re.sub(r"<YEAR>", year, notebook_content)

    # save notebook
    with open(os.path.join(path, "task.ipynb"), "w") as fp:
        fp.write(notebook_content)

    # open notebook
    subprocess.run(f"code {AOC_PATH}", shell=True)
    subprocess.run(f'code {os.path.join(path, "task.ipynb")}', shell=True)

    # open task
    tool = "xdg-open" if sys.platform == "linux" else "open"
    subprocess.run(f"{tool} {URL_BASE}/{year}/day/{day}", shell=True)


if __name__ == "__main__":
    main()
