# Troubleshooting

Solutions to the most common setup issues.

---

## Vault not loading at session start

**Symptom:** Claude has no memory of your projects. No vault context appears.

**Cause 1: CLAUDE_VAULT_PATH environment variable is not set**

Check if it is set:
```powershell
# Windows
$env:CLAUDE_VAULT_PATH

# Mac/Linux
echo $CLAUDE_VAULT_PATH
```

If it returns nothing, set it and add to your profile for persistence:
```powershell
# Windows - add this to your PowerShell profile ($PROFILE)
$env:CLAUDE_VAULT_PATH = "C:\Users\you\Documents\Claude"

# Mac/Linux - add this to ~/.bashrc or ~/.zshrc
export CLAUDE_VAULT_PATH="$HOME/Documents/Claude"
```

After setting it, restart Claude Code.

**Cause 2: Home.md does not exist at the vault path**

Check that the file exists:
```powershell
Test-Path "$env:CLAUDE_VAULT_PATH\Home.md"   # Windows
# Should return True
```

If False, either re-run the installer or create Home.md manually from the template in `free/vault-templates/Home.md`.

**Cause 3: settings.json is not wiring the hook**

Check that your `~/.claude/settings.json` includes the SessionStart hook:
```json
{
  "hooks": {
    "SessionStart": [
      { "command": "node ~/.claude/hooks/session-start.js" }
    ]
  }
}
```

If the file does not exist or is missing the hook, copy from `free/hooks/settings.json.example`.

---

## Hooks not running

**Symptom:** No context injection, no session summaries, vault seems disconnected.

**Cause 1: Node.js not installed**

```bash
node --version
# Should return v18.x.x or higher
```

If not found, install from https://nodejs.org (LTS version). Then re-run the PowerClaude installer.

**Cause 2: Hook files missing from ~/.claude/hooks/**

```powershell
Get-ChildItem ~/.claude/hooks/   # Windows
ls ~/.claude/hooks/              # Mac/Linux
```

Should show `session-start.js` and `user-prompt-submit.js`. If missing, copy from `free/hooks/`.

**Cause 3: settings.json has a JSON syntax error**

Validate your settings file:
```bash
node -e "JSON.parse(require('fs').readFileSync(process.env.HOME + '/.claude/settings.json', 'utf8')); console.log('valid')"
```

If it throws an error, open the file and look for missing commas or brackets.

---

## Model routing not working (Gemini Flash not being used)

**Symptom:** Everything runs on Sonnet. Cheap model routing is not happening.

**Cause 1: llm CLI not installed**

```bash
llm --version
```

If not found, install it:
```bash
pip install llm
```

**Cause 2: Gemini API key not configured**

```bash
llm keys set gemini
# Paste your key when prompted
```

Get a free key at https://aistudio.google.com/apikey

**Cause 3: CLAUDE.md model routing section is not present**

Open `~/.claude/CLAUDE.md` and check that the Model Routing section exists with the routing table. If you copied the template but did not fill it in, Claude will ignore generic instructions.

---

## CLAUDE.md not loading

**Symptom:** Claude ignores rules, does not know your projects, asks questions you have already answered.

**Check:** Does `~/.claude/CLAUDE.md` exist?

```powershell
Test-Path ~/.claude/CLAUDE.md   # Windows
ls ~/.claude/CLAUDE.md          # Mac/Linux
```

If only `CLAUDE.md.template` exists (not `CLAUDE.md`), run:
```powershell
# Windows
Copy-Item ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md

# Mac/Linux
cp ~/.claude/CLAUDE.md.template ~/.claude/CLAUDE.md
```

Then open the file and fill in all `[PLACEHOLDER]` sections.

---

## graphify not working

**Symptom:** `graphify query` fails or returns empty results.

**Cause 1: graphify not installed**

```bash
npm install -g @graphify/cli
```

**Cause 2: Project not indexed yet**

Run from the project root:
```bash
npx graphify analyze
```

This creates `graphify-out/graph.json`. Takes 30-120 seconds on first run.

**Cause 3: Wrong path in CLAUDE.md**

The graphify path in your Key Paths table must match where the graph file actually lives:
```
graphify-out/graph.json   <-- relative to project root
C:/dev/myproject/graphify-out/graph.json   <-- absolute path (use this in CLAUDE.md)
```

See `docs/graphify-setup.md` for full setup instructions.

---

## Windows: PowerShell execution policy blocking install

**Symptom:** Running `irm ... | iex` fails with "script execution is disabled".

**Fix:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then re-run the install command.

---

## Still stuck?

Open an issue at https://github.com/oliverstraus246-beep/powerclaude/issues

Include:
- OS and PowerShell/bash version
- Output of `node --version` and `which node`
- Contents of `~/.claude/settings.json` (redact any tokens)
- The exact error message
