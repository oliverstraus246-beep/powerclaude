# PowerClaude - Full Version

Thank you for purchasing. Here is everything you need to get started.

---

## What You Got

| Item | Location after install | What it does |
|------|----------------------|--------------|
| Vault-logger hook | `~/.claude/hooks/vault-logger.js` | Auto-logs every session to your vault at session end |
| 11 window prompts | `~/.claude/window-prompts/` | Specialized Claude sessions for Planning, Debug, Code Review, UI, Infra, Research, Prompt Eng, Refactor, Briefing, Security, Handoff |
| Advanced CLAUDE.md template | `~/.claude/CLAUDE.md.template` | Richer template with more customization fields |
| Personalization engine | `~/.claude/personalization-engine.md` | 7-question wizard that generates your CLAUDE.md automatically |
| Graphify + GitNexus guide | `~/.claude/graphify-gitnexus-guide.md` | How to index your codebase for semantic search |

---

## Install

**Requires:** Free tier already installed. If you have not done that yet:
- Windows: `irm https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/install.ps1 | iex`
- Mac/Linux: `curl -fsSL https://raw.githubusercontent.com/oliverstraus246-beep/powerclaude/main/install.sh | bash`

**Then run the paid installer from this folder:**

Windows:
```powershell
.\install-paid.ps1
```

Mac / Linux:
```bash
bash install-paid.sh
```

---

## Step 1: Generate Your CLAUDE.md (2 minutes)

The personalization engine turns 7 questions into a fully configured CLAUDE.md.

1. Open Claude Code
2. Start a new session
3. Paste the entire contents of `~/.claude/personalization-engine.md` as your first message
4. Answer the questions
5. Claude writes your CLAUDE.md automatically

You can also edit `~/.claude/CLAUDE.md` directly -- search for `FILL IN` to find every placeholder.

---

## Step 2: Use Your Window Prompts

Each `.md` file in `~/.claude/window-prompts/` is a specialized Claude session.

**How to use:**
1. Open Claude Code
2. Start a **new session** (important -- these work best as the first message)
3. Paste the entire contents of the window prompt
4. Claude immediately behaves as a specialist for that task

**The 11 windows:**

| File | Use it when |
|------|-------------|
| `01-planning.md` | Starting a feature or architecture decision |
| `02-debug.md` | Something is broken and you need root cause |
| `03-code-review.md` | Reviewing code before merge or ship |
| `04-ui-design.md` | Building or redesigning UI components |
| `05-infrastructure.md` | Deploy, CI/CD, environment config |
| `06-research.md` | Researching libraries, competitors, docs |
| `07-prompt-engineering.md` | Writing system prompts or voice scripts |
| `08-refactor.md` | Cleaning code without changing behavior |
| `09-briefing.md` | Start of session -- what happened, what is next |
| `10-security.md` | Pre-deploy security audit |
| `11-handoff.md` | End of session -- capture and carry context forward |

---

## Step 3: Vault-Logger

After install, your sessions are automatically logged to your vault at session end.

Each entry is timestamped and saved to:
```
[YOUR_VAULT]/Session Takeaways/Session Takeaways.md
```

No action needed -- it runs automatically via the Stop hook.

---

## Questions or Issues

Check `TROUBLESHOOTING.md` from the free tier repo first.

Most common issue: vault-logger not logging = `CLAUDE_VAULT_PATH` not set.
Run `node ~/.claude/validate.js` to check all configuration.
