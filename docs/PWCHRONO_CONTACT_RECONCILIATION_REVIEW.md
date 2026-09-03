# PWChrono Contact reconciliation review

## Execution result

On 2026-09-03, the user explicitly authorized creating and linking Contacts for the 13 Portal Users listed in this document. The ID-scoped script `scripts/apex/create_missing_portal_user_contacts.apex` completed successfully in one transaction:

- Contacts created: 13
- Portal Users linked: 13
- Total linked Portal Users after final resolution: 16 of 16
- Canonical Contacts shared by multiple login records: 1
- Unresolved records after execution: 0
- Ambiguous records after execution: 0
- Remaining conflicts: 0

`Wahid SFMA Test` was subsequently linked to the sole existing exact-email Contact, `Harley Windler` (`003g800000dL4exAAC`). That Contact is also referenced by the `Harmon_Abshire` Portal User. These are treated as two login/access records for one employee, preserving one canonical employee and bank-information record. No duplicate Contact was created; an attempted insert was rolled back after the org returned `STORAGE_LIMIT_EXCEEDED`.

`M Wahid CS Test`, `Shaun Howard`, and `Zack Martin` now have separate Contact records as requested, but all three Contacts inherit the shared email `m.wahidcs@gmail.com`. HR should correct those emails before relying on them for payslip delivery.

## Pre-creation snapshot

- Date: 2026-09-03
- Org: `PWChrono` (`00DHr0000018UO8MAM`)
- Mode: dry run before the authorized creation
- Portal Users reviewed: 16
- Already linked: 1
- Safe unique email matches: 0
- No Contact email match: 14
- Ambiguous email match: 1
- Existing-link conflicts: 0

At this stage, no Portal User could be linked automatically from email evidence alone. The later explicit instruction to create one new Contact per listed Portal User superseded the proposed manual decisions below.

## Payroll-critical resolution

The Portal User formerly named `Sultan khan` (`a0MHr00000MF3XsMAL`) owns three existing paid salary slips:

- `SLIP-00000` for 2025-11-01
- `SLIP-00001` for 2025-10-01
- `SLIP-00002` for 2025-09-01

That Portal User is now named `Harmon_Abshire` and is linked to `Harley Windler` (`003g800000dL4exAAC`). All three salary slips resolve through that Contact.

The other three existing paid salary slips belong to the already-linked `Wahid Khan` Portal User and can be backfilled after the Contact fields are deployed.

## Created and linked Portal Users (historical review)

| Portal User                | Role       | Current email evidence               | Recommended HR decision                                                                                                   |
| -------------------------- | ---------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| Alice Cooper               | Employee   | `alice.cooper@example.com`           | Confirm this is a real employee; create a Contact if valid, otherwise deactivate/archive the test identity.               |
| Carol Zhang                | HR Admin   | `carol.zhang@example.com`            | Confirm identity and create/select the employee Contact before granting payroll access.                                   |
| GSF Applicant - Sam Rivera | Employee   | `sam.rivera@example.com`             | Confirm whether the applicant was hired. Applicants should not become employee Contacts merely to satisfy payroll.        |
| Hamd Ali                   | HR Admin   | `hamd@thelodestonegroup.com`         | Likely real employee; HR should confirm and authorize a new Contact because no candidate exists.                          |
| M Wahid CS Test            | Employee   | `m.wahidcs@gmail.com`                | Treat as a test identity unless HR confirms otherwise; do not share one Contact with other Portal Users.                  |
| Shaun Howard               | Unassigned | fallback email `m.wahidcs@gmail.com` | Correct the employee email first or retire the record; the current shared fallback is not identity evidence.              |
| Sultan khan                | HR Admin   | `wahid@thelodestonegroup.com`        | Resolve urgently because three salary slips depend on it; choose the correct Contact or create one after HR confirmation. |
| Team Member 1              | Employee   | `team1@example.com`                  | Confirm demo/test status; create no Contact until confirmed.                                                              |
| Team Member 2              | Employee   | `team2@example.com`                  | Confirm demo/test status; create no Contact until confirmed.                                                              |
| Team Member 3              | Employee   | `team3@example.com`                  | Confirm demo/test status; create no Contact until confirmed.                                                              |
| Test Guest User            | Employee   | `test.guest@example.com`             | Keep outside payroll; deactivate or explicitly classify as test data.                                                     |
| Wahid SFMA Test            | HR Admin   | `wahidsfma@gmail.com`                | Confirm test status; do not reuse the already-linked Wahid Khan Contact.                                                  |
| Zack Martin                | Unassigned | fallback email `m.wahidcs@gmail.com` | Correct the employee email first or retire the record; do not infer a Contact from the shared fallback.                   |

## Created and linked inactive Portal Users

| Portal User  | Email                      | Recommended decision                                                                |
| ------------ | -------------------------- | ----------------------------------------------------------------------------------- |
| Bob Sales    | `bob.sales@example.com`    | Leave unlinked unless the employee must be reactivated and HR confirms the Contact. |
| John Manager | `john.manager@example.com` | Leave unlinked unless the employee must be reactivated and HR confirms the Contact. |

## Already linked

`Wahid Khan` (`a0MHr00000HhIc3MAF`) is linked to Contact `003Hr00002eLsnTIAS`, also named `Wahid Khan`. HR should verify that the Portal User's two stored email fields and the Contact email intentionally differ before production use.

## Ongoing data-hygiene review

For future Portal Users, HR should provide exactly one decision:

1. Link to Contact ID `<003...>`.
2. Create a new employee Contact using confirmed legal name and confirmed unique work email.
3. Mark as test/non-employee and exclude it from payroll.
4. Deactivate or retire the Portal User.

The 13 requested links are complete. Apply the same decision format only to the remaining `Wahid SFMA Test` conflict, then rerun the dry-run reconciliation. Payroll relationship backfill can proceed for the six existing salary slips and three salary-history records because all of their legacy employee relationships now resolve to Contacts.
