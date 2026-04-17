#!/bin/bash
# link-project.sh — Link shared skills into a specific project's .claude/ directory
#
# Run in Git Bash on Windows 11 with Developer Mode enabled.
#
# Usage:
#   ./scripts/link-project.sh /path/to/project                 # link all shared skills
#   ./scripts/link-project.sh /path/to/project --skills a,b,c  # link only specified skills
#   ./scripts/link-project.sh /path/to/project --list          # list what's currently linked
#   ./scripts/link-project.sh /path/to/project --unlink        # remove shared symlinks only
#   ./scripts/link-project.sh /path/to/project --unlink a,b    # remove specific shared symlinks
#
# Safe to run repeatedly. Never touches files that aren't symlinks pointing
# at this repo — your project-specific skills, CLAUDE.md, and settings are
# left alone.

set -euo pipefail

SHARED_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SHARED_SKILLS_DIR="$SHARED_DIR/skills"

usage() {
    cat <<'EOF'
Usage:
  link-project.sh <project_path>                   Link all shared skills
  link-project.sh <project_path> --skills a,b,c    Link only specified skills
  link-project.sh <project_path> --list            Show what's currently linked
  link-project.sh <project_path> --unlink          Remove all shared symlinks
  link-project.sh <project_path> --unlink a,b      Remove specific shared symlinks

The script only touches symlinks that point at this shared repo. Your
project-specific files are never modified.
EOF
    exit 1
}

if [ $# -lt 1 ]; then usage; fi

PROJECT_PATH="$1"
shift || true

# Normalize the project path
if [ ! -d "$PROJECT_PATH" ]; then
    echo "ERROR: Project path does not exist: $PROJECT_PATH"
    exit 1
fi
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
TARGET_SKILLS_DIR="$PROJECT_PATH/.claude/skills"

MODE="link"
SKILL_FILTER=""

while [ $# -gt 0 ]; do
    case "$1" in
        --list) MODE="list" ;;
        --unlink)
            MODE="unlink"
            if [ "${2:-}" ] && [[ "${2:-}" != --* ]]; then
                SKILL_FILTER="$2"
                shift
            fi
            ;;
        --skills)
            if [ -z "${2:-}" ]; then echo "ERROR: --skills requires a comma-separated list"; exit 1; fi
            SKILL_FILTER="$2"
            shift
            ;;
        *) echo "ERROR: Unknown argument: $1"; usage ;;
    esac
    shift
done

# --- Helpers ---

is_link_to_shared() {
    # Returns 0 if $1 is a symlink pointing somewhere inside $SHARED_DIR
    local path="$1"
    if [ ! -L "$path" ]; then return 1; fi
    local target
    target=$(readlink "$path")
    case "$target" in
        "$SHARED_DIR"/*|"$SHARED_SKILLS_DIR"/*) return 0 ;;
        *) return 1 ;;
    esac
}

list_available_skills() {
    find "$SHARED_SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort
}

skill_in_filter() {
    # Returns 0 if skill name $1 is in the comma-separated $SKILL_FILTER
    local skill="$1"
    local IFS=','
    for s in $SKILL_FILTER; do
        if [ "$s" = "$skill" ]; then return 0; fi
    done
    return 1
}

# --- Dev mode check (only for link mode) ---

check_developer_mode() {
    local test_target="$TARGET_SKILLS_DIR/.dm_test_target"
    local test_link="$TARGET_SKILLS_DIR/.dm_test_link"
    # Start clean in case a prior run left stragglers (especially copies from silent fallback)
    rm -rf "$test_link" "$test_target" 2>/dev/null || true
    mkdir -p "$test_target"
    # `ln -s` exits 0 on MSYS even when it silently falls back to copying.
    # Verify the created entry is an actual symlink before declaring success.
    if ln -s "$test_target" "$test_link" 2>/dev/null && [ -L "$test_link" ]; then
        rm -f "$test_link"
        rmdir "$test_target"
        return 0
    fi
    # Either ln failed or MSYS made a copy — clean up either form
    rm -rf "$test_link" 2>/dev/null || true
    rmdir "$test_target" 2>/dev/null || true
    return 1
}

# ========================================
# Banner
# ========================================
echo "========================================"
echo "Project: $PROJECT_PATH"
echo "Shared:  $SHARED_DIR"
echo "Mode:    $MODE"
echo "========================================"
echo ""

# ========================================
# LIST mode
# ========================================
if [ "$MODE" = "list" ]; then
    if [ ! -d "$TARGET_SKILLS_DIR" ]; then
        echo "No .claude/skills/ directory in this project."
        exit 0
    fi

    echo "Skills in this project's .claude/skills/:"
    echo ""
    printf "  %-25s %s\n" "NAME" "SOURCE"
    printf "  %-25s %s\n" "----" "------"

    for entry in "$TARGET_SKILLS_DIR"/*/; do
        [ -d "$entry" ] || continue
        name=$(basename "$entry")
        # Strip trailing slash for symlink check
        entry="${entry%/}"
        if is_link_to_shared "$entry"; then
            printf "  %-25s shared (symlink)\n" "$name"
        elif [ -L "$entry" ]; then
            printf "  %-25s symlink (external)\n" "$name"
        else
            printf "  %-25s project-specific\n" "$name"
        fi
    done
    echo ""
    echo "Available shared skills not linked here:"
    for skill in $(list_available_skills); do
        target="$TARGET_SKILLS_DIR/$skill"
        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            echo "  - $skill"
        fi
    done
    exit 0
fi

# ========================================
# UNLINK mode
# ========================================
if [ "$MODE" = "unlink" ]; then
    if [ ! -d "$TARGET_SKILLS_DIR" ]; then
        echo "No .claude/skills/ directory — nothing to unlink."
        exit 0
    fi

    removed=0
    for entry in "$TARGET_SKILLS_DIR"/*/; do
        [ -d "$entry" ] || continue
        entry="${entry%/}"
        name=$(basename "$entry")

        if [ -n "$SKILL_FILTER" ] && ! skill_in_filter "$name"; then
            continue
        fi

        if is_link_to_shared "$entry"; then
            rm "$entry"
            echo "  Removed symlink: $name"
            removed=$((removed + 1))
        fi
    done

    echo ""
    echo "Removed $removed shared symlink(s). Project-specific skills untouched."
    exit 0
fi

# ========================================
# LINK mode (default)
# ========================================

mkdir -p "$TARGET_SKILLS_DIR"

if ! check_developer_mode; then
    echo "ERROR: Cannot create native symlinks in $TARGET_SKILLS_DIR"
    echo ""
    echo "Two things are required on Windows + Git Bash:"
    echo "  1. Developer Mode ON"
    echo "     Settings → System → For Developers → Developer Mode → On"
    echo "  2. MSYS env var set so \`ln -s\` makes real symlinks instead of silently copying"
    echo "     Add to ~/.bashrc:  export MSYS=winsymlinks:nativestrict"
    echo "     Then close and reopen Git Bash."
    echo ""
    echo "Verify with:  echo \"\$MSYS\"   (should print: winsymlinks:nativestrict)"
    echo ""
    echo "Then re-run this script."
    exit 1
fi

# Determine which skills to link
SKILLS_TO_LINK=()
if [ -n "$SKILL_FILTER" ]; then
    # Validate each requested skill exists
    IFS=',' read -ra REQUESTED <<< "$SKILL_FILTER"
    for s in "${REQUESTED[@]}"; do
        if [ -d "$SHARED_SKILLS_DIR/$s" ]; then
            SKILLS_TO_LINK+=("$s")
        else
            echo "  WARN: Skill not found in shared repo: $s"
        fi
    done
else
    while IFS= read -r s; do
        SKILLS_TO_LINK+=("$s")
    done < <(list_available_skills)
fi

echo "Linking ${#SKILLS_TO_LINK[@]} shared skill(s):"
echo ""

linked=0
updated=0
skipped_existing=0

for skill in "${SKILLS_TO_LINK[@]}"; do
    source_path="$SHARED_SKILLS_DIR/$skill"
    target_path="$TARGET_SKILLS_DIR/$skill"

    if [ ! -d "$source_path" ]; then
        echo "  SKIP: $skill (not in shared repo)"
        continue
    fi

    if [ -L "$target_path" ]; then
        if is_link_to_shared "$target_path"; then
            current=$(readlink "$target_path")
            if [ "$current" = "$source_path" ]; then
                linked=$((linked + 1))
                continue
            fi
            rm "$target_path"
            ln -s "$source_path" "$target_path"
            echo "  Updated: $skill (was pointing elsewhere in shared)"
            updated=$((updated + 1))
        else
            echo "  SKIP:    $skill (symlink points outside shared repo — not touching)"
            skipped_existing=$((skipped_existing + 1))
        fi
    elif [ -d "$target_path" ]; then
        echo "  SKIP:    $skill (project-specific directory exists — not touching)"
        skipped_existing=$((skipped_existing + 1))
    elif [ -e "$target_path" ]; then
        echo "  SKIP:    $skill (file exists with this name — not touching)"
        skipped_existing=$((skipped_existing + 1))
    else
        ln -s "$source_path" "$target_path"
        echo "  Linked:  $skill"
        linked=$((linked + 1))
    fi
done

echo ""
echo "Done. $linked linked, $updated updated, $skipped_existing skipped (already project-specific)."
echo ""
echo "Tip: run with --list to see what's currently in this project's .claude/skills/"
