# You're running Claude Code at 20% capacity.

The other 80% is memory, skill routing, multi-window specialization, hook automation, and model cost control. None of it ships by default. This repo wires it all up.

---

## Before vs. After

| Stock Claude Code | PowerClaude |
|---|---|
| No memory between sessions | Vault loads your projects, decisions, and patterns at every session start |
| Re-explaining your stack every conversation | CLAUDE.md carries your full context -- stack, rules, key paths, active projects |
| Claude improvises every task | 120+ skills auto-invoke based on what you're doing -- no slash commands, no prompting |
| One window doing everything | 11 specialized windows: planning, debugging, code review, UI, infra, each expert at one job |
| Every task runs on Sonnet | Model routing: summarize a file -> Gemini Flash. Real code changes -> Sonnet. Architecture -> Opus. |
| Raw code ships as-written | Hook system: format on save, type check on edit, vault logging on completion, build verify on stop |
| You copy-paste API keys from memory | Centralized key store -- every project pulls from one place |

---

## What You Get -- Free

Install the foundation in under 2 minutes.

- **Setup script** (PowerShell + bash) -- creates vault structure, installs CLAUDE.md, wires hooks
- **CLAUDE.md starter template** -- fully documented, every section explained, ready to customize
- **Window prompt templates** -- planning window, debug window, code review window, general window
- **Hook boilerplate** -- format on save, incremental type check, vault logging patterns
- **Model routing guide** -- decision matrix: which task goes to which model, why, and how to wire it
- **API key management pattern** -- single JSON store, referenced by every project

---

## What You Get -- Paid ($25)

The free tier is a skeleton. The paid tier is the conversation that builds your actual system.

Most setups fail because they're generic. A CLAUDE.md written for someone else's stack doesn't help you. The paid tier includes a **Personalization Engine** -- a structured prompt you paste into Claude Code. It asks 13 questions about your projects, stack, workflows, preferences, and working style. In return, it outputs a complete, configured environment built around how you actually work.

- **Personalization Engine** -- answer 13 questions, get a fully generated CLAUDE.md, vault structure, and hook config built around how you actually work
- **Full advanced CLAUDE.md** -- complete proactive behaviors, full model routing logic, the entire skill auto-invoke library (every trigger condition documented)
- **Complete window prompt library** -- all 11 specialized windows, production-grade: Planning, Debug, Code Review, UI/Design, Infrastructure, Research, Prompt Engineering, Refactor, Briefing, Security, Handoff
- **Full hook library** -- pre/post hooks for TypeScript, Python, React, Node; vault-logging hooks that capture decisions and patterns automatically
- **Graphify + GitNexus integration guide** -- semantic codebase navigation: query your codebase like a database instead of reading files
- **Lifetime updates** -- every improvement to the system lands in your repo

---

## Install

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
2. Installs `CLAUDE.md.template` into `~/.claude/`
3. Wires the baseline hooks into `~/.claude/settings.json`

Then open Claude Code. The vault loads automatically on every session start.

After installing, run the validator to confirm everything is wired correctly:
```bash
node ~/.claude/validate.js
```

---

## Personalize in 5 Minutes (Free Tier)

After install, three files need your actual info:

**1. `~/.claude/CLAUDE.md`** (copy from the template)
```powershell
Copy-Item ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md
```
Open it and fill in every `[PLACEHOLDER]` section. The template has inline instructions for each one.

**2. `~/.claude/hooks/user-prompt-submit.js`**
Fill in your `ACTIVE_PROJECTS` array -- name, path, and stack for each project you're actively working on. This injects your project context at the start of every conversation.

**3. `~/.claude/api-keys.json`**
Add your Gemini API key (free at [aistudio.google.com](https://aistudio.google.com/apikey)) to unlock cheap model routing. Without it, everything runs on Sonnet.

That's it. Everything else auto-loads from your vault.

---

## Why This Exists

I've been running Claude Code daily for months. The gap between a stock install and a tuned one isn't small -- it's the difference between a capable assistant and a system that knows your codebase, remembers what you decided last Tuesday, routes cheap tasks away from expensive models, and automatically invokes the right behavior for whatever you're doing.

That setup took a long time to build. This repo packages it so you don't have to.

---

## Get the Full Setup

**$25 one-time. Lifetime updates.**

Text or CashApp to get access:
- CashApp: **$oliverstraus**
- Text: **303-946-4224**

Send $25 and your GitHub username. I'll add you to the private repo within a few hours.

Not sure if it's worth it for your setup? Text me first -- 303-946-4224. I'll tell you straight.

---

## FAQ

**Do I need to know how skills work?**
No. The whole point is they fire automatically. You write `useEffect` and the React skill activates. You see an error and the debugging skill kicks in. You don't manage it.

**Does this work on Windows?**
Yes. The install script, vault system, and all hook patterns are tested on Windows (PowerShell) and Mac/Linux (bash).

**What if I already have a CLAUDE.md?**
The installer backs it up to `CLAUDE.md.backup` before installing the template. Nothing gets overwritten without a safety copy.

**How does the paid tier work?**
You pay once ($25), send your GitHub username, and get added as a collaborator on the private repo. No subscription. Pull anytime for updates.

**What's the difference between the free template and the paid advanced CLAUDE.md?**
The free template has every section with instructions and examples -- a solid starting point you fill in yourself. The paid version is the full, production-grade file: every auto-invoke rule, every skill trigger, the complete model routing matrix, and vault conventions. The exact architecture running daily in a production setup.

**Do I need Node.js?**
Yes, for the hooks. Node.js 18+ is required. The installer checks for it and warns if it's missing.

**What is the vault?**
A folder of Markdown files -- your persistent memory. Claude reads `Home.md` on every session start. Over time it accumulates your project notes, decisions, and patterns. Think of it as a second brain that loads automatically.

---

## File Structure

```
powerclaude/
  install.ps1              # Windows installer (irm | iex)
  install.sh               # Mac/Linux installer (curl | bash)
  free/
    CLAUDE.md.template     # Starter CLAUDE.md with instructions
    api-keys.json.example  # API key store template
    hooks/
      session-start.js     # Injects vault Home.md at session start
      user-prompt-submit.js # Injects project context at conversation start
      settings.json.example # Hook wiring for ~/.claude/settings.json
    vault-templates/       # Seeded vault files (Home, Projects, etc.)
    window-prompts/        # Specialized session prompts (general, planning, debug, review)
  docs/
    vault-setup.md         # Vault philosophy and structure guide
    model-routing.md       # Model routing decision matrix and setup
    graphify-setup.md      # Semantic codebase querying guide
    mcp-guide.md           # MCP server setup guide
```

---

## Troubleshooting

Vault not loading? Hooks not firing? Model routing broken? See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for solutions to every common setup issue.

---

## Contributing

Issues and PRs welcome. If you've built a hook, skill trigger pattern, or window prompt that works well -- open a PR. The goal is the best possible default setup, not a showcase of one person's config.

---

*Built on [Claude Code](https://claude.ai/code) by Anthropic.*
*MIT License -- free tier. Paid tier files are proprietary.*


