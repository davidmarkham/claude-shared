# NC Annual Report — Three Bugs from Tab Restructure Cleanup

*Decoded 2026-04-20*

### 1. The ask
Three NC-flow bugs from incomplete cleanup of the "Annual Report" tab restructure: wire up the renamed instructions tab to its NC help field, update the field-completion check to the trimmed 6-field set, and finish the section header rename/merge that the original ticket only partially applied.

### 2. What you're changing
1. **Bug 1 — Instructions tab content rendering:** Find where the renamed "Annual Report Instructions" tab pulls its body content. The credit flow renders some `Institution_Portal_Help.<credit field>__c`; the NC branch needs to render `Institution_Portal_Help.AR_General_Overview_NC__c`. Likely a missing/wrong field reference in an LWC (or Visualforce) template, or a wire/Apex method returning the wrong field.
2. **Bug 2 — Finance completion logic:** Locate the method that evaluates whether the General Information tab is complete and sets `Annual_Report__c.Finance_Complete__c`. Update its required-field list to only the 6 NC fields: Total Non-Credit Revenue, Total Non-Credit Headcount, # of faculty (full-time), # of faculty (part-time), # of non-credit staff (full-time), # of non-credit staff (part-time). The two `_total` fields appear read-only/derived in the screenshot, so likely excluded from the check — confirm.
3. **Bug 3a — Section merge:** Remove the "I. Financial Information" and "II. Enrollment Information" headers on the NC General Information tab and replace with a single "Enrollment & Finance Information" header above all 4 fields (Revenue, Headcount, plus whatever else belongs in that group).
4. **Bug 3b — Section rename:** Rename "Faculty and Staff" → "Instructors & Staff" on the same tab.

### 3. Unknowns to resolve
- **Where does the instructions tab body get rendered?** Could be an LWC bound to `Institution_Portal_Help__c`, a rich-text field rendered via `lightning-formatted-rich-text`, or a Visualforce remnant. Search for `AR_General_Overview` (any suffix) to find the credit-side analog and copy its pattern.
- **Is the completion check Apex or LWC?** If Apex, look for a method like `checkFinanceComplete` / `evaluateAnnualReportSections` and a hardcoded list of field API names. If LWC, look for a JS array of required field names in the General Information component. Possibly both (LWC for UI checkmark, Apex for the persisted boolean).
- **Are the original section headers driven by markup or by metadata** (e.g., a Section CMT, a picklist-driven layout, or `<lightning-layout>` blocks)? Determines whether bug 3 is a markup edit or a metadata/CMT edit.

### 4. Assumptions I'm making
- The original ticket's NC vs. credit branching is done via a record type, a user-type check on the contact/account, or a feature flag — not by string-matching tab names. **Medium risk.** If branching *is* by tab name, there are likely more silent breakages beyond these three bugs (worth a grep for the old strings `"General Information"` and `"Enrollment and Finances"` regardless).
- The two `_total` fields (`# of faculty (total)`, `# of non-credit staff (total)`) are formula or derived fields and not part of the completion check. **Low risk** — the screenshot shows them grayed out.
- `Finance_Complete__c` is set by the same code path that drives the left-nav checkmark (single source of truth, not duplicated logic). **Medium risk** — if they're separate, fix both.
- The instructions tab body field is rich text and renders via the same component pattern as the credit side. **Low risk.**

### 5. Entry point
Grep the LWC and Apex codebase for `AR_General_Overview` — this finds both the credit-side rendering pattern (model for bug 1) and any hardcoded references that also need an NC variant. From there, locate the General Information tab's component to find the field-completion array (bug 2) and section markup (bug 3) in the same neighborhood.

## Additional context

These three bugs are follow-up cleanup on a previously-shipped ticket. The original ticket scope (already deployed) was:

1. NC: Rename "General Information" tab → "Annual Report Instructions" (tab + page title)
2. NC: Hide "Major Institutional Changes" tab
3. NC: Rename "Enrollment and Finances" tab → "General Information" (tab + page title)
4. NC: Remove 8 fields from the new General Information page (Tuition, Fees, Other Costs, Total Cost, State And Federal Funding, State And Federal Funding Description, Eligible for WIOA Funding, Financial Aid Availability)
5. NC: Merge "I. Financial Information" + "II. Enrollment Information" sections into one section called "Enrollment & Finance Information"
6. NC: Rename "Faculty and Staff" section → "Instructors & Staff"

Bugs 1 and 2 are functional regressions that the original ticket missed. Bug 3 is finishing scope items #5 and #6 of the original ticket — the section merge and the "Instructors & Staff" rename were specified but appear not to have been applied (the screenshot shows both old section headers still rendering and "Faculty and Staff" still in place, with the new labels marked in red as the intended state).

Reporter notes that on the renamed Annual Report Instructions tab, "currently nothing is being displayed" — confirming bug 1 is a render failure, not a styling issue. For bug 2, reporter confirmed that filling out 6 fields and clicking Save does not flip the left-nav checkmark or set `Finance_Complete__c = TRUE`.
