---
name: work-session
description: "Manage the full lifecycle of a developer work session — start, work, pause, resume, stop. Use when the user says 'start a work session', 'start session', 'new session', 'work on [ticket]', 'pick up [task]', 'resume [task]', 'pause session', 'stop session', 'wrap up', 'I'm done for now', 'switching tasks', 'taking a break', 'end of day', 'EOD', 'session checklist', 'workflow checklist', or 'meta checklist'. Also triggers when pasting a ticket to work through, or saying 'I need to stop working on this' or 'let me capture where I am'."
---

# Work Session

Manage the full lifecycle of a developer work session: start, work, pause, resume, stop. Externalizes executive function overhead so the developer can focus on the actual work.

## Why this exists

Context is expensive to rebuild. Every time a developer stops and comes back, they pay a re-entry tax. For developers with ADHD, this tax is higher because working memory doesn't hold state across breaks. This skill makes context capture prompted and structured instead of self-initiated.

## Session phases

### 1. START

**New task (ticket provided):**
- Use the decode-ticket skill to decode into implementation-ready language
- Present the meta checklist

**New task (from queue):**
- Check `~/repos/claude-shared/queue/` for pending decoded tickets
- If found, load the oldest and present as the implementation plan
- Present the meta checklist

**Resuming a task:**
- Ask for previous session notes or breadcrumb
- Ask if there are new inputs since last session
- Summarize current state: where they left off, what's next, open unknowns
- Present the meta checklist

### 2. WORK

Mostly hands-off. Provide on request:

**Meta checklist:**
> - [ ] Ticket decoded / task understood
> - [ ] Unknowns identified and tracked
> - [ ] Working in the right branch
> - [ ] Tests considered
> - [ ] Notes captured before stopping
> - [ ] Time logged
> - [ ] Status updated

### 3. PAUSE

Ask **one at a time:**
1. "What did you get done?"
2. "Where are you stuck or what's the next concrete step?"
3. "Anything that came up that isn't captured in the ticket?"

Format:
```
**Session note — [date]**
**Done:** [what they accomplished]
**Next step:** [where to pick up]
**Notes:** [blockers, decisions, discoveries]
```

Then: "Don't forget to log your time." / "Does the task status need updating?"

### 4. STOP

- Ask if there's anything to capture for documentation
- Remind about time logging and status update

## Principles

- **Prompt, don't lecture.** One question at a time. Accept short answers.
- **Low bar for capture.** One sentence is infinitely better than nothing.
- **Respect awareness.** Single mention for reminders. Don't nag.
- **Flexible entry.** Formal or informal triggers both work.
- **Keep the checklist light.** Reference card, not mandate.
