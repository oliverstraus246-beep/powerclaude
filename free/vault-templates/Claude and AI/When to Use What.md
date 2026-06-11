# When to Use What
Parent: [[Home]]

Quick routing guide for tools, models, and skills.

## Models
| Task | Model | Command |
|------|-------|---------|
| Summarize a file | Gemini 2.5 Flash | llm -m gemini-2.5-flash "summarize" < file.txt |
| Explain a snippet | Gemini 2.5 Flash | pipe to llm |
| Multi-file code changes | Claude Sonnet | current session |
| Complex debugging | Claude Sonnet | |
| Architecture decisions | Claude Sonnet | |
| Novel unsolved problems | Claude Opus | last resort |

## Tools
| Task | Tool |
|------|------|
| Understand how a codebase works | graphify query |
| Impact analysis: what breaks if I change X | GitNexus MCP |
| Summarize a URL or article | curl -sL URL piped to fabric -p summarize |
| Read a PDF, Word, or Excel file | markitdown file first |

## Skills
| Situation | Skill |
|-----------|-------|
| New feature being added | brainstorming (fires automatically) |
| Any error or crash | systematic-debugging (fires automatically) |
| Frontend code being written | ui-ux-pro-max (fires automatically) |
| About to ship | verification-before-completion (fires automatically) |

Related: [[Home]] - [[User Profile/Claude Behavior Rules]]
