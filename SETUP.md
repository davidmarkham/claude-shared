# Setup Guide

One-time setup for the claude-shared repo, including GitHub MCP integration
so Claude Desktop can push decoded tickets directly to the queue.

## Prerequisites

- **Windows 11** with **Developer Mode** enabled
  (Settings → System → For Developers → Developer Mode toggle)
- **Git Bash** (comes with Git for Windows)
- **Docker Desktop** (recommended) — for GitHub MCP server
- **Claude Desktop** app
- **Claude Code** extension in VS Code
- **GitHub account** with a private repo for this config

---

## Step 1: Create the GitHub repo and clone it

Create a **private** repo on GitHub (e.g., `claude-shared`), then clone:

```bash
git clone git@github.com:YOUR_USERNAME/claude-shared.git ~/repos/claude-shared
```

Copy this package's contents in, commit, and push:

```bash
cd ~/repos/claude-shared
# Copy everything from this package
chmod +x scripts/link-project.sh
git add -A && git commit -m "initial setup" && git push
```

---

## Step 2: Create a GitHub Personal Access Token

The GitHub MCP server needs a PAT to read/write to your repo.

1. Go to https://github.com/settings/tokens?type=beta (fine-grained tokens)
2. Click **Generate new token**
3. Name: `claude-mcp`
4. Expiration: 90 days (or your preference)
5. Repository access: **Only select repositories** → select your `claude-shared` repo
6. Permissions:
   - **Contents**: Read and write (to push queue files)
   - **Metadata**: Read (default)
7. **Copy the token immediately** — you won't see it again

---

## Step 3: Set up GitHub MCP server for Claude Desktop

### Option A: Docker (recommended)

Config file: `%APPDATA%\Claude\claude_desktop_config.json`

Open from Claude Desktop: **Settings → Developer → Edit Config**

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_PAT_HERE"
      }
    }
  }
}
```

### Option B: npx (no Docker)

On Windows, use the full path to `npx.cmd`, not just `"npx"`:

```json
{
  "mcpServers": {
    "github": {
      "command": "C:\\Program Files\\nodejs\\npx.cmd",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_PAT_HERE"
      }
    }
  }
}
```

### Verify

1. Completely quit Claude Desktop (not just close window)
2. Reopen Claude Desktop
3. MCP indicator appears in bottom toolbar — click to see GitHub tools
4. Test: "What repos can you see on my GitHub?"

---

## Step 4: Link shared skills into a project

Per-project, on demand:

```bash
~/repos/claude-shared/scripts/link-project.sh /d/IdeaProjects/NECHE-devdm
```

See [README.md](README.md) for `--list`, `--unlink`, and `--skills` options.

---

## Step 5: Load PowerShell queue helpers (optional)

Add to your PowerShell profile:

```powershell
echo $PROFILE                 # find path
notepad $PROFILE              # edit
# Add:
. ~/repos/claude-shared/scripts/queue-helpers.ps1
```

Restart PowerShell. Available commands:
- `qtix` — move downloaded ticket files to the queue
- `qlist` — list queue contents
- `qpeek` — preview the next ticket

---

## Troubleshooting

### Symlinks fail
- Enable Windows Developer Mode
- Run from Git Bash (not PowerShell or cmd)
- The link script has a self-test — it will tell you if symlinks aren't working

### GitHub MCP not showing in Claude Desktop
- Completely quit and reopen (not just close window)
- Check logs: `%APPDATA%\Claude\logs\`
- Verify Docker is running (if using Docker option)
- Verify PAT hasn't expired

### npx connection errors on Windows
- Use full path to `npx.cmd`, not just `"npx"`
- Find it: `Get-Command npx | Select-Object Source` in PowerShell

### Claude Code doesn't see linked skills
- Run the link script in Git Bash
- Check with `--list` to see what's actually linked
- Restart the Claude Code session

### Queue file not found by `/load-ticket`
- `git pull` in `~/repos/claude-shared/` after Desktop pushed a ticket
- Verify the file is in `queue/` and ends in `.md`
