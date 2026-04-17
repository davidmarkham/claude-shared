---
name: sf-code-standards
description: "Salesforce and LWC coding standards, code review conventions, and best practices. Auto-invoke when writing, reviewing, or generating Salesforce code (Apex, LWC, Aura, Visualforce, Flows, configuration). Also triggers on 'code review', 'standards check', 'best practices', or 'conventions' in a Salesforce context. Covers LWC reactivity patterns, template directives, promise chain formatting, Apex test naming, and index-driven list rendering."
---

# Salesforce Code Standards & Review Conventions

Apply these automatically when writing or reviewing Salesforce code. These are the standards enforced in code review — follow them proactively so reviews stay focused on logic, not nits.

---

## LWC: prefer reactive getters over `@track`

**Rule:** Use `@track` only for flat primitives (strings, booleans, numbers). For anything else — especially slices of an Apex-returned model object — expose the value through a reactive `get`.

**Why:** LWC's DOM diffing only guarantees reactive re-rendering for deep object changes when the value is read through a getter. `@track` on deep objects is not guaranteed to propagate DOM updates without a page refresh.

**Pattern:**

```js
export default class MyComponent extends LightningElement {
    returnModel;  // Plain private field, no @track

    get helpText() {
        return this.returnModel?.helpText?.map(help => ({
            title: help.title,
            content: help.content,
            contentId: `sect${help.id}`,
        })) || [];
    }
}
```

Template binds to `{helpText}`, not a `@track`'d copy.

**How to apply:**
- New components: build with this pattern from the start.
- Existing components touched in a PR: don't add new `@track` for non-primitives.
- Don't refactor existing `@track` en masse unless that's the PR's purpose.

---

## LWC templates: use `lwc:if`, not `if:true`

**Rule:** All net-new conditionals use `lwc:if` / `lwc:elseif` / `lwc:else`. Never `if:true` / `if:false` in new code.

**Opportunistic conversion:** When touching an existing `if:true` / `if:false` tag for any reason, convert it while you're there. Don't sweep unrelated tags.

---

## LWC iterable lists: index-driven map, not numbered fields on the FE

**Rule:** When rendering items backed by numbered Apex fields (e.g., `Main_Campus_Distance_2__c`, `_3__c`), build a single array of row objects on the FE — each with `index`, `label`, `name`, `value`, `error` — and iterate it. Pass the index/field name back to Apex; let Apex map index → numbered field in one place.

**Why:** Per-index `showItem1` / `showItem2` flags and template branches bloat markup and JS.

**Pattern:**

```js
get campusMap() { return this.currentCampusMap; }

this.currentCampusMap = Object.keys(this.apexReturnModel?.campusMap ?? {}).reduce((acc, currKey, i) => {
    acc.push({
        campusLabel: `Campus ${i} Simple Label`,
        campusIndex: i,
        campusError: false,
        campusName: currKey,
        campusValue: this.apexReturnModel.campusMap[currKey] ?? null,
    });
    return acc;
}, []);
```

On save, send `{ index, name, value }` per row back to Apex. Apex has a single switch/if-else mapping field name → numbered field assignment.

---

## Formatting: condense one-line functions and trim whitespace

**Standard promise-chain format:**

```js
getDetailPageModel({ reviewId: recordId })
    .then(result => {
        this.returnModel = result;
        this.helpText = result.helpText;
    })
    .catch(error => handleError(error, this.labels.Error_Header, this))
    .finally(() => this.isLoading = false);
```

Rules:
- `.then` with multiple statements → braced block
- `.catch` / `.finally` with single statement → braceless arrow, one line
- **`.catch` error message:** `error.body?.message || 'fallback string'`
- **No empty `.finally(() => {})` blocks** — delete the call entirely
- Clean up extra blank lines and over-indented blocks in Apex and JS

---

## LWC: extract user-facing strings to Custom Labels

**Rule:** When a template (or JS) contains more than a handful of user-facing strings — section headers, field labels, button text, messages — extract them to Custom Labels and surface via a `labels` import. Inline string literals are fine for one-off text; a block of them is a signal to extract.

**Why:** Labels can be tweaked by admins without a deploy, support translation, and keep markup readable.

**Naming:** Scope labels to the component and keep them descriptive — e.g. `institutionEvaluatorCatQEP`, not generic `QEP`.

**Pattern:**

```js
import QEP_EVALUATOR     from '@salesforce/label/c.institutionEvaluatorCatQEP';
import SACSCOC_EVALUATOR from '@salesforce/label/c.institutionEvaluatorCatSACSCOC';

export default class InstitutionEvaluatorDetailModal extends LightningElement {
    labels = {
        qepEvaluator:     QEP_EVALUATOR,
        sacscocEvaluator: SACSCOC_EVALUATOR,
    };
}
```

```html
<span class="slds-form-element__label">{labels.qepEvaluator}</span>
```

**How to apply:**
- Net-new components with a block of user-facing strings: labels from the start.
- Existing components: don't sweep. When adding a substantial new strings block, use labels for the new block even if the rest is inline.
- When proposing new labels, check the project's label storage (MDAPI `CustomLabels.labels` or SFDX `.meta-label.xml` files) for existing ones first — reuse over duplicate.

---

## LWC data access

- `@wire` for read operations (reactive, cacheable)
- Imperative Apex for write operations and complex flows
- Don't mix wire and imperative for the same data source

## LWC component communication

- Parent → child: `@api` properties
- Child → parent: `CustomEvent` dispatch
- Sibling/unrelated: Lightning Message Service (LMS), not pubsub

---

## Apex

**Bulkification:** Handle collections. No SOQL or DML inside loops.

**SOQL placement:** Selector classes only. Private constructor, `static newInstance()`, `ArgumentNullException.throwIfNull()` for params.

**Trigger pattern:** One trigger per object → handler. No logic in triggers.

**Security:**
- `WITH SECURITY_ENFORCED` for reads
- `Security.stripInaccessible()` for DML
- Never bypass sharing without explicit justification

**Governor limits:** Avoid full table scans. Respect 100 SOQL / 150 DML / 10 callout. `Limits` class checks in batch/queueable.

**Error handling:** `Database.SaveResult` for partial success. Custom exceptions with meaningful messages.

**Naming:** Classes `PascalCase`, methods `camelCase`, constants `UPPER_SNAKE_CASE`.

**Test naming:** `test_methodName_expectedResult` — literal `test` + method/scenario + expected outcome.

**Tests:** Every class gets a test class. `@TestSetup` for shared data. Bulk (200+) for triggers. Positive and negative cases. Meaningful assertions.

---

## Fields, Objects, Config

- Custom fields: `Snake_Case__c`
- Custom objects: `Snake_Case__c`
- Relationships: name after target (`Primary_Contact__c`)
- Before-save flows for stamps/validation; after-save for related record DML
- Flow naming: `[Object] - [Trigger] - [Purpose]`
- Permission Sets over Profiles
- Field Sets for dynamic display
- Custom Metadata Types over Custom Settings
- Named Credentials for callouts

---

## Quick checklist — new LWC

- [ ] `returnModel` is a plain private field, no `@track`
- [ ] Template-bound values from `returnModel` via `get` accessors
- [ ] `@track` only for flat primitives
- [ ] Template uses `lwc:if` / `lwc:elseif` / `lwc:else`
- [ ] Numbered-field lists use index-driven array, not per-index branches
- [ ] Blocks of user-facing strings pulled from Custom Labels, not hardcoded in template
- [ ] Promise chains use condensed format
- [ ] `.catch` uses `error.body?.message || 'fallback'`
- [ ] No empty `.finally(() => {})` blocks
- [ ] No stray blank lines or over-indented blocks
- [ ] Any `if:true` touched was converted to `lwc:if`

## Quick checklist — Apex

- [ ] No SOQL/DML inside loops
- [ ] SOQL in Selector classes
- [ ] Triggers use factory/handler pattern
- [ ] No hardcoded IDs — Schema describes instead
- [ ] Parameter validation via `throwIfNull()` or equivalent
- [ ] Bulkified for 200+ records
- [ ] Test class exists with meaningful assertions
- [ ] Test methods: `test_methodName_expectedResult`
- [ ] Future/Queueable guard against recursion
- [ ] No callouts from trigger context without async
