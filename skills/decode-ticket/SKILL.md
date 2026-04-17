---
name: decode-ticket
description: "Translate work tickets, task descriptions, Jira issues, or user stories from problem-space language into solution-space language. Use this skill whenever a user pastes a ticket, task, bug report, feature request, or work item and wants help understanding what to build, where to start, or how to break it down. Also triggers when a user says 'decode this', 'what does this ticket mean', 'help me break this down', 'what's the first step', or pastes a block of requirements text. Works for any tech stack but defaults to Salesforce (LWC, Apex, Visualforce) when the domain is ambiguous."
---

# Ticket Decoder

Translate tickets from problem-space language into solution-space language so the developer can reach execution-readiness faster.

## Why this exists

Tickets describe problems and desired outcomes. Developers need to know what files to touch, what logic to change, and where to start typing. The gap between those two things — decoding — is real cognitive work that happens before any code gets written. This skill externalizes that decoding.

## Output format

For every ticket, produce up to five sections. Skip any section with nothing to put in it.

### 1. The ask
One or two sentences maximum. What is actually being done, stated in plain implementation language. Not a restatement of the ticket — a translation of it.

### 2. What you're changing
A numbered list of the concrete deliverables: files, fields, config changes, logic changes. One line per item. Be specific (name the object, the component, the method) when the ticket gives enough information. When it doesn't, describe what the developer needs to find.

### 3. Unknowns to resolve
Things that can't be determined from the ticket alone and that affect the implementation approach. Only include items that are genuine blockers or decision points. For each one, note what the developer should search for or who to ask.

Don't list things the developer will obviously discover in the first five minutes of looking at the code.

### 4. Assumptions I'm making
Inferences that are reasonable but not confirmed by the ticket. These are things where you're filling in gaps based on how systems like this typically work. For each assumption, note the risk if it's wrong — usually "low" or "medium" with a brief reason.

### 5. Entry point
The single first concrete action. What to search for in the codebase, what file to open, what to create. Specific enough that the developer can open their editor and start without further planning.

## Expanded format

When the developer asks for more detail — phrases like "more info", "break this down further", "give me the full breakdown", "expand on that", or "walk me through the implementation" — switch to the expanded format:

### 1. What the ticket explicitly says
The literal stated requirements. No interpretation, just what's written.

### 2. What the ticket assumes I know
Domain context, user workflows, business logic that isn't stated. Flag each inference and explain why it's reasonable.

### 3. What's genuinely ambiguous
Questions that can't be resolved from the ticket. For each, suggest a reasonable default assumption and note the risk if wrong.

### 4. Implementation steps
Concrete, ordered steps using the developer's stack language. For Salesforce/LWC work: components, data sources, Apex, markup, events/communication patterns, existing patterns to stay consistent with.

### 5. Entry point
Same as the lean format — the single first concrete action.

## Principles

- **Every sentence must be actionable or informational.** No motivation, no padding.
- **Separate known from inferred from unknown.** That's the whole value.
- **Use the developer's stack language.** "Apex class" not "backend service."
- **Don't restate the ticket.** Translate, don't summarize.
- **Don't pad simple tickets.** Three lines is correct if that's all it needs.
- **Flag inferences distinctly.** Don't present guesses as facts.
