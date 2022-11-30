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

To start working on a task, simply run the following:

```bash
python aoc-setup.py --year 2021 --day 20
```

This will create the following directory and files in the github repo

```
.
└── advent-of-code
    └── 2021
        └── day-20
            └── task.ipynb
```