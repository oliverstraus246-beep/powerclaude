# TypeScript Hooks

Two hooks for TypeScript projects.

## Format on save (Prettier)

Runs Prettier on any .ts/.tsx/.js/.jsx file after a Write or Edit.

Requirements:
- Prettier installed in project: `npm install -D prettier`
- .prettierrc or prettier config in package.json

## Incremental type check

Runs TypeScript compiler in incremental mode after editing .ts/.tsx files.
- Uses --noEmit so it only type-checks, does not emit files
- Uses --incremental so unchanged files are not re-checked
- 60-second timeout to prevent hung tsc processes

Requirements:
- TypeScript installed: `npm install -D typescript`
- tsconfig.json in project root

## Setup

Merge this settings.json into your ~/.claude/settings.json under the "hooks" key.
The hooks use CLAUDE_TOOL_FILE env variable (set automatically by Claude Code).
