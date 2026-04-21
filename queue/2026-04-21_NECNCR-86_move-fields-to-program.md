# NECNCR-86

*Decoded 2026-04-21*

## Layer 1: What the ticket explicitly says

**Your scope (the "Code to do for David Markham" section):**
1. Add new/changed fields to the Program page in the Institution Portal (per mockup)
2. Allow users to edit all fields in the modal during Annual Report period
3. Make fields editable in the table via inline editing
4. Make finalize button submittable without requiring CIP Code

**Not your scope (but upstream dependencies — confirmed deployed to sandbox):**
- Field moves from Annual Report → Program object
- Deleting "Credential Outcomes", creating 5 new percentage fields
- Converting "Labor Market Outcomes" to text field
- Creating "Other Outcomes Measures" text area

## Layer 2: What the ticket assumes you know

- **"Institution Portal" = the NECHE member-facing portal** where institutions (like "Test College of Questionable Learning") edit their own data. The mockup shows the `/Programs` tab with a Non-Credit Programs list and an edit modal.
- **"Annual Report period" is a gated state.** Most of the time these fields are read-only; during AR period they become editable. There's almost certainly existing logic somewhere (a flag on a parent object, a date range check, or a custom setting/metadata) that determines "are we in AR period right now?" — find and reuse it, don't invent new logic.
- **The modal is an existing LWC** (or set of LWCs) handling the Program edit view. Extending it, not building from scratch.
- **Inline editing in the table** — the summary table at the top of the mockup (Program Name / Non-Credit Type / Headcount / Status / #of Completers) has pencil icons on Headcount, Status, and #of Completers. Those three are the inline-editable fields during AR period per callout #1.
- **The yellow callouts "1"** in the mockup mark the fields editable during AR period: **Status, Headcount, Number of Completers, Program Offered at**.
- **"Finalize button"** — existing finalize action (likely on the Annual Report or the Program list) currently blocking submission because it validates CIP Code presence. CIP Code is a Career Cluster-adjacent field that apparently isn't required for Non-Credit programs.

## Layer 3: Ambiguities — resolved

| Question | Resolution |
|---|---|
| Config-side work (field creation/deletion on Program) deployed to sandbox? | **Yes — confirmed deployed.** |
| Does "all fields editable in the modal during AR period" include Name, Career Cluster, Non-Credit Type? | **No — scoped to the updated/new fields only.** Unaffected fields retain their current editability behavior. |

## Layer 3: Remaining ambiguities — flagging with defaults

| Question | Default assumption | Risk if wrong |
|---|---|---|
| Is there one modal LWC or separate view/edit LWCs? | Single modal component with a mode (view/edit) or reactive disabled state on inputs | If separate, need to touch both or consolidate — more scope |
| How is "AR period" currently determined? | Existing Apex method or @AuraEnabled getter on a parent (Institution?) record returns a boolean | If it's client-side date math, verify where the source of truth lives |
| Do the 4 inline-editable table fields already work inline, or is that also new? | Callout #1 on Status/Headcount/#of Completers in the table suggests it's new/being changed. Treat as "make these inline-editable during AR period." | If already working, just gating by AR period |
| Does "Program Offered at" become a multi-select picklist (dual-listbox) in the edit modal too? | The left "Underwater Basket Weaving" modal shows it as a simple text field ("Location 1; Location 2") — so in the *edit* modal it stays as-is, and the dual-listbox pattern is only for *add* | If edit should also use dual-listbox, that's a meaningful UI change |
| Is the finalize button on the AR page, the Programs list, or elsewhere? | Likely on the Annual Report page or a related controller. Find by searching for "finalize" + "CIP" | If it's in a flow or validation rule rather than Apex, different fix path |
| Are any of the new fields required? | Tuition/Fees/Total Cost likely required; percentage rates and text fields likely optional | Wrong requiredness = validation errors on save |

## Implementation plan

### Step 1: Locate the existing components
Search for:
- The LWC rendering the Non-Credit Programs modal (likely named something like `programEditModal`, `nonCreditProgramForm`, or sits under a `programs` folder)
- The LWC rendering the Non-Credit Programs table
- The Apex controller backing both (look for `@AuraEnabled` methods returning Program records)
- The finalize button handler (search repo for `finalize` + `CIP` or `CIP_Code`)
- The existing "is AR period" check (search for `AnnualReport`, `isAnnualReportPeriod`, `AR_Period`, or similar)

### Step 2: Extend the Program modal LWC
- Add the 8 moved fields + 5 new percentage fields + Labor Market Outcomes (now text) + Other Outcomes Measures to the markup
- Follow existing patterns — reactive getters for disabled state, `lwc:if` for conditional sections, index-driven rendering if there's a list, Custom Labels for any new display strings
- Bind the `disabled` attribute on each **new/updated** input to a reactive getter like `get isFieldEditable()` that checks "is AR period"
- **Unaffected fields retain their existing editability behavior — don't alter them**
- Match the mockup layout (two-column, roughly the order shown)

### Step 3: Update the Apex controller
- Update the SOQL query returning Program records to include all new fields
- Update the DML save method to handle the new fields
- Add FLS check on the new fields (`Schema.sObjectType.Program__c.fields.Tuition__c.isUpdateable()` pattern or `stripInaccessible`)
- Keep it bulkified even if this is a single-record save context

### Step 4: Table inline editing
- In the table LWC, wire up inline-edit for Status, Headcount, Number of Completers, Program Offered at (per mockup callouts)
- Gate inline-edit availability by the same "is AR period" check
- Handle save events, call Apex, refresh the row

### Step 5: Fix the finalize button
- Find the CIP Code validation (likely in the Apex finalize method, or a validation rule, or a validateOnSave handler)
- Make it conditional: require CIP Code only for credit programs, not non-credit — OR remove the requirement entirely if product confirms
- **Confirm intent before removing:** "make finalize submittable without CIP Code" could mean (a) always optional, or (b) optional for non-credit only. Default to (b) — safer.

### Step 6: Test
- Apex tests for the controller changes (new fields load, save, FLS enforced)
- Manual test: enter AR period, edit all new/updated modal fields, save; exit AR period, verify new/updated fields disabled while other fields' editability is unchanged
- Manual test: inline-edit each of the 4 table fields during/outside AR period
- Manual test: finalize a non-credit program without CIP Code populated

## First concrete action

Open the repo and search for the LWC rendering the Non-Credit Programs modal:

```bash
grep -r "Non-Credit" force-app/main/default/lwc/ --include="*.html"
grep -r "programs" force-app/main/default/lwc/ -l | head
```

Once found, open the `.js` file and look at how existing fields handle the edit-vs-view state. That pattern is what to replicate for the new fields.
