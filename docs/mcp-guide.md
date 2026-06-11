# MCP Guide

MCP (Model Context Protocol) servers give Claude tools that connect to external services. Without MCPs, Claude cannot read your GitHub PRs, query your database, or check your calendar.

## What MCPs are

An MCP server is a local process that exposes tools Claude can call. When configured, Claude can:
- Read and create GitHub issues and PRs
- Query Supabase databases
- Send Slack messages
- Read Google Calendar events
- And anything else an MCP server exposes

## How to configure MCPs

MCPs are configured in `~/.claude/settings.json` under `mcpServers`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

## Core MCPs to install first

### GitHub
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN"
  }
}
```
Use for: reading PRs, creating issues, reviewing code diffs.

### Supabase (if you use Supabase)
```json
"supabase": {
  "command": "npx",
  "args": ["-y", "@supabase/mcp-server-supabase@latest"],
  "env": {
    "SUPABASE_ACCESS_TOKEN": "YOUR_SUPABASE_PAT"
  }
}
```
Use for: querying your database, running migrations, reading logs.

## Routing rules for MCPs

Add routing rules to your CLAUDE.md so Claude knows when to use which MCP:

```
| GitHub task (PR, issue, diff) | Use github MCP tools |
| Database query | Use supabase MCP tools |
| Calendar event | Use calendar MCP tools |
```

## Storing MCP credentials

Keep MCP API tokens in `~/.claude/api-keys.json` alongside your other keys. Reference them in settings.json via environment variables rather than hardcoding.

## MCP servers directory

Browse available MCPs at:
- https://github.com/modelcontextprotocol/servers (official)
- https://mcp.so (community directory)
- Claude Code settings > MCP Servers > Add

## Troubleshooting

If an MCP server fails to start:
1. Check that the package is installed: `npx -y @package/name --version`
2. Verify the API token is valid
3. Check Claude Code logs: View > Output > Claude Code

If tools are missing:
1. Restart Claude Code after changing settings.json
2. Check the MCP server is listed in Claude Code settings as "connected"
