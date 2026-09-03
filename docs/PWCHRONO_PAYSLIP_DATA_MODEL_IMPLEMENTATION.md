# PWChrono payslip data-model implementation

## Scope

This package implements the first four approved payslip prerequisites without generating PDFs. The Contact reconciliation, payroll metadata deployment, single-tab application deployment, and Experience Cloud publication are recorded separately below.

1. Reconcile `Portal_Users__c.Contact__c` using exact unique email matches.
2. Add the missing employee/bank fields to `Contact` with access isolated to the Payroll Manager permission set.
3. Establish `Contact__c` as the canonical employee relationship on salary slips, salary assignments, and salary history.
4. Add immutable salary-slip snapshot fields, normalized line items, and delivery audit records.

## Employee and bank ownership

`Contact` is the canonical employee master for identity, employment, email, and the employee's current bank account. `Portal_Users__c` remains the access/login record and must point to the employee Contact through `Contact__c`.

New Contact fields:

- `Account_Title__c`
- `IBAN_Code__c`
- `Father_Name__c`
- `Government_ID_Number__c`

The existing `Bank_Name__c`, `Account_Number__c`, `Branch_Name_Code__c`, and `SWIFT_Code__c` fields remain in use. Full account, IBAN, and government ID values must never be copied to a salary slip; only masked snapshot fields are provided.

Assign `PWChrono Payroll Manager` only to authorized HR/payroll staff. It deliberately grants no access to portal guest users. Sensitive Employee Directory sections are returned only for the employee's own Contact or an authorized payroll manager, and full account/passport values are masked before leaving Apex. Organization-wide defaults, sharing, field-level security, and `Portal_User_Profile__c` authorization remain additional enforcement layers.

## Contact reconciliation

Run `scripts/apex/reconcile_portal_user_contacts.apex` first as provided. It is a dry run and performs no DML. It:

- normalizes employee email case and whitespace;
- accepts only one matching Contact;
- refuses duplicate Contact-email matches;
- refuses a Contact already linked to another portal user;
- reports records with missing or unmatched email.

Only after HR reviews every proposed match should `applyChanges` be changed to `true` and the script rerun against the confirmed target org. Ambiguous employees must be linked manually; the script intentionally does not match on name.

The current record-by-record decision list is maintained in [`PWCHRONO_CONTACT_RECONCILIATION_REVIEW.md`](PWCHRONO_CONTACT_RECONCILIATION_REVIEW.md).

After those links are complete, run `scripts/apex/migrate_payroll_relationships_to_contact.apex` in its default dry-run mode. It backfills salary-slip, salary-assignment, and salary-history `Contact__c` values only through the reviewed `Portal_Users__c.Contact__c` relationship. It never matches payroll records by name or email.

## Canonical payroll employee relationship

`Contact__c` is canonical. It is present on `PWChrono_Salary_Slip__c`, `PWChrono_Salary_Assignment__c`, and `PWChrono_Salary_History__c`. Payroll values and historical ownership must be resolved through Contact.

The payroll controller, salary-slip viewer, salary-slip history trigger, and appraisal salary-assignment path now resolve payroll ownership through Contact. The viewer sends Contact IDs to Apex and reads the Contact relationship plus immutable employee-name/code snapshots. The legacy automatic salary-slip notification flow is stored as `Draft`; the release checklist must verify that no previously active flow version remains active before HR uses the controlled delivery path.

`Employees__c` is retained temporarily only because current portal access and existing records still reference `Portal_Users__c`. `Employee__c` and `Portal_Users__c` are additional legacy fields. The active compatibility rule prevents those Portal User lookups from contradicting one another.

`Require_Canonical_Contact` is delivered inactive. Activate it only after all Portal Users are linked to Contacts, payroll records are backfilled, and every remaining salary-slip producer has been confirmed to populate `Contact__c`. This ordering prevents the migration package from breaking current salary-slip creation.

## Immutable snapshot

The salary slip now contains:

- period, payment, attendance, and leave totals;
- salary assignment and employee Contact references;
- frozen employee, department, designation, and bank display values;
- masked government ID, account number, and IBAN;
- generation, delivery, document-reference, and snapshot-lock fields.

`PWChrono_Salary_Slip_Line__c` stores earning and deduction rows. The existing JSON fields remain temporarily for backward compatibility.

`PWChrono_Payslip_Delivery__c` stores one record per delivery attempt with recipient snapshot, file identifiers, request/sent audit, retry count, sanitized error, and a unique idempotency key.

## Delivery authorization boundary

The existing salary-slip email action and cross-employee selector are restricted by the `PWChrono_Send_Payslips` custom permission, supplied through `PWChrono_Payroll_Manager`. Users without it are locked server-side to their own linked Contact, and guest users cannot send. Apex obtains the destination only from `PWChrono_Salary_Slip__c.Contact__r.Email` and rejects a different caller-supplied address; the LWC also hides the action when the permission is absent.

This action remains a transitional HTML-email implementation. It does not default an environment-specific CC recipient, generate or attach an immutable PDF, queue delivery, or write `PWChrono_Payslip_Delivery__c`. Those capabilities remain a separate implementation phase.

## Deployment gates

1. Restore and verify the intended org authorization with `sf org display`.
2. Run the reconciliation script in dry-run mode and obtain HR approval for unresolved matches.
3. Validate `manifest/pwchrono-payslip-data-model.xml` without deploying.
4. Run all payroll and salary-slip tests.
5. Deploy metadata only after explicit approval.
6. Assign the Payroll Manager permission set only to named HR/payroll users.
7. Execute the approved Contact reconciliation separately and capture its result.

PDF generation, an audited delivery service, queueing, delivery-history writes, and the final HR send UI are intentionally outside this package.

## Validation evidence (2026-09-03)

- Target identity verified as the `PWChrono` Developer Edition org (`00DHr0000018UO8MAM`).
- Contact reconciliation: 13 explicitly reviewed Contacts were created and linked atomically on 2026-09-03. The final `Wahid SFMA Test` login was linked to its sole exact-email Contact. The final dry run reports all 16 Portal Users linked with 0 unresolved, 0 ambiguous, and 0 conflicts. `Harley Windler` is intentionally shared by two Portal login records so the employee and current bank master are not duplicated.
- Existing salary slips: 6 total, 6 using `Employees__c`, 0 using `Employee__c`, and 0 using `Portal_Users__c`.
- Contact migration readiness: all 6 salary slips and all 3 salary-history records resolve to Contact through their transition Portal User. There are no salary-assignment records yet.
- Isolated org comparison confirmed that `PWChrono_ConfigurationController` already matches the repository, while the org's older `PWChrono_ConfigurationController_Test` still calls removed per-user feature APIs. The current profile-based repository test is now included in this manifest.
- `PWChrono_NewMgrDashboardCtrl_Test` was corrected locally to call the current `getDashboardData(portalUserId, sessionToken)` contract and is also included in the manifest; the production controller was not changed.
- Final payslip/data-model check-only validation `0Afg800000C3pIQCAZ`: 87/87 components and 49/49 focused tests passed with zero component errors, test failures, or coverage warnings. This validation included the updated Employee Directory controller and both of its current test classes.
- Payroll/data-model deployment `0Afg800000C45OoCAJ`: 87/87 components and 49/49 focused tests passed with no component or test errors.
- Reporting-manager check-only validation `0Afg800000C4Ws1CAF` and deployment `0Afg800000C4JOYCA3`: 6/6 components and 5/5 focused tests passed. The Configuration Center and new-user form now use the existing `Portal_Users__c.Reports_To__c` self-lookup for manager assignment, with inactive-manager, self-reporting, and cycle rejection.
- Alice Cooper was assigned to the established Engineering manager Harmon_Abshire through `Reports_To__c`. Existing valid reporting chains were preserved; applicant and test records without evidence were not guessed.
- One-tab application and destructive-tab validation `0Afg800000C4ELdCAN` passed, followed by successful deployment `0Afg800000C3knOCAR`: 27/27 components and 4/4 focused tests passed. The obsolete standalone application tabs were deleted and `PWChrono_Dashboard` remains the single PWChrono application entry tab.
- The broader `RunLocalTests` check-only validation `0Afg800000C1VJ0CAN` progressed past both PWChrono contract corrections. It is now blocked before test execution only by `SwiftSignIntegrationTest`, which references the missing `SwiftSignFlowController.EnvelopeRequest` type. SwiftSign source is not part of this repository or payslip package, so it was not imported or modified.
- The `Pulse Work Chrono` Experience site was published successfully with job `08Pg800000Jzu5TEAR`. The public site URL rendered the branded login page with its CSS and no browser console warnings/errors. Authenticated Configuration Center validation remains pending because it requires a user OTP.
- The salary relationship backfill remains pending because the connected administrator has not been granted `PWChrono_Payroll_Manager`; Salesforce therefore correctly hides the new sensitive payroll fields from that user. No workaround access was added.
