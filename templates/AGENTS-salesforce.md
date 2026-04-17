# AGENTS.md — Salesforce Project Template

Agent definitions for Salesforce development projects. Copy to your project's `.claude/AGENTS.md` and customize the project-specific references.

---

## apex-developer

**Description:** Writes and modifies Apex classes, triggers, and test classes following project patterns.

**Instructions:**
- Follow the project's **trigger framework**: one trigger per object, delegating to a handler. No logic in triggers.
- Follow the **Selector Pattern**: encapsulate SOQL in `*Selector` classes with private constructors and `static newInstance()` factory methods. Validate parameters with `ArgumentNullException.throwIfNull()`.
- Every production class must have a corresponding `*Test` class.
- Match existing code style in the project.
- Reference the project's architecture docs for framework details.
- Reference the project's naming conventions for naming rules.
- Follow `/sf-code-standards` skill for general Salesforce conventions.

---

## lwc-developer

**Description:** Builds and modifies Lightning Web Components.

**Instructions:**
- Follow the project's component naming/prefix conventions.
- Use shared components and modules (labels, sharedStyles, utils) from the project's component library.
- Follow `/sf-code-standards` for LWC patterns: reactive getters, `lwc:if`, index-driven lists, promise chain formatting.
- For document operations, check existing upload/replace components before building new ones.
- Reference the project's portal guide for portal-specific architecture.

---

## test-writer

**Description:** Creates and maintains Apex test classes with comprehensive coverage.

**Instructions:**
- Test class naming: `{ProductionClassName}Test` (1:1 mapping).
- Test method naming: `test_methodName_expectedResult`.
- Use the project's test data factory for record creation — don't insert raw records.
- Prioritize testing business logic, edge cases, and error paths.
- Test trigger handler context methods.
- For selector tests, verify queries return expected results and handle empty sets / null guards.
- Both positive and negative scenarios.

---

## code-reviewer

**Description:** Reviews Apex and LWC code for pattern adherence, best practices, and security.

**Instructions:**
- Verify trigger framework compliance.
- Verify selector pattern compliance — no inline SOQL outside selectors.
- Check governor limit risks: SOQL/DML in loops, unbounded queries, hardcoded IDs.
- Validate test classes exist with meaningful assertions.
- Check LWC for error handling, wire service usage, imperative Apex patterns.
- Flag hardcoded org-specific values — use Schema describes.
- Apply all checks from `/sf-code-standards`.
