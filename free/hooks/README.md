# Hooks

PowerClaude uses two hooks to load vault context automatically.

## How hooks work in Claude Code

Claude Code hooks are shell commands that fire at specific points in the session lifecycle. They receive a JSON payload on stdin and can output context that gets injected into the conversation.

Hook types used here:
- **SessionStart** - fires when Claude Code launches. Use it to load your vault.
- **UserPromptSubmit** - fires on the first message of each new conversation. Use it to inject lean context.

## Setup

1. Copy `session-start.js` and `user-prompt-submit.js` to `~/.claude/hooks/`
2. Set `CLAUDE_VAULT_PATH` environment variable to your vault root path, OR edit the `VAULT_PATH` constant inside each file
3. Merge `settings.json.example` into `~/.claude/settings.json`

### Windows (PowerShell):

```powershell
# Set vault path (add to your PowerShell profile for persistence)
$env:CLAUDE_VAULT_PATH = "C:\Users\yourname\Documents\Claude"
```

### Mac / Linux:

```bash
# Add to ~/.zshrc or ~/.bashrc
export CLAUDE_VAULT_PATH="$HOME/Documents/Claude"
```

## Merging settings.json

If you already have a `~/.claude/settings.json`, add the hooks section manually:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "node ~/.claude/hooks/session-start.js",
        "description": "Load vault Home.md on session start"
      }
    ],
    "UserPromptSubmit": [
      {
        "command": "node ~/.claude/hooks/user-prompt-submit.js",
        "description": "Inject lean context on first message"
      }
    ]
  }
}
```

## Configuring user-prompt-submit.js

Open `~/.claude/hooks/user-prompt-submit.js` and fill in:

```js
const ACTIVE_PROJECTS = [
  { name: "My App", path: "C:/Users/me/myapp", stack: "React + Node" },
  { name: "My API", path: "C:/Users/me/myapi", stack: "Python + FastAPI" },
];

const MUST_DO_RULES = [
  "Frontend/UI work -> invoke ui-ux-pro-max skill FIRST",
  "Any bug or error -> invoke systematic-debugging skill",
  "Choices with options -> use AskUserQuestion, never plain text",
];
```

## Full hook library

The paid tier includes a complete hook library with:
- Format on save (Prettier, Black, gofmt by language)
- Incremental TypeScript type checking on edit
- Vault logging hooks that auto-capture decisions and patterns
- Build verification on session stop

Get it at https://gumroad.com/l/powerclaude
