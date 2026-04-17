---
name: breadcrumb
description: "Capture session state when pausing or stepping away from work. Use when the developer says 'breadcrumb', 'capture where I am', 'I need to step away', 'pause', 'save my place', 'switching tasks', or 'where was I'. Also triggers on 'what was I doing' when resuming. Generates a scannable note for Jira, Todoist, or a file."
---

# Breadcrumb

Generate a quick context-capture note when the developer pauses work. The note should let them resume cold — no memory required.

## When pausing

Ask these **one at a time** (not as a wall):

1. "What did you get done?" (partial answers fine — "started the component" counts)
2. "What's the next concrete step?" (most important — future-them needs this)
3. "Anything come up that isn't in the ticket?" (new unknowns, decisions, gotchas)

Format the output:

```
**Breadcrumb — [date/time]**
**Task:** [ticket ID or brief description if known]
**Done:** [what was accomplished]
**Next step:** [where to pick up — be specific: file, method, line of thinking]
**Notes:** [blockers, decisions made, things discovered]
**Open in editor:** [file path or search term to get back to the right spot]
```

## When resuming

If the developer shares a previous breadcrumb or asks "where was I":
- Read the breadcrumb
- Summarize the state in 2-3 sentences
- State the next step clearly
- Ask if anything has changed since the breadcrumb was written

## Principles

- A one-line breadcrumb is better than no breadcrumb. Don't make capture feel heavy.
- "Next step" is the most valuable field. If only one thing gets captured, it's this.
- "Not sure what's next" is valid — capture as "Next step: TBD — need to [think about X / ask Y / investigate Z]"
- Keep it scannable. Bullet points, not paragraphs.
- Don't nag about time logging or status updates — that's the work-session skill's job.
