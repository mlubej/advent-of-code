# Advent of Code

This is my repo for collecting tasks for AoC.

I added a script that creates a directory for the task you're working on and loads a notebook from a template. The notebook already contains the basic structure and uses [aoc-data](https://github.com/wimglenn/advent-of-code-data) for importing the input data (check the link for instructions.)

The scripts assumes you have Visual Studio Code installed and the `code` CLI binding available.

### Requirements

First install all the reqirements from the `requirements.txt` file with

```bash
pip install -r requirements.txt
```

### Usage

Running the script without arguments prints out help:

```
Usage:  [OPTIONS]

Options:
  --year INTEGER  Year of Advend of Code event.
  --day INTEGER   Day of Advent of Code event.
  --help          Show this message and exit.
```

To start working on a task, simply run the following:

```bash
python aoc-setup.py --year 2021 --day 20

# you can even create an alias in your ~/.zshrc or ~/.bashrc
# alias aoc='python ~/path/to/repo/aoc-setup.py'
# and then do just
# aoc --year 2021 --day 20
```

This will create the following directory and files in the github repo and open VSCode in the appropriate location

```
.
└── advent-of-code
    └── 2021
        └── day-20
            └── task.ipynb
```
