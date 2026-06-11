# PowerClaude Personalization Engine
# ─────────────────────────────────────────────────────────────────────────────
# INSTRUCTIONS: Paste the entire contents of this file into a new Claude Code
# session. Claude will ask you 7 questions and then generate your complete
# personalized setup — CLAUDE.md, vault, window prompts, hooks, and routing.
#
# Requirements before running:
# - Claude Code installed (https://claude.ai/code)
# - Node.js installed (for hook scripts)
# - A vault folder path in mind (e.g. C:\Users\you\Documents\Claude)
# ─────────────────────────────────────────────────────────────────────────────

You are setting up a complete, personalized Claude Code environment using the PowerClaude system. Your job is to interview the user and then generate every file they need — no templates left partially filled, no placeholders remaining.

This is a one-time setup session. Take your time. Ask each question one at a time using the AskUserQuestion tool. After collecting all answers, generate the complete system.

---

## PHASE 1: INTERVIEW

Ask each question one at a time using AskUserQuestion. Wait for the full answer before proceeding to the next question.

### Question 0: Name and role

Ask this first. The answer fills in the Always-On Context section of CLAUDE.md.

Use AskUserQuestion with:
- question: "What is your name, role, and email address? (This goes into your CLAUDE.md so Claude knows who you are.)"
- header: "Your identity"
- options:
  - "I'll type it in the Other field below"
  - (just one option that guides them to use Other for free text)

### Question 1: Projects

Ask: "List your active projects. For each one, tell me: the project name, its absolute path on disk, its tech stack, and what it does in one sentence."

Use AskUserQuestion with:
- question: "List your active projects. For each one: name, full path on disk, tech stack, one-line description. (You can type freely in the Other field)"
- header: "Active projects"
- options: at least one option noting they should use the Other field to type their full list

### Question 2: Tech stack

Ask about their primary tech stack in detail.

Use AskUserQuestion with:
- question: "What is your primary tech stack? Include languages, frameworks, databases, testing tools, and any key libraries you use daily."
- header: "Tech stack"
- options: common stacks as options, with Other for custom

Suggested options:
- "TypeScript + React + Node.js"
- "Python (FastAPI/Django/Flask)"
- "Full-stack TypeScript (Next.js)"
- "Multiple stacks (use Other to list)"

### Question 3: MCP servers

Ask which MCP servers they have installed.

Use AskUserQuestion with:
- question: "Which MCP servers do you have installed or plan to install?"
- header: "MCP servers"
- multiSelect: true
- options:
  - "GitHub (PRs, issues, code search)"
  - "Supabase (database, migrations)"
  - "Slack (messaging)"
  - "Google Calendar / Gmail"
  - "Linear (issues)"
  - "None yet / not sure"
  (plus Other for custom)

### Question 4: External tools

Ask which external tools they check daily.

Use AskUserQuestion with:
- question: "Which external tools are part of your daily workflow?"
- header: "Daily tools"
- multiSelect: true
- options:
  - "Gmail"
  - "Slack"
  - "Notion"
  - "Linear"
  - "GitHub"
  - "Figma"
  (plus Other)

### Question 5: Vault path

Ask where they want their vault.

Use AskUserQuestion with:
- question: "Where do you want your Claude vault? This is the folder that stores your persistent memory — projects, decisions, session notes."
- header: "Vault path"
- options:
  - "~/Documents/Claude (Mac/Linux)"
  - "C:\\Users\\[username]\\Documents\\Claude (Windows)"
  - "~/OneDrive/Claude (Windows, auto-synced)"
  - "I'll specify a custom path (use Other)"

### Question 6: Frustrations

Ask what is currently broken or frustrating about their Claude setup.

Use AskUserQuestion with:
- question: "What are your biggest frustrations with how Claude works for you right now? What does it get wrong, forget, or do too often?"
- header: "Pain points"
- options:
  - "Re-explaining my stack every session"
  - "Too verbose / too many questions"
  - "Forgets decisions I made"
  - "Does not know when to stop and ask"
  (plus Other to describe specific issues)

### Question 7: Response style

Ask about their preferred response style.

Use AskUserQuestion with:
- question: "How do you prefer Claude to communicate with you?"
- header: "Response style"
- options:
  - "Terse: lead with result, minimal explanation"
  - "Balanced: result first, context when it matters"
  - "Thorough: explain the why behind decisions"
  - "Match the task: short for quick tasks, detailed for complex ones"

---

## PHASE 2: GENERATE

After collecting all 7 answers, generate the complete setup. Write every file to disk using the Write tool. Do not leave any placeholder unfilled.

### File 1: ~/.claude/CLAUDE.md

Generate a complete CLAUDE.md based on their answers. Structure:

**App Launchers section** (if they mentioned Electron apps):
- Add launch commands for each app they listed
- Use PowerShell syntax on Windows, bash on Mac/Linux

**[NAME] - Always-On Context section**:
- Fill in their actual name, role, email from what they shared
- List their actual projects with real paths and stacks
- Set greeting rules matching their response style preference
- Set tone rules based on their response style (terse/balanced/thorough)
- Rules: include the 4 core rules, plus any rules derived from their frustrations

**Proactive Behaviors table**:
- Include the core 8 behaviors
- Add stack-specific behaviors for their tech stack:
  - TypeScript/React projects: add hooks for ui-ux-pro-max, design-motion-principles
  - Python projects: add fabric URL processing
  - Any project: add graphify query routing

**Auto-Invoke Skills section**:
- Include Planning and Design section (always)
- Include UI and Frontend section ONLY if they use React/Vue/Angular
- Include Debugging and Quality section (always)
- Include Execution and Delivery section (always)
- Include Codebase Navigation with their actual graphify paths
- Include Research section if they process URLs or documents
- For each MCP they listed, add a routing rule:
  - GitHub MCP: "GitHub task (PR, issue, diff) -> use github MCP tools mcp__github__*"
  - Supabase MCP: "Database query -> use supabase MCP tools"
  - etc.

**Key Paths table**:
- Vault: their actual vault path
- API keys: ~/.claude/api-keys.json
- Each project: their actual paths
- Graphify graphs: [project path]/graphify-out/graph.json for each project

**Model Routing section**:
- Full routing table
- Add their stack-specific routing (e.g. if they use Python, add Python file summarization patterns)

**Vault Conventions section**:
- Standard conventions
- Add any custom logging rules based on their projects

**Vault Loading section**:
- Their actual vault path
- Instructions to set CLAUDE_VAULT_PATH env variable

### File 2: Vault at their specified path

Create the full vault structure with seeded files:

Home.md:
- Their actual name in Quick Reference
- Their actual projects listed in Active Projects
- Correct date

User Profile/User Profile.md:
- Their actual background from the interview

User Profile/Claude Behavior Rules.md:
- Rules derived from their frustrations (e.g. if they said "too verbose" -> add rule against long explanations)

Projects/Active/[ProjectName].md for each project:
- One file per project with name, path, stack, description
- Parent: [[Projects/Projects]]

Session Takeaways/Session Takeaways.md:
- Entry for today: "PowerClaude installed. Setup complete."

Claude and AI/When to Use What.md:
- Their actual model routing table
- Their actual MCP routing

### File 3: Personalized window prompts

Create one window prompt file per specialized window they need, based on their stack:

Always create:
- ~/.claude/windows/general.md
- ~/.claude/windows/planning.md
- ~/.claude/windows/debug.md
- ~/.claude/windows/code-review.md

Create if they use React/frontend:
- ~/.claude/windows/ui-design.md

Create if they do infrastructure/DevOps:
- ~/.claude/windows/infra.md

Each window prompt should:
- Be pre-filled with their actual project name and stack
- Include their actual project paths in the context section
- Reference their specific tools (not generic placeholders)

### File 4: ~/.claude/hooks/user-prompt-submit.js

Generate the actual hook file with:
- Their actual ACTIVE_PROJECTS array (real project names, paths, stacks)
- Their actual MUST_DO_RULES based on their stack
- Their actual CLAUDE_VAULT_PATH set as default

### File 5: ~/.claude/settings.json

Generate or update settings.json with:
- SessionStart hook wired to session-start.js
- UserPromptSubmit hook wired to user-prompt-submit.js
- Any MCP server configs they asked about (with token placeholders)

---

## PHASE 3: VERIFY

After writing all files, confirm completion:

1. List every file that was created
2. Show the first 10 lines of CLAUDE.md to confirm it is filled in (no [PLACEHOLDERS] remaining)
3. Show the ACTIVE_PROJECTS array from user-prompt-submit.js
4. Tell them: "Run `claude` in any project folder. Your vault loads automatically. Your stack auto-invokes skills. Model routing is active."

---

## RULES FOR GENERATION

- Every placeholder MUST be filled in. If you are unsure about a value, make a reasonable inference from the interview or ask one final clarifying question.
- Do not generate comments explaining what each section does — generate real values.
- CLAUDE.md must be ready to use as-is. The user should not need to edit anything.
- Window prompts must reference their actual stack, not generic stack placeholders.
- The vault Home.md must have their actual name and projects listed.
- If they mentioned frustrations about specific behavior, address those explicitly in Claude Behavior Rules.
