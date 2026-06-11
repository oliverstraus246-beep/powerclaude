# Graphify + GitNexus: Full Setup Guide

This guide covers semantic codebase navigation - the single biggest productivity unlock in the paid setup. Instead of reading files to understand code, you query a graph.

## What you get

After this setup:
- `graphify query "how does auth work" --graph project/graphify-out/graph.json`
  -> Returns a description of the auth flow with file and line references. 30 seconds.
  
- GitNexus MCP tool in Claude Code:
  -> "What breaks if I change the User model?" -> Impact analysis in seconds
  -> "Find all places that handle payments" -> Semantic search across the codebase

## Part 1: Graphify

### Installation

```bash
npm install -g graphify-cli
```

Verify:
```bash
graphify --version
```

### Indexing your first project

Navigate to the project root and run:

```bash
cd C:/path/to/your/project
graphify build --output graphify-out/graph.json
```

For large projects (>50k lines), this takes 2-5 minutes. For typical projects, under 60 seconds.

### Add to .gitignore

```
graphify-out/
```

### Using the graph

Basic query:
```bash
graphify query "how does authentication work" --graph graphify-out/graph.json
```

Other useful queries:
```bash
graphify query "what does the User model contain" --graph graphify-out/graph.json
graphify query "how is the database initialized" --graph graphify-out/graph.json
graphify query "where are environment variables loaded" --graph graphify-out/graph.json
graphify query "what calls the sendEmail function" --graph graphify-out/graph.json
graphify query "how does the API handle errors" --graph graphify-out/graph.json
```

### Adding to CLAUDE.md

In your Key Paths table:
```
| Graphify - Project Name | C:/path/to/project/graphify-out/graph.json |
```

In your Proactive Behaviors:
```
| About to read source files | Query graphify first |
```

In your Auto-Invoke Skills:
```
graphify query (CLI command) - invoke for ANY codebase question:
  graphify query "question" --graph "C:/path/to/project/graphify-out/graph.json"
```

### Keeping the graph current

Rebuild when:
- Added a major new feature (new routes, new modules)
- Refactored a core module
- The graph feels stale (Claude misses recent additions)

Daily development does not require a rebuild - the graph is a snapshot, not a live index. Rebuild once a week during active development.

Add to your shell profile for convenience:
```bash
# Mac/Linux ~/.zshrc or ~/.bashrc
alias gbuild='graphify build --output graphify-out/graph.json'
alias gquery='graphify query'
```

```powershell
# Windows PowerShell profile
function gbuild { graphify build --output graphify-out/graph.json }
function gquery { graphify query @args }
```

---

## Part 2: GitNexus

GitNexus provides impact analysis and semantic search through a Claude Code MCP integration.

### Installation

```bash
npm install -g gitnexus
```

### Indexing a project

```bash
cd C:/path/to/your/project
npx gitnexus analyze
```

This creates a GitNexus index for the project. First run takes 1-3 minutes.

### Connecting to Claude Code

GitNexus exposes an MCP server. Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "npx",
      "args": ["gitnexus", "mcp"],
      "cwd": "C:/path/to/your/project"
    }
  }
}
```

Restart Claude Code after adding this.

### What GitNexus provides

Once connected, Claude Code has access to `mcp__gitnexus__*` tools:

**Impact analysis:**
"What files break if I change the payment processor interface?"
-> GitNexus traces all callers and callers-of-callers, returns the impact list

**Semantic search:**
"Find all places that validate user permissions"
-> Returns file/line references for every location, not just exact string matches

**Dependency chains:**
"What does the UserService depend on?"
-> Returns the full dependency tree

### Adding to CLAUDE.md

In your Auto-Invoke Skills section:
```
GitNexus MCP - invoke for:
- Impact analysis: "What breaks if I change X?"
- Semantic queries: "Find all places that handle payments"
- Dependency chains: "What does Y depend on?"
```

### Graphify vs GitNexus: when to use which

| Use case | Tool |
|----------|------|
| "How does X work?" (understanding) | graphify query |
| "What breaks if I change X?" (impact) | GitNexus MCP |
| "Find all places that do Y" (semantic search) | GitNexus MCP |
| "What files does Z depend on?" | GitNexus MCP |
| Quick codebase orientation | graphify query |
| Pre-refactor impact assessment | GitNexus MCP |

Use both. They solve different problems.

---

## Part 3: CLAUDE.md integration (complete example)

Here is the full codebase navigation section for your CLAUDE.md, with real paths substituted:

```
### Codebase Navigation

graphify query (CLI command) - invoke for ANY codebase question:
  graphify query "question" --graph "C:/path/to/project/graphify-out/graph.json"

- "How does auth work?" -> query
- "What calls this function?" -> query  
- "Where is the payment handler?" -> query
- NEVER open files to explore code. Query first, open specific files only if query is insufficient.

GitNexus MCP (mcp__gitnexus__*) - invoke for:
- Impact analysis: "What breaks if I change X?"
- Semantic queries: "Find all places that handle payments"
- Dependency chains: "What does Y depend on?"
- Always run impact analysis BEFORE refactoring any shared function
```

---

## Troubleshooting

**graphify build fails with memory error:**
For very large monorepos, run with increased Node memory:
```bash
NODE_OPTIONS=--max-old-space-size=4096 graphify build --output graphify-out/graph.json
```

**Queries return stale results:**
Run `graphify build` again to rebuild the graph.

**GitNexus MCP not showing in Claude Code:**
1. Verify `npx gitnexus mcp` runs without error from your project root
2. Restart Claude Code after editing settings.json
3. Check Claude Code settings -> MCP Servers for connection status

**gitnexus analyze is slow:**
First run indexes git history - this is normal. Subsequent runs are incremental.
