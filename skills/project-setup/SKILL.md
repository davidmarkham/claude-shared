---
name: project-setup
description: "Bootstrap a new Salesforce project's .claude/ configuration by scanning the codebase. Use when setting up Claude Code in a new project for the first time. Triggers on 'setup project', 'init project', 'bootstrap project', 'new project setup', or 'scan codebase'. Generates a project-specific CLAUDE.md, AGENTS.md, and settings_local.json based on what's actually in the code."
allowed-tools: Bash(find *), Bash(ls *), Bash(wc *), Bash(grep *), Bash(head *), Bash(cat *), Bash(mkdir *), Write, Edit
---

# Project Setup

Scan a Salesforce codebase and generate project-specific `.claude/` configuration. This skill produces files that layer on top of the shared global config at `~/.claude/`.

## Prerequisites

The shared config must be synced first (`~/repos/claude-shared/scripts/sync.sh`). This skill generates only the **project-specific** layer — shared skills, code standards, and behavioral rules come from the global config.

## On invocation

### Step 1: Detect project basics

Scan the project root and determine:

```bash
# Source format
ls -d sfdx-project.json 2>/dev/null && echo "SFDX" || echo "MDAPI"

# Source root (sfdx vs mdapi)
# SFDX: force-app/main/default/ or similar (check sfdx-project.json)
# MDAPI: src/

# Find the source root
find . -maxdepth 3 -name "package.xml" -type f 2>/dev/null
find . -maxdepth 1 -name "sfdx-project.json" -type f 2>/dev/null
```

Ask the developer to confirm:
- **Project name** (for the CLAUDE.md header)
- **Client/org name** (if not obvious from repo name)
- **Source root path** (confirm what was auto-detected)

### Step 2: Scan the codebase

Run these scans to characterize the project:

```bash
SRC="<detected_source_root>"

# Counts by metadata type
echo "=== Apex classes ===" && find "$SRC" -path "*/classes/*.cls" -not -name "*-meta.xml" | wc -l
echo "=== Test classes ===" && find "$SRC" -path "*/classes/*Test.cls" -not -name "*-meta.xml" | wc -l
echo "=== LWC ===" && find "$SRC" -path "*/lwc/*" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l
echo "=== Aura ===" && find "$SRC" -path "*/aura/*" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l
echo "=== Triggers ===" && find "$SRC" -path "*/triggers/*.trigger" -not -name "*-meta.xml" | wc -l
echo "=== VF Pages ===" && find "$SRC" -path "*/pages/*.page" -not -name "*-meta.xml" 2>/dev/null | wc -l
echo "=== Flows ===" && find "$SRC" -path "*/flows/*.flow" -not -name "*-meta.xml" 2>/dev/null | wc -l
echo "=== Static Resources ===" && find "$SRC" -path "*/staticresources/*" -not -name "*-meta.xml" -type f 2>/dev/null | wc -l

# Trigger framework detection
echo "=== Trigger framework ===" 
grep -rl "TriggerFactory\|TriggerHandler\|TriggerDispatcher\|fflib_SObjectDomain" "$SRC/classes/" 2>/dev/null | head -5
# Check first trigger to see delegation pattern
find "$SRC/triggers/" -name "*.trigger" -not -name "dlrs_*" 2>/dev/null | head -1 | xargs head -10 2>/dev/null

# Selector pattern detection
echo "=== Selectors ===" 
find "$SRC" -path "*/classes/*Selector.cls" | head -10

# Service layer detection
echo "=== Services ===" 
find "$SRC" -path "*/classes/*Service.cls" | head -10

# Controller pattern detection
echo "=== Controllers ===" 
find "$SRC" -path "*/classes/*Controller.cls" | head -10

# Model/DTO pattern
echo "=== Models ===" 
find "$SRC" -path "*/classes/*Model.cls" -o -path "*/classes/*DTO.cls" | head -10

# LWC naming prefixes (detect portal groupings)
echo "=== LWC prefixes ===" 
find "$SRC" -path "*/lwc/*" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sed 's/[A-Z].*//' | sort | uniq -c | sort -rn | head -10

# Shared LWC modules (utils, labels, sharedStyles)
echo "=== Shared LWC modules ===" 
for mod in utils labels sharedStyles shared; do
    find "$SRC" -path "*/lwc/$mod" -type d 2>/dev/null
done

# Key integrations (Box, PowerBI, external callouts)
echo "=== Integrations ===" 
grep -rl "HttpRequest\|Http()\|callout\|BoxService\|powerBI\|NamedCredential" "$SRC/classes/" 2>/dev/null | head -10

# DLRS triggers
echo "=== DLRS ===" 
find "$SRC/triggers/" -name "dlrs_*" 2>/dev/null | wc -l

# Test data factory
echo "=== Test data factory ===" 
find "$SRC" -path "*/classes/TestDataFactory*" -o -path "*/classes/*TestFactory*" -o -path "*/classes/*TestHelper*" 2>/dev/null | head -5

# Custom settings / custom metadata
echo "=== Custom settings usage ===" 
grep -rl "getInstance\|getOrgDefaults\|__mdt\b" "$SRC/classes/" 2>/dev/null | head -5
```

### Step 3: Ask targeted questions

Based on scan results, ask **only** what can't be auto-detected:

- "I found LWC components grouped by prefix: `institution*` (34), `evaluator*` (18), `commissioner*` (12). Are these Experience Cloud portals? Any others?"
- "The trigger framework delegates to `TriggerFactory.createAndExecuteHandler()`. Is this the pattern for all new triggers?" (only if detected)
- "I found Box.com integration classes. Any other external integrations I should know about?"
- "Are there deployment tools/processes I should know about? (CI/CD, Copado, Illuminated Cloud, change sets, etc.)"
- "Any auto-generated code I should never manually edit?" (if DLRS detected, confirm; ask about others)

Keep it to 3-5 questions max. Don't ask about things the scan already answered.

### Step 4: Generate project config

Create `.claude/` directory and files:

#### `.claude/CLAUDE.md`

```markdown
# CLAUDE.md — [Project Name]

## Project Overview

[One paragraph: what this project is, what it does, who uses it]

**Source format:** [SFDX / Metadata API]
**Source root:** `[path]/`

## Project Structure

```
[src or force-app]/
├── classes/        # Apex classes ([N]) + test classes ([N])
├── lwc/            # Lightning Web Components ([N])
├── aura/           # Aura components ([N]) [if any]
├── triggers/       # Apex triggers ([N])
[... only include directories that exist]
```

## Architecture & Patterns

### Trigger Framework
[Detected pattern — e.g., "TriggerFactory.createAndExecuteHandler()" or "fflib domain layer"]

### Data Access
[Detected pattern — e.g., "Selector classes with newInstance() factory" or "inline SOQL in controllers"]

### LWC Organization
[Detected prefixes/portal groupings]

### Shared Components
[List detected shared modules: utils, labels, sharedStyles, data tables, etc.]

### Key Integrations
[Detected external integrations]

## Important Notes

- [Auto-generated code warnings (DLRS, managed packages)]
- [Deployment method]
- [Any other project-specific constraints]
```

Omit any section that doesn't apply. Keep it concise — this is a reference card, not documentation.

#### `.claude/AGENTS.md`

Start from the shared template at `~/repos/claude-shared/templates/AGENTS-salesforce.md`. Customize with project-specific details:

- Replace generic references with actual class names from the scan
- Add project-specific agents (e.g., `box-integration`, `annual-report`) based on detected integration points
- Reference actual doc file paths if they exist in the project

#### `.claude/settings_local.json`

Generate permission rules scoped to this project's paths:

```json
{
  "permissions": {
    "allow": [
      "Bash(grep -rl ... \"<project_path>/src/classes/\")",
      "Bash(find \"<project_path>/src\" ...)"
    ]
  }
}
```

Base the grep patterns on what was actually found useful during the scan — LWC import tracing, selector detection, shared component usage.

### Step 5: Present results

Show the developer what was generated:
- Summary of what was detected
- The generated CLAUDE.md (for review before writing)
- The generated AGENTS.md (for review)
- The settings_local.json (for review)

Ask: "Look good? I'll write these to `.claude/`. Anything to add or change?"

Only write the files after the developer confirms.

## Principles

- **Detect, don't assume.** Every claim in the generated CLAUDE.md should come from the scan, not from patterns you've seen in other projects. If the project doesn't use selectors, don't document a selector pattern.
- **Ask only what you can't scan.** The developer's time is the scarce resource. Scan first, ask about gaps.
- **Keep it minimal.** The project CLAUDE.md supplements the global config. Don't duplicate shared standards — just reference them. "Follow `/sf-code-standards` for coding conventions" is enough.
- **Counts don't need to be exact.** "~300 Apex classes" is fine. The point is giving Claude Code a sense of project scale, not an inventory.
- **Existing .claude/ config takes precedence.** If the project already has a `.claude/CLAUDE.md`, show the developer a diff of what the scan would add, don't overwrite.
