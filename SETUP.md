# Setup Guide

Complete setup for the claude-shared repo, including GitHub MCP integration
so Claude Desktop can push decoded tickets directly to the queue.

## Prerequisites

- **Windows 11** with **Developer Mode** enabled
  (Settings → System → For Developers → Developer Mode toggle)
- **Git Bash** (comes with Git for Windows)
- **Node.js** (LTS) — needed for GitHub MCP server
- **Docker Desktop** (recommended) OR Node.js for GitHub MCP server
- **Claude Desktop** app
- **Claude Code** extension in VS Code
- **GitHub account** with a private repo for this config

---

## Step 1: Create the GitHub repo

Create a **private** repo on GitHub (e.g., `claude-shared`).

Clone it and copy these files in:

```bash
# In Git Bash:
git clone git@github.com:YOUR_USERNAME/claude-shared.git ~/repos/claude-shared
# Copy the contents of this package into that directory
cd ~/repos/claude-shared
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
   (and any other repos you want Claude to access)
6. Permissions:
   - **Contents**: Read and write (needed to push queue files)
   - **Metadata**: Read (required by default)
7. Click **Generate token**
8. **Copy the token immediately** — you won't see it again

---

## Step 3: Set up GitHub MCP server for Claude Desktop

### Option A: Docker (recommended — cleaner isolation)

Make sure Docker Desktop is running, then edit your Claude Desktop config:

**Config file location:** `%APPDATA%\Claude\claude_desktop_config.json`

Open it from Claude Desktop: **Settings → Developer → Edit Config**

Add or merge this into your config:

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

Replace `YOUR_PAT_HERE` with your actual token.

### Option B: npx (no Docker needed)

**Important Windows note:** Use the full path to `npx.cmd`, not just `"npx"`.
Find it by running in PowerShell: `Get-Command npx | Select-Object Source`
It's typically `C:\Program Files\nodejs\npx.cmd`.

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

**Note:** The `@modelcontextprotocol/server-github` package is deprecated in
favor of `ghcr.io/github/github-mcp-server` (Docker). The npx version still
works but may not receive updates. Use Docker if possible.

### Verify

1. **Completely quit** Claude Desktop (not just close the window)
2. Reopen Claude Desktop
3. Look for the MCP server indicator (slider icon) in the bottom toolbar
4. Click it — you should see GitHub tools listed (create_or_update_file, etc.)
5. Test: Ask Claude "What repos can you see on my GitHub?"

---

## Step 4: Set up GitHub MCP for Claude Code

Claude Code can also use the same GitHub MCP server. Since you're logged into
Claude Desktop, MCP servers configured there are automatically available in
Claude Code. But if you want to add it explicitly:

```bash
# In Git Bash (NOT inside a Claude Code session):
claude mcp add github \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=YOUR_PAT_HERE \
  --scope user \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

The `--scope user` flag makes it available across all projects.

---

## Step 5: Sync shared config to ~/.claude/

```bash
# In Git Bash:
cd ~/repos/claude-shared
chmod +x scripts/sync.sh
./scripts/sync.sh
```

This creates symlinks from `~/.claude/skills/` to the repo's skill directories,
and symlinks `~/.claude/CLAUDE.md` to the repo's global CLAUDE.md.

**Verify:** Open Claude Code in VS Code, type `/` — you should see the shared
skills listed (decode-ticket, breadcrumb, load-ticket, etc.).

---

## Step 6: Load PowerShell helpers (optional)

Add this line to your PowerShell profile:

```powershell
# Find your profile path:
echo $PROFILE

# Edit it:
notepad $PROFILE

# Add this line:
. ~/repos/claude-shared/scripts/queue-helpers.ps1
```

Restart PowerShell. You now have:
- `qtix` — move downloaded ticket files to the queue
- `qlist` — list what's in the queue
- `qpeek` — preview the next ticket

---

## Workflow: Chat → Queue → Claude Code

### Pushing tickets from Claude Desktop (with GitHub MCP)

1. Decode a ticket in Claude Desktop as usual
2. Say: **"Push this to my queue"** or **"Queue this ticket"**
3. Claude uses the GitHub MCP to create the file directly in your
   `claude-shared` repo's `queue/` directory
4. The file appears in your repo — `git pull` in your local clone to sync

### Pushing tickets from Claude.ai web (no GitHub MCP)

1. Decode a ticket in Claude.ai chat
2. Say: **"Queue this ticket"**
3. Claude generates a downloadable .md file
4. Download it, then either:
   - Run `qtix` in PowerShell (auto-moves from Downloads to queue)
   - Or manually move it to `~/repos/claude-shared/queue/`

### Loading tickets in Claude Code

1. In any Claude Code session: `/load-ticket`
2. Claude reads the queue, shows available tickets
3. Pick one (or it auto-loads if there's only one)
4. Start working — the ticket is archived after you begin

### Committing queue history

```bash
cd ~/repos/claude-shared
git add -A && git commit -m "queue: [brief description]" && git push
```

---

## Updating shared skills

Edit skills directly in `~/repos/claude-shared/skills/`. Since they're
symlinked, changes are immediately live in Claude Code (it detects skill
file changes without restart).

```bash
cd ~/repos/claude-shared
git add -A && git commit -m "update: [skill name]" && git push
```

After pulling on another machine, run `./scripts/sync.sh` to create any
new symlinks.

---

## Troubleshooting

### Symlinks not working
- Ensure Developer Mode is enabled in Windows Settings
- Run `sync.sh` from Git Bash (not PowerShell or cmd)

### GitHub MCP not showing in Claude Desktop
- Completely quit and reopen (not just close window)
- Check logs: `%APPDATA%\Claude\logs\`
- Verify Docker is running (if using Docker option)
- Verify the PAT hasn't expired

### npx connection errors on Windows
- Use the full path to `npx.cmd` — not just `"npx"`
- Run `Get-Command npx | Select-Object Source` in PowerShell to find the path
- Make sure Node.js is in your system PATH

### Claude Code doesn't see shared skills
- Run `./scripts/sync.sh` in Git Bash
- Check that `~/.claude/skills/` contains symlinks (not empty)
- Restart VS Code / Claude Code session

### Queue file not found by /load-ticket
- Make sure you've done `git pull` in `~/repos/claude-shared/` after pushing
  from Claude Desktop
- Verify the file is in `queue/` and ends in `.md`
