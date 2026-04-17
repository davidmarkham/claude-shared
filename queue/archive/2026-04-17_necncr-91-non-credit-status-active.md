# NECNCR-91 — Set Non-Credit Status to Active

*Decoded in Claude chat — 2026-04-17*

## The ask

Extend the "Add as Non-Credit" action on the Sites page so that, in addition to checking `Site.Non_Credit_Site__c`, it also sets `Site.Non_Credit_Status__c = 'Active'`.

## What you're changing

1. The handler behind the "Add as Non-Credit" link — add `Non_Credit_Status__c = 'Active'` to the same update that sets `Non_Credit_Site__c = true`.

## Unknowns to resolve

- Where the handler lives. Most likely an LWC/Aura action calling Apex, or a Visualforce controller action, based on the screenshot showing a custom Sites page. Search for `Non_Credit_Site__c` assignments in Apex to find it.
- Confirm `Non_Credit_Status__c` field type — if picklist, verify `'Active'` matches the API value exactly (casing/whitespace).

## Assumptions

- `'Active'` is an existing valid value on `Non_Credit_Status__c`. The "Site UFO" row in the screenshot already shows "Active", so the value exists in the UI. **Risk: Low**
- No validation rules or triggers on Site need updating — just setting the field. Worth a quick grep for triggers reacting to `Non_Credit_Status__c`. **Risk: Low**
- Only the "Add as Non-Credit" path changes. The blank Non-Credit Status on "New Site" in the screenshot is exactly the bug this ticket fixes. **Risk: Low**

## Entry point

Grep the repo for `Non_Credit_Site__c` assignments in Apex (`Non_Credit_Site__c = true` or `.Non_Credit_Site__c =`). That's the line you're adding `Non_Credit_Status__c = 'Active';` next to.

## Additional context

- Ticket includes a screenshot showing the Sites page UI: "Add as Non-Credit" link in the "All Sites" table promotes a site into the "Non-Credit Sites" table above. The Non-Credit Status column is currently blank for newly-promoted sites.
