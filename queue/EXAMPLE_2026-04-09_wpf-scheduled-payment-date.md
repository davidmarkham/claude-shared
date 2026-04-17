# WPF Giving — Scheduled Payment Date

*Decoded in Claude chat — 2026-04-09*
*Project: WPF Giving portal (OpenWacca)*

## The ask

Add the Scheduled Payment Date (from child Payment record) to three detail tables on the WPF Giving portal: Current Giving (Matching Gift), Director Discretionary, and Family Discretionary.

## What you're changing

1. New custom field on Opportunity: `Scheduled_Payment_Date__c` (Date) — stamped from the Payment object
2. Record-triggered flow on `npe01__OppPayment__c`: before-save, stamps `npe01__Scheduled_Date__c` onto the parent Opportunity's new field
3. Three field sets: add `Scheduled_Payment_Date__c` to each detail table's field set

## Unknowns to resolve

- Confirm NPSP API names: Payment object likely `npe01__OppPayment__c`, scheduled date field likely `npe01__Scheduled_Date__c` — verify in org
- Check whether NPSP native rollup already supports stamping this field before building custom flow
- Confirm 1:1 Payment-to-Opportunity relationship holds for all three gift types

## Assumptions

- The three tables use the shared `c:LightningDataTable` component driven by field sets — adding to field sets is sufficient, no component changes needed. **Risk: Low**
- Cross-object formula won't work (child-to-parent not supported on standard Opportunity formula fields) — flow-based stamping is required. **Risk: Low**

## Entry point

Open Object Manager → search for `npe01__OppPayment__c` → confirm the scheduled date field's API name. Then create the custom field on Opportunity.

## Additional context

- Loren Crippin and Megan Slater are collaborators on this project
- Approach avoids modifying the shared `c:LightningDataTable` component — metadata-layer solution preferred
