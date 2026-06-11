# Graphify Setup

Graphify turns your codebase into a queryable knowledge graph. Instead of reading files to understand code, you ask questions and get answers.

## Why this matters

Without graphify, understanding a codebase means reading files, following imports, building a mental model. It takes 10-30 minutes per unfamiliar codebase. With graphify, it takes 30 seconds.

```
# Without graphify
Claude reads: index.ts, app.ts, routes/auth.ts, middleware/auth.ts, 
             utils/token.ts, models/user.ts... (15 files, 5 minutes)

# With graphify  
graphify query "how does auth work" --graph project/graphify-out/graph.json
Result: Auth flow described in 10 seconds, with exact file/line references.
```

## Installation

```bash
npm install -g graphify-cli
```

## Indexing a project

Run once per project, then re-run when the structure changes significantly:

```bash
cd /path/to/your/project
graphify build --output graphify-out/graph.json
```

This generates a semantic graph of your codebase. Takes 30-120 seconds depending on project size.

## Querying

```bash
# Ask any question about the codebase
graphify query "how does authentication work" --graph graphify-out/graph.json
graphify query "where are API routes defined" --graph graphify-out/graph.json
graphify query "what calls the payment processor" --graph graphify-out/graph.json
graphify query "how does the session management work" --graph graphify-out/graph.json
```

## Using from Claude

Add the graph paths to your CLAUDE.md Key Paths table:

```
| Graphify - My Project | C:/Users/me/myproject/graphify-out/graph.json |
```

Then in your proactive behaviors:
```
| About to read source files | Query graphify first |
```

Claude will then automatically query graphify before opening files.

## Updating the graph

Re-run `graphify build` when:
- You add a major new feature
- You restructure the codebase
- The graph feels stale (Claude is missing recent additions)

For active development, rebuilding once a week is usually enough.

## Gitignore

Add to your project's .gitignore:
```
graphify-out/
```

The graph file can be large and is regenerated from source, so it should not be committed.

## GitNexus (advanced)

GitNexus extends graphify with:
- Impact analysis: "what breaks if I change X?"
- Semantic search across commits
- Cross-project dependency tracking

Install: `npx gitnexus analyze` in your project root.
See the paid tier graphify-gitnexus-guide.md for full GitNexus setup.

