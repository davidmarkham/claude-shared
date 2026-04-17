#!/bin/bash
# sync.sh — Symlink shared Claude Code config to ~/.claude/
#
# Run in Git Bash on Windows 11 with Developer Mode enabled.
# Developer Mode allows symlink creation without admin elevation.
#
# Usage: ./scripts/sync.sh
#
# Safe to run repeatedly. Skips existing real directories.
# Pass --force to recreate existing symlinks.

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_HOME="$HOME/.claude"
FORCE=false

if [ "${1:-}" = "--force" ]; then
    FORCE=true
fi

echo "========================================"
echo "Claude Shared Config — Sync"
echo "========================================"
echo "Source: $SHARED_DIR"
echo "Target: $CLAUDE_HOME"
echo ""

# --- Check Developer Mode (best-effort) ---
# Git Bash symlinks require Developer Mode on Windows 11
# We test by attempting to create and remove a symlink
test_symlink_support() {
    local test_target="$CLAUDE_HOME/.symlink_test_target"
    local test_link="$CLAUDE_HOME/.symlink_test_link"
    mkdir -p "$test_target"
    if ln -s "$test_target" "$test_link" 2>/dev/null; then
        rm -f "$test_link"
        rmdir "$test_target"
        return 0
    else
        rmdir "$test_target" 2>/dev/null
        return 1
    fi
}

mkdir -p "$CLAUDE_HOME"

if ! test_symlink_support; then
    echo "ERROR: Cannot create symlinks."
    echo "Enable Developer Mode: Settings → System → For Developers → Developer Mode"
    echo "Then re-run this script."
    exit 1
fi

# --- Skills ---
echo "Skills:"
mkdir -p "$CLAUDE_HOME/skills"
linked=0
skipped=0
updated=0

for skill_dir in "$SHARED_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    target="$CLAUDE_HOME/skills/$skill_name"

    if [ -L "$target" ]; then
        if [ "$FORCE" = true ]; then
            rm "$target"
            ln -s "$skill_dir" "$target"
            echo "  Refreshed: $skill_name"
            ((updated++))
        else
            ((linked++))
        fi
    elif [ -d "$target" ]; then
        echo "  SKIP: $skill_name (real directory — project-specific?)"
        ((skipped++))
    else
        ln -s "$skill_dir" "$target"
        echo "  Linked: $skill_name"
        ((linked++))
    fi
done

echo "  ($linked linked, $updated updated, $skipped skipped)"
echo ""

# --- Global CLAUDE.md ---
echo "CLAUDE.md:"
CLAUDE_MD_TARGET="$CLAUDE_HOME/CLAUDE.md"

if [ -f "$SHARED_DIR/CLAUDE.md" ]; then
    if [ -L "$CLAUDE_MD_TARGET" ]; then
        if [ "$FORCE" = true ]; then
            rm "$CLAUDE_MD_TARGET"
            ln -s "$SHARED_DIR/CLAUDE.md" "$CLAUDE_MD_TARGET"
            echo "  Refreshed"
        else
            echo "  Already linked"
        fi
    elif [ -f "$CLAUDE_MD_TARGET" ]; then
        echo "  EXISTS as real file — not overwriting"
        echo "  To use shared version: rm '$CLAUDE_MD_TARGET' && re-run sync"
    else
        ln -s "$SHARED_DIR/CLAUDE.md" "$CLAUDE_MD_TARGET"
        echo "  Linked"
    fi
fi
echo ""

# --- Queue status ---
echo "Queue:"
QUEUE_DIR="$SHARED_DIR/queue"
pending=$(find "$QUEUE_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
archived=$(find "$QUEUE_DIR/archive" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  Pending:  $pending"
echo "  Archived: $archived"
echo ""

echo "========================================"
echo "Done. Shared config is live."
echo "========================================"
