# Claude Shared Config

Personal shared repository for Claude Code skills, commands, and configuration.
Syncs to `~/.claude/` via symlinks so all Claude Code projects inherit shared skills.

## Quick Start

See **[SETUP.md](SETUP.md)** for the full step-by-step guide, including
GitHub MCP server configuration for automatic ticket pushing.

**Short version:**

```bash
# In Git Bash:
git clone <this-repo> ~/repos/claude-shared
cd ~/repos/claude-shared
chmod +x scripts/sync.sh
./scripts/sync.sh
```

## Prerequisites

- Windows 11 with **Developer Mode enabled**
  (Settings → System → For Developers → Developer Mode toggle)
- Git Bash (comes with Git for Windows)
- Claude Code extension in VS Code
- Docker Desktop (recommended) for GitHub MCP server
- GitHub PAT with Contents read/write on this repo

## Structure

```
skills/              # Shared skills (symlinked to ~/.claude/skills/)
  decode-ticket/     # Ticket decoder for Claude Code context
  breadcrumb/        # Session pause/resume breadcrumb notes
  sf-code-standards/ # Salesforce/LWC coding standards & review conventions
  sf-change-list/    # Deployment file list → grouped component summary
  load-ticket/       # Load a decoded ticket from the queue
  work-session/      # Full work session lifecycle management
  project-setup/     # Scan codebase → generate project .claude/ config
templates/           # Starter templates for project-specific config
  AGENTS-salesforce.md  # Agent definitions template for SF projects
docs/                # Reference docs (not loaded as skills)
  chrome-integration.md # @browser setup and usage reference
queue/               # Decoded tickets pushed from Claude chat app
  archive/           # Consumed tickets moved here after loading
scripts/             # Sync and utility scripts
CLAUDE.md            # Global CLAUDE.md (symlinked to ~/.claude/CLAUDE.md)
```

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

### After loading

- The ticket is moved to `queue/archive/` once you start
- Commit when convenient — git tracks the full queue history

## Updating shared skills

Edit skills in this repo. Symlinks mean `~/.claude/skills/<name>` points
directly here — changes are live immediately (Claude Code detects skill
file changes without restart).

```bash
git add -A && git commit -m "update skills" && git push
```

## Project-specific skills

Project-specific skills go in each project's own `.claude/skills/` directory,
committed to that project's repo. They layer on top of these shared skills.
Precedence: enterprise > personal (~/.claude) > project (.claude).

## Re-syncing after a pull

```bash
cd ~/repos/claude-shared && ./scripts/sync.sh
```

Only needed if new skills were added. Existing symlinks survive pulls.
