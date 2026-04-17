---
name: link-project
description: "Connect an existing or new project to the shared claude-shared repo: run the link script to symlink shared skills, identify redundant project-local files, and propose cleanup. Use when the user says 'link this project', 'connect to shared config', 'onboard this project', 'link shared skills', 'clean up project config', or 'check for redundant config'. For greenfield projects with no existing .claude/ content, suggest /project-setup afterwards to generate project-specific config."
allowed-tools: Bash(ls *), Bash(cat *), Bash(find *), Bash(readlink *), Bash(diff *), Bash(realpath *), Bash(bash *), Bash(grep *), Write, Edit
---

# Link Project to Shared Repo

Connect a project to `/d/claude/claude-shared/` by symlinking shared skills into the project's `.claude/skills/`, then identify and propose cleanup of any now-redundant project-local files.

## When to use

- Onboarding a project to the shared config for the first time
- After pulling new shared skills, to pick them up in a specific project
- When a project has accumulated local copies of skills that are now in the shared repo
- Any time "clean up project config" or "what's redundant here" comes up

## Shared repo location

`/d/claude/claude-shared/`

Script: `/d/claude/claude-shared/scripts/link-project.sh`
Skills source: `/d/claude/claude-shared/skills/`
Global CLAUDE.md reference: `/d/claude/claude-shared/CLAUDE.md`

## Workflow

### Step 1: Confirm the project path

If the developer didn't specify a project path, ask. Typical formats:
- `/d/IdeaProjects/NECHE-devdm` (Git Bash style, Windows)
- `D:\IdeaProjects\NECHE-devdm` (Windows native)

Use Git Bash-style paths when running the link script.

### Step 2: Audit the current state

Before making any changes, scan the project's `.claude/` directory and the shared repo to identify:

```bash
PROJECT="<project_path>"
SHARED="$HOME/repos/claude-shared"

# What skills exist in the project right now?
echo "=== Project skills ==="
ls -la "$PROJECT/.claude/skills/" 2>/dev/null || echo "No .claude/skills/ yet"

# What shared skills are available?
echo ""
echo "=== Available shared skills ==="
ls -1 "$SHARED/skills/"

# What's in the project's CLAUDE.md?
echo ""
echo "=== Project CLAUDE.md (if exists) ==="
[ -f "$PROJECT/.claude/CLAUDE.md" ] && cat "$PROJECT/.claude/CLAUDE.md"
[ -f "$PROJECT/CLAUDE.md" ] && cat "$PROJECT/CLAUDE.md"
```

Build three lists:

1. **Already linked** — project skills that are already symlinks to the shared repo (via `readlink` check)
2. **Redundant project-local skills** — project-specific directories in `.claude/skills/` whose names match shared skills (e.g., project has its own `decode-ticket/` dir while a shared one also exists)
3. **Safe project-specific skills** — project directories that don't overlap with anything shared

### Step 3: Check CLAUDE.md for content overlap

If the project has a `CLAUDE.md` (either at root or in `.claude/`), compare its content against the global shared CLAUDE.md. Identify sections that are likely duplicates:

Look for these kinds of overlapping content:
- Communication style instructions that restate global preferences ("be direct", "don't pad", etc.)
- Coding principles that are now in the shared CLAUDE.md (simplicity first, surgical changes, goal-driven)
- "Ask, don't assume" variations
- "Do not edit `./src` unless asked" — this is now in the global config
- Task tracking / breadcrumb instructions
- Salesforce defaults that are covered by `/sf-code-standards`
- Ticket workflow descriptions that are in the global CLAUDE.md

Do NOT flag as duplicate:
- Project-specific codebase descriptions (architecture, portals, shared component names)
- Integration specifics (Box.com classes, PowerBI components, etc.)
- Custom file paths (labels storage location, source root, etc.)
- Anything that references project-specific conventions or constraints

### Step 4: Present the audit as a summary diff

Show the developer a clear breakdown **before doing anything**:

```
=== Audit for [project_path] ===

SKILLS IN PROJECT .claude/skills/:
  ✓ my-custom-skill        project-specific (no conflict)
  ⚠ decode-ticket          redundant — shared version available
  ⚠ breadcrumb             redundant — shared version available
  ℹ (empty or no dir)      — will be created

SHARED SKILLS AVAILABLE TO LINK:
  + decode-ticket
  + breadcrumb
  + sf-code-standards
  + sf-change-list
  + load-ticket
  + work-session
  + project-setup

PROJECT CLAUDE.md OVERLAP WITH GLOBAL:
  ⚠ "How to help me" section — duplicates global communication style
  ⚠ "Ask, don't assume" — duplicates global coding principles
  ⚠ Code review conventions highlights — now in /sf-code-standards skill
  ✓ "The codebase" section — project-specific, keep
  ✓ Portal filtering pattern description — project-specific, keep

PROPOSED ACTIONS:
  1. Link 7 shared skills into .claude/skills/
  2. Remove 2 redundant project-local skill directories (decode-ticket, breadcrumb)
  3. Slim down project CLAUDE.md — remove 3 duplicate sections
```

### Step 5: Confirm each action separately

Ask the developer:
1. "Proceed with linking shared skills? (all 7, or a subset?)"
2. "Remove the 2 redundant project-local skill directories? They'll be replaced by the shared symlinks."
3. "Show the proposed project CLAUDE.md edit?" — if yes, show a before/after diff, then ask to apply.

**Never take destructive actions without an explicit per-category yes.** Even if the developer said "go ahead and link", confirm the deletion of project-local skills separately, and confirm CLAUDE.md edits separately.

### Step 6: Execute confirmed actions

**Linking:**
```bash
bash /d/claude/claude-shared/scripts/link-project.sh "$PROJECT"
# or with --skills filter if the developer specified a subset
```

**Removing redundant project skills:**
```bash
# For each confirmed redundant skill:
rm -rf "$PROJECT/.claude/skills/<skill_name>"
# Then re-link that specific skill so the symlink replaces what was removed:
bash /d/claude/claude-shared/scripts/link-project.sh "$PROJECT" --skills <skill_name>
```

Important: delete the project-local directory BEFORE linking, since the link script skips existing real directories.

**Slimming CLAUDE.md:** Propose the edited file content first, then write it only after explicit confirmation. Preserve all project-specific content verbatim.

### Step 7: Report what was done

End with a summary:
```
Done.
- Linked: [list of skills]
- Removed project-local: [list]
- Updated: .claude/CLAUDE.md (removed N duplicate sections, kept M project-specific)

Next step: if this is a new project without a tailored CLAUDE.md, run /project-setup
to scan the codebase and generate project-specific config.
```

## Principles

- **Per-category confirmation.** Linking is safe; deletion isn't. Always separate the two.
- **Leave project-specific content alone.** The global config is about shared behavior and Salesforce standards. Anything about the actual codebase stays in the project CLAUDE.md.
- **Preserve git history.** If the project is under git, remind the developer they can `git diff` and revert the CLAUDE.md edit if they don't like it.
- **If you're unsure whether content is duplicate or project-specific, don't flag it.** False negatives (missed duplicates) are cheap — the developer can clean up later. False positives (deleting project-specific stuff) are expensive.
- **Don't invent redundancy.** If a section in the project CLAUDE.md isn't actually in the global CLAUDE.md or in a shared skill, it's not duplicate — it's project-specific content that happens to be similar in topic.
