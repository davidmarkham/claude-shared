---
name: load-ticket
description: "Load a decoded ticket from the queue and begin implementation. Use when the developer says 'load ticket', 'next ticket', 'grab a ticket', 'what's in the queue', or 'pick up from chat'. Reads decoded tickets pushed from the Claude chat app."
allowed-tools: Bash(ls *), Bash(cat *), Bash(mv *), Bash(mkdir *)
---

# Load Ticket from Queue

Read the next decoded ticket from the shared queue and use it as the implementation plan.

## Queue location

`~/repos/claude-shared/queue/`

## On invocation

1. List files in the queue directory:
   !`ls -1t ~/repos/claude-shared/queue/*.md 2>/dev/null | grep -v EXAMPLE || echo "EMPTY"`

2. If EMPTY: Tell the developer there are no tickets in the queue. Suggest decoding one in the Claude chat app first.

3. If files exist:
   - Show the list of available tickets (filename = date + ticket ID + brief description)
   - If only one ticket, load it automatically
   - If multiple, ask which one to load (or load the oldest by default)

4. After loading:
   - Display the decoded ticket content
   - Ask: "Ready to start, or want to discuss anything first?"
   - When ready, identify the entry point from the decoded ticket and begin

5. After the developer confirms they've started:
   - Archive the ticket file:
     ```
     mkdir -p ~/repos/claude-shared/queue/archive
     mv [file] ~/repos/claude-shared/queue/archive/
     ```
   - This prevents reloading the same ticket
   - The file remains in git history since queue is tracked

## File naming convention

`YYYY-MM-DD_[ticket-id]_[brief-slug].md`

Examples:
- `2026-04-09_JIRA-1234_wpf-scheduled-date.md`
- `2026-04-09_SCPE-export-concatenation.md`
- `2026-04-09_misc_contact-field-addition.md`

## Ticket file format

Each file contains a fully decoded ticket (output from Claude chat), including:
- The ask
- What you're changing
- Unknowns to resolve
- Assumptions
- Entry point
- Any additional context from the chat conversation (Fathom notes, client clarifications, etc.)

## Principles

- The decoded ticket is the plan. Don't re-decode — it was decoded with full conversational context in the chat app.
- If the decoded ticket has unknowns, surface them before starting implementation.
- The developer may have added handwritten notes to the file. Respect and incorporate those.
