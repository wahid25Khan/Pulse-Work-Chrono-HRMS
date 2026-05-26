# Pulse Work Chrono — Site Go-Live Audit

This audit reviews the **Pulse Work Chrono** Experience Cloud / site metadata currently present in the repository and highlights what is still missing to make the site URL reliably live in a target org.

---

## Executive summary

The repo is **partially ready** for site go-live, but it is **not yet complete enough to recreate the full site from source alone**.

### Biggest findings

1. **The navigation menu exists** in metadata and can be deployed.
2. **The network exists** in metadata and is marked `Live`.
3. **The actual site container metadata is missing from source**.
4. **The Experience/site bundle is missing from source**.
5. **Guest access configuration is incomplete**.
6. **No guest sharing rules / sharing sets are present in metadata**.
7. Many key portal objects use **`externalSharingModel=Private`**, so site users/guest users will not see records unless sharing is configured in the org.

---

## Confirmed present in source

### Network metadata

File:

- `force-app/main/default/networks/Pulse Work Chrono.network-meta.xml`

Confirmed values:

- `status = Live`
- `urlPathPrefix = PulseWorkChronovforcesite`
- `site = Pulse_Work_Chrono`
- `picassoSite = Pulse_Work_Chrono1`

This tells us the org/network expects a real site and builder bundle to exist.

### Navigation menu metadata

File:

- `force-app/main/default/navigationMenus/SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`

Status:

- Present
- Structured
- Deployable

So yes — **the site navigation menu already exists in metadata**.

### Portal-related app/tab metadata

Present:

- `force-app/main/default/applications/PWChrono_Portal.app-meta.xml`
- `force-app/main/default/tabs/PWChrono_Holidays.tab-meta.xml`
- other PWChrono tabs/components used for portal navigation

### Guest access documentation

File:

- `docs/guest-user-permissions.md`

This doc is useful, but it describes a much larger permission footprint than what is currently implemented in metadata.

---

## Confirmed missing in source

## 1. Missing site metadata

The network references:

- `site = Pulse_Work_Chrono`

But there is **no** corresponding file in source such as:

- `force-app/main/default/sites/Pulse_Work_Chrono.site-meta.xml`

There is also no `sites/` folder retrieved locally.

### Impact

If the target org does **not already have** the site created, the URL will not be reproducible from this repo alone.

---

## 2. Missing Experience bundle / site bundle

The network references:

- `picassoSite = Pulse_Work_Chrono1`

But locally:

- `force-app/main/default/siteDotComSites/` contains only `Canary_AI1.site-meta.xml`
- there is **no** `Pulse_Work_Chrono1.site-meta.xml`
- there is **no** `experiences/Pulse...` bundle retrieved locally

### Impact

This is a major blocker for recreating the site UI/pages/routes from source.

In other words:

- the **network exists**,
- the **menu exists**,
- but the **actual site/builder bundle is not in the repo**.

---

## 3. Incomplete guest permission set

File:

- `force-app/main/default/permissionsets/PWChrono_Guest_Access.permissionset-meta.xml`

Current contents:

- only **1 Apex class** is granted: `PWChrono_AdminController`
- **no object permissions**
- **no field permissions**

### Impact

This is far from enough for the portal flows described in `docs/guest-user-permissions.md`.

---

## 4. Incomplete portal user permission set

File:

- `force-app/main/default/permissionsets/PWChrono_Portal_User_Access.permissionset-meta.xml`

Current contents:

- only 5 Apex classes:
  - `PWChrono_AccessController`
  - `PWChrono_AttendanceController`
  - `PWChrono_AuthController`
  - `PWChrono_ConfigurationController`
  - `PWChrono_LeaveController`
- **no object permissions**
- **no field permissions**

### Impact

Even for authenticated/portal-side usage, the source metadata is incomplete.

---

## 5. Missing guest sharing rules / sharing sets

No metadata was found for:

- sharing rules dedicated to guest/site access
- sharing sets
- site-specific sharing artifacts

### Impact

Even if Apex and object permissions are granted, record access will still fail for many objects unless sharing is configured.

---

## Critical record-sharing findings

Many important portal objects are configured with:

- `externalSharingModel = Private`

### Confirmed private external sharing on core portal objects

Portal framework objects:

- `Portal_Users__c`
- `Portal_User_Profile__c`
- `Portal_Object__c`
- `Portal_Object_Field__c`
- `Portal_Object_Permission__c`
- `Portal_Field_Permission__c`

Key PWChrono objects with private external sharing include:

- `PWChrono_Expense_Claim__c`
- `PWChrono_Goal__c`
- `PWChrono_Job_Applicant__c`
- `PWChrono_Job_Opening__c`
- `PWChrono_Interview__c`
- `PWChrono_Onboarding_Task__c`
- `PWChrono_Training_Attendance__c`
- `PWChrono_Training_Event__c`
- `PWChrono_Training_Program__c`
- `PWChrono_Tax_Declaration__c`
- `PWChrono_Company_Policy__c`
- `PWChrono_Leave_Type__c`
- `PWChrono_Leave_Policy__c`
- `PWChrono_Leave_Period__c`
- `PWChrono_Leave_Ledger__c`
- `PWChrono_User_Feature_Access__c`
- and several more

### Why this matters

If the site is using guest-user execution or site-context execution, these records will **not be visible by default**.

So yes — **you will very likely need sharing rules, sharing sets, or OWD/external sharing adjustments** for the site to work.

---

## Important nuance: navigation menu is not the blocker

The site navigation menu is already present in source:

- `SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`

So if the question is:

> Do we need to deploy the site navigation menu?

The answer is:

- **Yes, if the target org does not already have it or if you want to update it from source.**
- **No, it is not the main missing blocker** — because it already exists in metadata.

The bigger blockers are:

- missing site metadata
- missing experience/site bundle
- incomplete guest/portal permissions
- missing sharing configuration

---

## Most likely missing items to make the site URL live

## If the target org already has the site created

Then the likely missing go-live items are:

1. deploy/update the navigation menu
2. deploy/update the app + tabs + sidebar changes
3. complete guest permission set
4. complete portal user permission set
5. configure guest/site sharing rules in org
6. verify site activation and publish state
7. verify guest user profile and Experience Builder settings

## If the target org does NOT already have the site created

Then you are additionally missing:

1. `sites/Pulse_Work_Chrono.site-meta.xml`
2. the actual site bundle for `Pulse_Work_Chrono1`
   - either `siteDotComSites/...`
   - or the relevant Experience Builder bundle retrieved from org

Without those, the repo does **not** contain everything needed to recreate the site URL from scratch.

---

## Non-metadata org setup likely still required

These are likely required in Setup even if metadata is deployed:

- create/confirm the Experience Cloud site
- activate/publish the site
- assign the guest user profile / permission sets
- grant Apex class access on the guest user profile
- enable guest record creation if needed
- configure sharing rules / external access
- verify file upload permissions (`ContentVersion`, `ContentDocumentLink`)
- verify email templates and site login flow settings

---

## Recommended next steps

## Priority 1 — retrieve the missing site assets

Retrieve or confirm the existence of:

- `Pulse_Work_Chrono` site metadata
- `Pulse_Work_Chrono1` site/experience bundle

If these exist in the org, retrieve them into source.

## Priority 2 — complete access metadata

Expand:

- `PWChrono_Guest_Access.permissionset-meta.xml`
- `PWChrono_Portal_User_Access.permissionset-meta.xml`

These should include the required Apex, object, and field access.

## Priority 3 — define sharing strategy

For the private external-sharing objects, decide whether to use:

- guest user sharing rules
- sharing sets
- external OWD adjustments
- or a redesign toward authenticated Experience Cloud users instead of guest execution

## Priority 4 — verify org-side site configuration

In the target org, confirm:

- site exists
- site is active
- site is published
- guest user is configured
- guest permissions are assigned
- navigation menu is assigned to the site

---

## Bottom line

### Yes, the navigation menu already exists.

### Yes, you likely need sharing rules or equivalent sharing configuration.

### And the biggest missing source items are the actual site metadata + site bundle.

So the short answer is:

> The repo has the network and the menu, but it does **not yet have everything needed** to fully stand up the Pulse Work Chrono site URL from scratch.
