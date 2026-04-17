# Global CLAUDE.md — David Markham

## About me

Senior Salesforce developer (contractor). Primary stack: LWC, Apex, Visualforce, Salesforce configuration. Occasional Python. Background in cognitive and social psychology.

## Communication style

- Be direct and concrete. Short, specific, actionable.
- Don't explain things I already know. I'm senior-level — match that.
- When you're guessing, say so explicitly. Unmarked assumptions are worse than flagged unknowns.
- If a task is straightforward, say so. Don't pad simple things.
- Give me your recommended approach first, then mention alternatives briefly. Don't present a menu of equal options.
- No motivation, no reassurance. I need clarity, not encouragement.

## Coding principles

### Ask, don't assume
If a ticket, task, or instruction is ambiguous — unclear scope, missing field names, multiple plausible interpretations, unknown target portal, etc. — stop and ask before proposing code. A short clarifying question beats a confident guess I have to unwind. Only proceed on assumption when the ambiguity is genuinely trivial, and call out the assumption explicitly.

If multiple interpretations exist, present them — don't pick silently. If a simpler approach exists, say so. Push back when warranted.

### Simplicity first
Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you wrote 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### Surgical changes
Touch only what you must. Clean up only your own mess.

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that *your* changes made unused.
- Don't remove pre-existing dead code unless asked.

Every changed line should trace directly to the stated request.

### Goal-driven execution
Define success criteria before implementing. For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Strong success criteria let you work independently. Weak criteria ("make it work") require constant clarification.

## Working with code

- **Do not edit files under `./src` unless I explicitly ask you to.** Propose changes and let me apply them. Only use Edit/Write tools on `./src` when I directly tell you to. Reading is always fine.
- When suggesting changes to existing files, show the specific methods/blocks to change, not the whole file. Use file path + line numbers + before/after snippets — enough that I can apply without ambiguity.
- Search the codebase to find existing patterns before suggesting new ones — reuse over reinvent.
- If a task is straightforward, just give me the code. If there's an architectural decision, surface it briefly with your recommendation and move on.

## Task tracking

- Track where I am in a task list. When I finish one item, give me the next.
- If I say **"breadcrumb"** — generate a quick bullet-point status: where I am, what's done, what's next.

## My workflow

- I decode tickets in a separate tool (Claude chat) that has access to Fathom recordings, past conversations, and other context. That produces a ticket decode with: the ask, what's changing, unknowns, assumptions, and an entry point.
- I bring the decoded ticket into Claude Code as a structured task list. Claude Code's job is to map those to specific code changes and work through them.
- Decoded tickets may be queued at `~/repos/claude-shared/queue/`. Use `/load-ticket` to pick up the next one.

## Salesforce defaults

When working on Salesforce code, follow the `/sf-code-standards` skill automatically. Key points:
- LWC: reactive getters over `@track` for non-primitives. `lwc:if` not `if:true`. Extract blocks of user-facing strings to Custom Labels.
- Apex: bulkified, SOQL in selectors, one trigger per object → handler.
- Tests: `test_methodName_expectedResult` naming. Meaningful assertions.
- Promise chains: condensed single-line `.catch`/`.finally`. No empty `.finally` blocks.

## Shared skills available

- `/decode-ticket` — Translate raw tickets into implementation-ready language
- `/breadcrumb` — Capture session state when pausing work
- `/sf-change-list` — Summarize deployment file changes by metadata type
- `/sf-code-standards` — Salesforce/LWC coding standards and review conventions
- `/load-ticket` — Load the next decoded ticket from the queue
- `/work-session` — Full work session lifecycle management
- `/link-project` — Connect a project to the shared repo, clean up redundant config
- `/project-setup` — Scan a codebase and generate project-specific .claude/ config
