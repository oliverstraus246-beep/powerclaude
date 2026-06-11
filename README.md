# You're running Claude Code at 20% capacity.

The other 80% is memory, skill routing, multi-window specialization, hook automation, and model cost control. None of it ships by default. This repo wires it all up.

---

## Before â†’ After

| Stock Claude Code | PowerClaude |
|---|---|
| No memory between sessions | Vault loads your projects, decisions, and patterns at every session start |
| Re-explaining your stack every conversation | CLAUDE.md carries your full context â€” stack, rules, key paths, active projects |
| Claude improvises every task | 120+ skills auto-invoke based on what you're doing â€” no slash commands, no prompting |
| One window doing everything | 11 specialized windows: planning, debugging, code review, UI, infra, each expert at one job |
| Every task runs on Sonnet | Model routing: summarize a file â†’ Gemini Flash. Real code changes â†’ Sonnet. Architecture â†’ Opus. |
| Raw code ships as-written | Hook system: format on save, type check on edit, vault logging on completion, build verify on stop |
| You copy-paste API keys from memory | Centralized key store â€” every project pulls from one place |

---

## What You Get â€” Free

Install the foundation in under 2 minutes.

- **Setup script** (PowerShell + bash) â€” creates vault structure, installs CLAUDE.md, wires hooks
- **CLAUDE.md starter template** â€” fully documented, every section explained, ready to customize
- **Window prompt templates** â€” planning window, debug window, code review window, general window
- **Hook boilerplate** â€” format on save, incremental type check, vault logging patterns
- **Model routing guide** â€” decision matrix: which task goes to which model, why, and how to wire it
- **API key management pattern** â€” single JSON store, referenced by every project

---

## What You Get â€” Paid ($25)

The free tier is a skeleton. The paid tier is the conversation that builds your actual system.

Most setups fail because they're generic. A CLAUDE.md written for someone else's stack doesn't help you. The paid tier includes a **Personalization Engine** â€” a structured prompt you paste into Claude Code. It asks 7 questions about your projects, stack, workflows, and preferences. In return, it outputs a complete, configured environment built around how you actually work.

- **Personalization Engine** â€” answer 7 questions, get a fully generated CLAUDE.md, vault structure, and hook config tuned to your projects
- **Full advanced CLAUDE.md** â€” complete proactive behaviors, full model routing logic, the entire skill auto-invoke library (every trigger condition documented)
- **Complete window prompt library** â€” all 11 specialized windows, production-grade: Planning, Debug, Code Review, UI/Design, Infrastructure, Research, Prompt Engineering, Refactor, Briefing, Security, Handoff
- **Full hook library** â€” pre/post hooks for TypeScript, Python, React, Node; vault-logging hooks that capture decisions and patterns automatically
- **Graphify + GitNexus integration guide** â€” semantic codebase navigation: query your codebase like a database instead of reading files
- **Lifetime updates** â€” every improvement to the system lands in your repo

---

## How It Works â€” 3 Steps

**Windows:**
```powershell
irm https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/install.ps1 | iex
```

**Mac / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/install.sh | bash
```

The script:
1. Creates the vault directory structure under your home folder
2. Installs a CLAUDE.md starter into `~/.claude/`
3. Wires the baseline hooks into `~/.claude/settings.json`

Then open Claude Code. The vault loads automatically.

---

## Why This Exists

I've been running Claude Code daily for months. The gap between a stock install and a tuned one isn't small â€” it's the difference between a capable assistant and a system that knows your codebase, remembers what you decided last Tuesday, routes cheap tasks away from expensive models, and automatically invokes the right behavior for whatever you're doing.

That setup took a long time to build. This repo packages it so you don't have to.

---

## Get the Full Setup

â†’ **[Buy the Personalization Engine â€” $25](https://gumroad.com/l/powerclaude)**

One-time. Lifetime updates. If it doesn't save you more than 2 hours in your first week, you don't need it.

---

## FAQ

**Do I need to know how skills work?**  
No. The whole point is they fire automatically. You write `useEffect` and the React skill activates. You see an error and the debugging skill kicks in. You don't manage it.

**Does this work on Windows?**  
Yes. The install script, vault system, and all hook patterns are tested on Windows (PowerShell) and Mac/Linux (bash).

**What if I already have a CLAUDE.md?**  
The installer backs it up to `CLAUDE.md.backup` before installing the template. Nothing gets overwritten without a safety copy.

**Is the paid tier a one-time purchase?**  
Yes. No subscription. Updates ship to the same Gumroad product.

**What's the difference between the free template and the paid advanced CLAUDE.md?**  
The free template has every section with instructions and examples. The paid version is the full, production-grade file with every auto-invoke rule, every skill trigger, the complete model routing matrix, and vault conventions â€” the exact architecture that runs daily in a production setup.

---

## Contributing

Issues and PRs welcome. If you've built a hook, skill trigger pattern, or window prompt that works well â€” open a PR. The goal is the best possible default setup, not a showcase of one person's config.

---

*Built on [Claude Code](https://claude.ai/code) by Anthropic.*  
*MIT License â€” free tier. Paid tier files are proprietary.*

