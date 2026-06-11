# Model Routing

Running every Claude Code task on Sonnet is like using a sledgehammer for a thumbtack. The model routing system routes cheap tasks to cheap models, saving credits for tasks that actually need Sonnet.

## The principle

Not all tasks require the same intelligence. Summarizing a file, explaining a snippet, generating a regex - these are low-complexity tasks that Gemini Flash handles at near-Sonnet quality for a fraction of the cost. Reserve Sonnet for what it is actually good at: multi-file code changes, complex debugging, architecture.

## Setup

### Step 1: Install the llm CLI

```bash
pip install llm
```

### Step 2: Add your Gemini API key

Get a free key at https://aistudio.google.com/apikey

```bash
# Set in api-keys.json AND as environment variable
llm keys set gemini
# Enter your API key when prompted
```

### Step 3: Add the key to api-keys.json

Edit `~/.claude/api-keys.json` and fill in your GEMINI_API_KEY.

### Step 4: Add to your CLAUDE.md

The routing rules in CLAUDE.md tell Claude which tasks go to which model. The template includes a starter routing table. Customize it for your workflow.

## Decision matrix

| Task | Model | Why |
|------|-------|-----|
| Summarize a file | Gemini 2.5 Flash | 90% quality, 10% cost |
| Explain a code snippet | Gemini 2.5 Flash | Well within its capability |
| Generate a regex | Gemini 2.5 Flash | Pattern generation is cheap |
| Write tests for simple code | Gemini 2.5 Flash | Straightforward generation |
| Draft vault notes | Gemini 2.5 Flash | Known topic, structured output |
| Codebase Q&A | graphify query | No model needed - graph traversal |
| Multi-file code changes | Claude Sonnet | Complex reasoning required |
| Debugging across files | Claude Sonnet | After graphify query fails |
| Architecture decisions | Claude Sonnet | Tradeoff analysis needed |
| Novel unsolved problems | Claude Opus | Only if Sonnet fails twice |

## Usage patterns

```bash
# Summarize any file
llm -m gemini-2.5-flash "summarize this" < file.txt

# Explain a snippet
cat snippet.ts | llm -m gemini-2.5-flash "explain what this does"

# Generate a regex
llm -m gemini-2.5-flash "write a regex that matches email addresses with +aliases"

# Quick data transform
cat data.json | llm -m gemini-2.5-flash "convert this JSON array to a CSV"
```

## Available models (as of 2025)

| Alias | Model | Notes |
|-------|-------|-------|
| gemini-2.5-flash | Gemini 2.5 Flash | Primary cheap model. Fast, accurate. |
| gemini/gemini-2.0-flash | Gemini 2.0 Flash | Fallback if 2.5 Flash is unavailable |
| claude-haiku-4-5 | Claude Haiku | Low-cost Claude option. Better code than Gemini. |
| claude-sonnet-4-6 | Claude Sonnet | Default Claude Code model. Full capability. |
| claude-opus-4-8 | Claude Opus | Maximum reasoning. Use sparingly. |

## Cost context

Approximate relative costs (normalized to Sonnet = 10x):
- Gemini Flash: 1x
- Claude Haiku: 2x
- Claude Sonnet: 10x
- Claude Opus: 60x

On a 100-task session, routing 60% of tasks to Gemini Flash cuts the session cost by ~50%.
