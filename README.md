# Claude Shared Config

Personal shared repository for Claude Code skills and configuration, linked
**per-project** on an opt-in basis. Projects that want shared skills get them
symlinked into their own `.claude/skills/`. Projects that don't keep their own
setup, untouched.

## Architecture

```
~/repos/claude-shared/              # This repo
├── skills/                          # Shared skills, one dir per skill
├── templates/                       # Starter templates (AGENTS.md, etc.)
├── docs/                            # Reference docs (chrome integration, etc.)
├── queue/                           # Decoded tickets from Claude chat
└── scripts/link-project.sh          # Links this repo's skills into a project

<project>/.claude/
├── skills/
│   ├── sf-code-standards  → symlink → ~/repos/claude-shared/skills/sf-code-standards
│   ├── decode-ticket      → symlink → ~/repos/claude-shared/skills/decode-ticket
│   ├── my-custom-skill/     (project-specific, real directory, not touched)
│   └── ...
├── CLAUDE.md                        # Project's own (not touched by link script)
└── settings.local.json              # Project's own (not touched by link script)
```

Symlinks mean edits to shared skills are immediately live in every linked
project — no per-project sync needed after a repo update.

## Two ways to link a project

### Option 1: Use the `/link-project` skill (recommended)

In Claude Code, type `/link-project` (the project you're currently working
in is assumed). The skill:

1. Audits the project's current `.claude/` state
2. Identifies redundant local skills that duplicate shared ones
3. Flags project CLAUDE.md content that duplicates the global CLAUDE.md
4. Shows a summary diff before anything changes
5. Asks for per-category confirmation (link, delete, edit) separately
6. Runs the link script and any confirmed cleanup

This is the right call when onboarding an existing project that already has
its own `.claude/` setup — you want to connect it to the shared repo *and*
slim down any accumulated duplication in one pass.

### Option 2: Run `link-project.sh` directly

For scripted/quick linking with no cleanup concerns, use the script directly.

## Prerequisites

- Windows 11 with **Developer Mode enabled**
  (Settings → System → For Developers → Developer Mode toggle)
- Git Bash (comes with Git for Windows)
- Claude Code extension in VS Code
- GitHub PAT with Contents read/write on this repo (for Desktop → queue push)

See [SETUP.md](SETUP.md) for GitHub MCP server setup for Claude Desktop.

## Using the link script

All commands run in Git Bash. Paths can use forward slashes — Git Bash
handles Windows paths transparently.

### Link all shared skills into a project

```bash
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm
```

This symlinks every skill from `skills/` into the project's `.claude/skills/`.
Any real directories that are already there (project-specific skills) are left
alone.

### Link only specific skills

```bash
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/SACSCOC-devboxdm \
    --skills decode-ticket,breadcrumb,sf-code-standards
```

Useful when a project only needs a subset.

### List what's currently in a project's `.claude/skills/`

```bash
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm --list
```

Shows each skill as one of:
- `shared (symlink)` — linked to this repo
- `symlink (external)` — symlink pointing somewhere else
- `project-specific` — a real directory

Plus a list of available shared skills *not* currently linked there.

### Remove shared symlinks (keep project-specific skills)

```bash
# Remove all shared symlinks:
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm --unlink

# Remove specific ones only:
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm --unlink breadcrumb,sf-change-list
```

Project-specific skills are never touched.

### Re-run after pulling shared repo updates

The link script is idempotent. When you pull updates to this repo, the
symlinks still point at the right place — nothing needs re-syncing. Only
re-run the script if you pulled a **new** shared skill that a project should
pick up:

```bash
cd ~/repos/claude-shared && git pull
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm  # picks up new skills
```

## Safety guarantees

The link script only touches:
- Symlinks that already point at this repo (it may update or remove those)
- Empty slots in `.claude/skills/` (it may add new symlinks there)

It will never touch:
- A real directory or file in `.claude/skills/`
- A symlink pointing outside this repo
- Anything outside of `.claude/skills/` (your CLAUDE.md, settings, AGENTS.md, etc.)

## Workflow: Chat → Claude Code ticket handoff

### From Claude Desktop (automatic — with GitHub MCP)

1. Decode a ticket in Claude Desktop
2. Say **"push this to my queue"**
3. Claude uses GitHub MCP to commit the file directly to `queue/`
4. In your local clone: `git pull`
5. In Claude Code: `/load-ticket`

### From Claude.ai web (manual — download and move)

1. Decode a ticket in Claude.ai chat
2. Claude generates a queue file → you download it
3. Run `qtix` in PowerShell (or move to `~/repos/claude-shared/queue/`)
4. In Claude Code: `/load-ticket`

The `/load-ticket` skill archives the consumed ticket to `queue/archive/`.
Commit the archive move when convenient for git history.

## Project-specific setup

For a new project, after linking shared skills, run `/project-setup` in
Claude Code. It scans the codebase and generates `.claude/CLAUDE.md`,
`.claude/AGENTS.md`, and `.claude/settings.local.json` tailored to the
project's actual structure.

## Updating shared skills

Edit skills in `~/repos/claude-shared/skills/`. Changes are immediately live
in every linked project (Claude Code picks up skill file changes without
restart).

```bash
cd ~/repos/claude-shared
git add -A && git commit -m "update: [skill name]" && git push
```

On another machine, `git pull` picks up the changes. No re-linking needed.
