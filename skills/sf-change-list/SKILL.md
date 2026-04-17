---
name: sf-change-list
description: "Generate a Jira-ready list of changed Salesforce components grouped by metadata type. Use when the user pastes a file list from a GitHub branch, Copado deployment export, or any Salesforce metadata paths and wants a summarized component list. Triggers on pasting file paths, folder trees, Copado-style prefix lines, or mentions of deployment summary, changed components, what changed in this branch."
---

# Salesforce Change List Generator

Produce a clean, grouped list of changed Salesforce components for Jira or deployment tracking.

## Output Format

Only include sections that have changes:

```
==Custom Labels==
[label API names]
==Aura Components==
[component names]
==LWC==
[component names]
==Apex==
[class names]
==Custom Fields==
[Object__c.Field__c]
==Custom Objects==
[Object__c]
==Static Resources==
[resource names]
==Custom Metadata==
[type names]
==Flows==
[flow names]
==Permission Sets==
[permission set names]
==Profiles==
[profile names]
==Other==
[anything that doesn't fit above]
```

## Input Formats

### GitHub branch folder tree
Use parent folder to determine type: `classes/` → Apex, `lwc/` → LWC, `aura/` → Aura, `labels/` → Custom Labels, `objects/` → Custom Objects/Fields. For LWC/Aura, component name = subfolder name. Strip extensions and `-meta.xml`. List each unique name once.

**MDAPI Custom Labels:** Some projects store labels in a single MDAPI file like `src/labels/CustomLabels.labels` — all labels in one XML file as `<labels>` elements. If that file appears in a change list, the actual label names are the `<fullName>` values *inside* the diff, not the filename. Ask for the diff (or a list of added/modified label `fullName`s) rather than listing `CustomLabels` as a component.

### Copado deployment export (prefix style)
| Copado prefix | Section |
|---|---|
| `ApexClass/`, `ApexTrigger/` | Apex |
| `LightningComponentBundle/` | LWC |
| `AuraDefinitionBundle/` | Aura Components |
| `CustomLabel/` | Custom Labels |
| `CustomField/` | Custom Fields (keep `Object.Field`) |
| `CustomObject/` | Custom Objects |
| `StaticResource/` | Static Resources |
| `CustomMetadata/` | Custom Metadata |
| `Flow/` | Flows |
| `PermissionSet/` | Permission Sets |
| `Profile/` | Profiles |
| Anything else | Other |

### Mixed / freeform
Parse inline annotations gracefully. Combine with file lists.

## Rules

1. Deduplicate. 2. Include test classes. 3. No file extensions in output. 4. Custom Fields always as `Object__c.Field__c`. 5. Unknown types → `==Other==`. 6. Skip empty sections. 7. Use section order above.
