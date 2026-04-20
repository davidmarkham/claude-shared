# NECNCR-92

*Decoded 2026-04-20*

**The ask:** The "Date Location Closed" field currently shows when `Status = Inactive`. Extend the visibility rule so it also shows when `Non_Credit_Status__c = Inactive`.

**What you're changing:**
1. The visibility logic for the "Date Location Closed" field on the Site UFO / non-credit site edit screen — add `Non_Credit_Status__c = Inactive` to the condition that currently checks `Status = Inactive`.

**Unknowns to resolve:**
- Where the visibility is controlled. Most likely candidates, in order: (a) an LWC with a `template if:true` around the field, (b) a Visualforce page with a `rendered` attribute, (c) a Dynamic Form / page layout visibility rule. The screenshot styling (custom header, red Save button, "Return to Sites" link) strongly suggests this is a custom LWC or VF page, not a standard record page.
- Whether the logic is OR (show if either status is Inactive) or should be mutually exclusive based on `Type`. Given `Type = Non-Credit Location` on this record, an OR condition is almost certainly correct — but confirm the credit-location path still behaves as it does today.

**Assumptions I'm making:**
- The existing `Status = Inactive` check is a simple equality comparison, not part of a larger state machine. Low risk — if it were more complex, the ticket would likely say so.
- "Date Location Closed" is a single field rendered in one place, not duplicated across credit/non-credit variants. Medium risk — if there are separate sections for credit vs. non-credit sites, you may need to add the field to the non-credit section rather than modifying a condition.
- The field should be editable (not read-only) when shown under the non-credit condition, matching current behavior for the credit path. Low risk.

**Entry point:** Grep the repo for `Date_Location_Closed__c` (or the likely API name — check the field first in Object Manager). That will land you on the component/page that renders it and the existing `Status` visibility check to extend.
