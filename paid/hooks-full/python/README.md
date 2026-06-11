# Python Hooks

Formats Python files after every Write or Edit.

## What it runs
1. black: opinionated Python formatter
2. isort: sorts imports alphabetically by section

## Requirements
- black: `pip install black`
- isort: `pip install isort`

Both must be available in the PATH that Claude Code uses.

## Setup
Merge settings.json into ~/.claude/settings.json under "hooks".
