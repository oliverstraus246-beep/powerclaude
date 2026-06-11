# Vault Setup

The vault is a folder of Markdown files that Claude reads automatically via hooks. It is your persistent memory across every session.

## What the vault does

Without a vault, Claude starts every session with zero context. You re-explain your projects, your preferences, your decisions. You correct the same mistakes repeatedly.

With a vault, every session starts knowing:
- What your active projects are and where they live
- What decisions you made last week and why
- What patterns you have noticed
- How you want Claude to behave

The vault is not magic. Claude does not read it psychically. The session-start hook reads your Home.md and injects it into context on launch. You maintain the vault; the hook loads it.

## Folder structure

```
Claude/
├── Home.md                         <- Master index. Loaded on every session start.
├── User Profile/
│   ├── User Profile.md             <- Your background, skills, work style
│   └── Claude Behavior Rules.md   <- How you want Claude to respond
├── Projects/
│   ├── Projects.md                 <- Index of all projects
│   └── Active/
│       └── MyProject.md            <- One file per active project
├── Session Takeaways/
│   └── Session Takeaways.md       <- Dated log of what happened in each session
├── Decisions Log/
│   └── Decisions Log.md           <- Architectural decisions and reasoning
├── Goals and Ideas/
│   └── Goals and Ideas.md         <- What you are working toward
├── Claude and AI/
│   └── When to Use What.md        <- Model/skill routing reference
└── Knowledge Base/
    ├── Web Development/
    ├── Design/
    └── Marketing/
```

## Wikilink conventions

Every file must link to at least one other. This makes the vault a graph, not a pile of notes.

Format: [[Folder/FileName|Display Name]] or [[Folder/FileName]] for same-name links.

Every file must have on line 2: `Parent: [[Folder/ParentFile]]`

When you create a new file, update the parent to link back to it.

## Maintaining the vault

Claude maintains the vault automatically when configured:

- After a meaningful feature: Claude appends to Projects/Active/[Project].md
- After a decision: Claude appends to Decisions Log
- After each session: Claude updates Session Takeaways

This happens because of the proactive behavior rules in your CLAUDE.md. If you skip that section, the vault goes stale.

## Using an Obsidian viewer (optional but recommended)

The vault is plain Markdown. Open the Claude folder in Obsidian for:
- Graph view showing how notes connect
- Backlink navigation
- Quick search across all your notes
- Wikilink autocomplete when editing

Obsidian is free for personal use: https://obsidian.md
