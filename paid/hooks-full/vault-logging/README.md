# Vault Logging Hook

Automatically appends a timestamped entry to your Session Takeaways when a session ends.

## Setup

1. Copy vault-logger.js to ~/.claude/hooks/
2. Set CLAUDE_VAULT_PATH environment variable (or edit the VAULT_PATH constant in vault-logger.js)
3. Add to ~/.claude/settings.json:

```json
{
  "hooks": {
    "Stop": [
      {
        "command": "node ~/.claude/hooks/vault-logger.js",
        "description": "Log session summary to vault on stop"
      }
    ]
  }
}
```

## How it works

When Claude Code stops (session ends), it passes a summary to the Stop hook.
The logger appends that summary to Session Takeaways/Session Takeaways.md with today date.

For full vault logging (decisions, project updates, pattern tracking), configure the
proactive behaviors in your CLAUDE.md - those run during the session, not just at the end.
