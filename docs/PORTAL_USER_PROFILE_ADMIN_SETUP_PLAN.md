# Portal User Profile and Feature Administration Plan

## Document status

| Item                          | Value                                                                                    |
| ----------------------------- | ---------------------------------------------------------------------------------------- |
| Project                       | Pulse Work Chrono HRMS                                                                   |
| Target org alias              | `PWChrono`                                                                               |
| Org ID verified on 2026-09-01 | `00DHr0000018UO8MAM`                                                                     |
| Document purpose              | Define the target profile, feature, permission, and administrator setup experience       |
| Implementation status         | In progress; current source implements the profile record manager and permission editors |

## 1. Objective

`Portal_User_Profile__c` should be the reusable access package for a Portal User. An administrator should be able to create, understand, assign, and maintain a profile without entering feature keys, object API names, or field API names.

The design must:

- keep `Portal_Users__c.Portal_User_Profile__c` as the only runtime profile assignment;
- make profile names and purposes understandable to business administrators;
- provide controlled feature selection from a central catalog;
- apply recommended object and field access automatically;
- allow advanced permission overrides when required;
- prevent invalid, unsafe, or incomplete profiles from being activated;
- support cloning, comparison, impact review, bulk user assignment, and auditing;
- enforce access in Apex in addition to controlling navigation visibility; and
- preserve a clear release boundary between metadata deployment, data migration, Experience Cloud publication, and authenticated browser testing.

## 2. Confirmed current-state baseline

The following results were verified against the connected `PWChrono` org on 2026-09-01.

### 2.1 Profile and user assignment counts

| Item                             | Current count |
| -------------------------------- | ------------: |
| `Portal_User_Profile__c` records |             2 |
| Users assigned to `PUP-0000`     |             8 |
| Users assigned to `PUP-0001`     |             2 |
| Users without a profile          |             6 |
| Total `Portal_Users__c` records  |            16 |

Both profiles currently expose only their auto-number names. Administrators therefore see values such as `PUP-0000` instead of names such as “HR Manager” or “Employee Self Service.”

### 2.2 Permission and feature counts

| Item                                     | Current count |
| ---------------------------------------- | ------------: |
| Object-permission records for `PUP-0000` |            22 |
| Object-permission records for `PUP-0001` |             1 |
| Field-permission records                 |             0 |
| Profile-feature assignment records       |             0 |

### 2.3 Repository and org drift

The repository currently queries `Portal_Profile_Feature__c.Is_Enabled__c`, but this field was not present in the connected org during the live check. This metadata dependency must be deployed before the repository feature resolver can be considered operational in that org.

The feature names are also inconsistent between the Apex catalog and navigation filtering:

- navigation expects `Projects`, but the Apex feature list does not include it;
- navigation expects `Reports Dashboard`, but the Apex feature list does not include it; and
- navigation treats `Admin` as a wildcard, but the Apex feature list does not include `Admin`.

Feature keys must be reconciled before profile feature assignments are seeded.

### 2.4 Current administrator experience

The current Configuration Center can list Portal Users and assign an existing profile. Its profile selector queries only `Id` and `Name`, so it displays auto-number values.

The current `pwchronoProfilePermissions` component:

- runs on a `Portal_User_Profile__c` record page;
- displays a searchable object-permission table;
- supports assignment plus View, Create, Edit, and Delete selections;
- does not configure profile details or profile status;
- does not manage features;
- does not explain feature dependencies;
- does not expose field restrictions;
- does not provide templates, cloning, comparison, impact review, or user counts; and
- does not warn about incomplete or unsafe profiles.

## 3. Target ownership model

The runtime access path must be:

```text
Verified portal session
  -> Portal_Users__c
    -> Portal_User_Profile__c
      -> Portal_Profile_Feature__c assignments
      -> Portal_Object_Permission__c assignments
      -> Portal_Field_Permission__c exceptions
      -> approval routing settings
```

Do not introduce runtime fallbacks to employee roles, per-user feature strings, legacy role-feature metadata, or Salesforce Profile as the identity of a custom OTP Portal User.

Legacy sources may be read by a controlled migration utility, but they must not remain part of the post-migration access resolver.

## 4. Recommended `Portal_User_Profile__c` schema

| Field                         | Type                               | Required    | Purpose                                                                                          |
| ----------------------------- | ---------------------------------- | ----------- | ------------------------------------------------------------------------------------------------ |
| `Name`                        | Auto Number                        | Existing    | Salesforce record identifier only                                                                |
| `Display_Name__c`             | Text(120)                          | Yes         | Human-readable name shown to administrators and users                                            |
| `Developer_Key__c`            | Text(80), Unique, External ID      | Yes         | Stable programmatic profile identifier                                                           |
| `Description__c`              | Long Text Area                     | Yes         | Explains who should receive the profile and what it permits                                      |
| `Profile_Type__c`             | Restricted Picklist                | Yes         | Employee, Manager, HR Manager, Recruiter, Payroll Administrator, System Administrator, or Custom |
| `Is_Active__c`                | Checkbox                           | Yes         | Controls whether the profile can be assigned and used                                            |
| `Is_Template__c`              | Checkbox                           | Yes         | Identifies a profile that can be used as a starting preset                                       |
| `Is_Locked__c`                | Checkbox                           | Yes         | Protects system profiles from destructive changes                                                |
| `Can_Approve__c`              | Checkbox                           | Yes         | Indicates whether members may approve supported requests                                         |
| `Approval_Scope__c`           | Restricted Picklist                | Conditional | None, Direct Reports, Department, or All Employees                                               |
| `Default_Approval_Profile__c` | Lookup to `Portal_User_Profile__c` | Conditional | Identifies the destination profile for submitted approvals                                       |
| `Last_Reviewed_Date__c`       | Date                               | Recommended | Supports periodic access review                                                                  |
| `Last_Reviewed_By__c`         | Lookup to User                     | Recommended | Records the internal reviewer                                                                    |

### 4.1 Profile rules

- `Display_Name__c` must be used everywhere in the administrator interface. The auto-number may be shown as secondary reference text.
- `Developer_Key__c` must be unique and should become read-only after the profile is activated.
- Inactive profiles must not appear in normal assignment selectors.
- A profile with active users must not be deactivated unless the administrator chooses a replacement profile.
- `Approval_Scope__c` and `Default_Approval_Profile__c` are required only when `Can_Approve__c` or approval routing applies.
- A locked system profile may be cloned but must not be deleted or materially reduced through the portal interface.

### 4.2 Enabled feature storage decision

Do not add an `Enabled_Features__c` multi-select picklist. Continue with the normalized `Portal_Profile_Feature__c` child object. A normalized model supports descriptions, dependency validation, reporting, auditing, and future access levels without picklist limitations.

## 5. Central feature catalog

The approved design does not introduce a `Portal_Feature__c` object or a Custom Metadata feature catalog. The existing `PWChrono_AccessController.ALL_FEATURES` list remains the canonical supported-feature list, while `Portal_Profile_Feature__c` stores enabled feature assignments for each profile.

### 5.1 Feature definition attributes

| Attribute                    | Purpose                                                                                   |
| ---------------------------- | ----------------------------------------------------------------------------------------- |
| Feature key                  | Existing key used by Apex and LWC, for example `Leave Management`                         |
| Label                        | Administrator-facing label, for example “Leave Management”                                |
| Description                  | Plain-language explanation of the screens and actions included                            |
| Category                     | Self Service, Team Management, HR and Talent, Payroll, Work Management, or Administration |
| Display order                | Controls ordering in the Profile Manager                                                  |
| Active                       | Removes retired features from new configuration                                           |
| Administrator only           | Prevents inappropriate use in employee templates                                          |
| Navigation mappings          | Identifies menu items controlled by the feature                                           |
| Required object access       | Stored on the profile-feature assignment in `Required_Objects__c`                         |
| Sensitive field requirements | Stored on the profile-feature assignment in `Required_Fields__c`                          |

The administrator interface must load the canonical Apex list and only allow selection from valid entries. Administrators must never enter a free-text `Feature_Key__c`. Any new supported feature requires coordinated Apex, navigation, dependency, test, and deployment changes.

### 5.2 Recommended initial feature catalog

| Existing feature key     | Label                  | Category        | Purpose                                                       |
| ------------------------ | ---------------------- | --------------- | ------------------------------------------------------------- |
| `Dashboard`              | Dashboard              | Self Service    | Portal landing page and employee summary                      |
| `My Profile`             | My Profile             | Self Service    | View and maintain permitted employee details                  |
| `Attendance Management`  | Attendance Management  | Self Service    | Employee attendance, overtime, WFH, and timesheet experiences |
| `Leave Management`       | Leave Management       | Self Service    | Employee leave requests and leave status                      |
| `Holidays`               | Holidays               | Self Service    | Company holiday calendar                                      |
| `Company Policies`       | Company Policies       | Self Service    | Published policy access                                       |
| `Expense Management`     | Expense Management     | Self Service    | Expense submission and status                                 |
| `Tax Declaration`        | Tax Declaration        | Self Service    | Employee tax declaration experience                           |
| `Employee Directory`     | Employee Directory     | HR and Talent   | View permitted employee directory information                 |
| `Manager Dashboard`      | Manager Dashboard      | Team Management | Team-level management summaries                               |
| `Approvals`              | Approvals              | Team Management | Approve or reject supported employee requests                 |
| `Performance Management` | Performance Management | Team Management | Performance-review workflows                                  |
| `Appraisal`              | Appraisals             | Team Management | Employee appraisal workflows                                  |
| `Goals`                  | Goals                  | Team Management | Employee and team goal management                             |
| `Recruitment`            | Recruitment            | HR and Talent   | Job, applicant, and recruitment workflows                     |
| `Onboarding`             | Onboarding             | HR and Talent   | Employee onboarding workflows                                 |
| `Training Management`    | Training Management    | HR and Talent   | Training catalog and employee training workflows              |
| `Projects`               | Projects               | Work Management | Project list and project-related experiences                  |
| `Payroll`                | Payroll                | Payroll         | Payroll and salary-slip experiences                           |
| `Configuration`          | Configuration          | Administration  | Portal configuration center                                   |
| `Admin Settings`         | Admin Settings         | Administration  | Administrative settings and maintenance                       |
| `Reports Dashboard`      | Reports Dashboard      | Administration  | Administrative and management reporting                       |

The existing display-name keys are retained deliberately to preserve the current runtime contract. Do not introduce a second key namespace without an explicit migration plan.

### 5.3 Remove the `Admin` wildcard

The current navigation helper grants all menu access when the feature set contains `Admin`. This creates an overly broad and difficult-to-audit shortcut.

Replace it with explicit feature assignments through a locked System Administrator template. The navigation and Apex services should evaluate the same canonical keys.

If internal Salesforce users require emergency access, use a deliberate Salesforce Custom Permission or Permission Set rather than automatically granting all portal features based only on user type.

## 6. `Portal_Profile_Feature__c` assignment model

The child object should represent only the relationship between a profile and a catalog feature.

Recommended fields:

| Field                    | Purpose                                                  |
| ------------------------ | -------------------------------------------------------- |
| `Portal_User_Profile__c` | Parent profile                                           |
| `Feature_Key__c`         | Stable developer key selected from the central catalog   |
| `Is_Enabled__c`          | Enables or disables the assignment                       |
| `Access_Level__c`        | Optional future value such as View or Manage             |
| `Assignment_Key__c`      | Unique generated value combining profile and feature key |

`Feature_Label__c`, `Required_Objects__c`, and `Required_Fields__c` should not be manually repeated for every profile. During transition they may remain read-only for compatibility, but the central catalog should become authoritative.

The save service must reject:

- unknown feature keys;
- duplicate profile-feature assignments;
- inactive catalog features on a new profile;
- enabled features whose required object access is missing; and
- administrator-only features on prohibited profile types.

## 7. Object and field permission model

### 7.1 Object permissions

Continue using `Portal_Object_Permission__c` for application-level object access:

- View
- Create
- Edit
- Delete
- View All
- Modify All

View All and Modify All must appear only in an Advanced section and must include a clear warning. Selecting a feature should first apply its recommended minimum permissions. The administrator may then review or adjust them.

The feature catalog provides recommendations, but every relevant Apex controller must enforce the resulting permissions. Navigation visibility alone is not a security control.

### 7.2 Field permissions

Do not require an administrator to configure every field individually. Use `Portal_Field_Permission__c` primarily for sensitive exceptions and fields exposed by custom portal Apex.

Recommended sensitive groups include:

- payroll and compensation;
- bank and payment information;
- tax information;
- authentication, OTP, lock, and session fields;
- OAuth credentials or integration tokens;
- approval-only internal notes; and
- confidential recruitment information.

The administrator interface should show friendly grouped controls such as “Payroll details” or “Bank details,” with the individual field list available in an Advanced disclosure.

Salesforce CRUD/FLS remains authoritative for Salesforce users. Custom Portal User authorization must also be enforced explicitly by the Apex service layer.

## 8. Recommended profile templates

### 8.1 Employee Self Service

Recommended features:

- Dashboard
- My Profile
- Attendance Management
- Leave Management
- Holidays
- Company Policies
- Expense Management
- Tax Declaration
- Employee Directory with limited view access
- Training Management
- Goals

Data scope should normally be the employee's own records, with limited directory information for other employees.

### 8.2 Line Manager

Start with Employee Self Service and add:

- Manager Dashboard
- Approvals
- team attendance and leave operations;
- Performance Management;
- Appraisals; and
- team goal visibility.

Approval and data scope should normally be Direct Reports unless a wider scope is explicitly approved.

### 8.3 HR Manager

Start with Line Manager and add:

- broader Employee Directory management;
- Recruitment;
- Onboarding;
- Training Management administration;
- HR reporting; and
- approved leave, attendance, and employee-management access.

Payroll should remain excluded unless the business explicitly combines HR and Payroll responsibilities.

### 8.4 Recruiter

Recommended features:

- Dashboard
- Recruitment
- Onboarding
- limited Employee Directory
- approved recruitment reports

The template should not include payroll, bank, tax, or general administrative access.

### 8.5 Payroll Administrator

Recommended features:

- Dashboard
- Payroll
- Tax Declaration administration
- limited Employee Directory
- payroll reporting

Payroll and bank-related field permissions must be explicitly granted and audited.

### 8.6 System Administrator

Recommended features:

- Configuration
- Admin Settings
- Reports Dashboard
- all explicitly approved functional features

This template should be locked, clonable, and protected from accidental deactivation. It must not rely on a hidden `Admin` wildcard.

## 9. Administrator Profile Manager experience

Add a new **Profiles** section to `pwchronoConfigurationCenter`.

### 9.1 Profile list

The landing page should provide:

- summary cards for Active Profiles, Unassigned Users, Profiles With Warnings, and Unused Profiles;
- search and filters for profile type and status;
- display name with auto-number as secondary text;
- active/inactive status;
- assigned-user count;
- enabled-feature count;
- permission-health status;
- last reviewed date; and
- Edit, Clone, Compare, View Users, Activate, and Deactivate actions.

Loading, empty, error, permission-denied, and partial-data states must be designed explicitly. Errors should appear near the affected control in addition to a toast.

### 9.2 Five-step setup wizard

#### Step 1: Basics

- Enter display name and description.
- Select a profile type.
- Start from a recommended template or from a blank custom profile.
- Generate a developer key automatically and allow editing only before activation.

#### Step 2: Features

- Display features as grouped cards.
- Show a plain-language description for every feature.
- Show which screens and business capabilities are included.
- Mark recommended features for the selected template.
- Hide retired catalog features from new profiles.
- Never expose free-text feature-key entry.

#### Step 3: Data access

- Apply recommended object and sensitive-field permissions automatically.
- Explain why each object is required by the selected features.
- Provide a “Use recommended access” action.
- Put manual CRUD, View All, Modify All, and individual field controls in an Advanced section.
- Show dependency warnings immediately when access is reduced below the feature minimum.

#### Step 4: Approvals

- Display only when approval functionality is relevant.
- Configure whether the profile may approve.
- Select Direct Reports, Department, or All Employees scope.
- Configure the default approval destination profile where applicable.
- Prevent circular approval routing.

#### Step 5: Review and activate

Display:

- profile summary;
- selected features;
- object and sensitive-field access;
- approval configuration;
- users affected;
- access being granted or revoked;
- missing dependencies;
- high-risk permissions;
- lockout warnings; and
- activation readiness.

Support Save Draft, Back, Activate, and Cancel actions. Activation must be blocked until validation errors are resolved.

### 9.3 Administrator productivity features

- Clone an existing profile or template.
- Compare any two profiles side by side.
- Preview the menu and capabilities a selected test user will receive.
- Bulk-assign users from the Users section.
- Filter and assign all currently unassigned users.
- Replace a profile for all assigned users during deactivation.
- Export a profile summary for access review.
- Record change history and the responsible administrator.
- Warn before navigating away with unsaved changes.

## 10. Validation and safety rules

A profile must not activate when:

- its display name or developer key is missing;
- its developer key is duplicated;
- it contains unknown or duplicate feature keys;
- a selected feature lacks its required minimum object access;
- approval routing is incomplete or circular;
- an administrator-only feature is used by a prohibited profile type;
- it would remove the last usable system-administrator route; or
- another configured dependency is invalid.

Additional safeguards:

- deny access by default when no valid active profile is assigned;
- do not silently fall back to employee role or legacy feature stores;
- require a replacement before deactivating a profile with assigned users;
- retain the actual approving Portal User on transactional records for audit;
- provide accessible labels for every input and icon action;
- support keyboard navigation and visible focus states;
- move focus to the wizard heading when steps change; and
- announce validation and save results to assistive technology.

## 11. Apex and component plan

### 11.1 Apex services

Introduce or extend services to support:

- retrieving profile summaries and counts;
- retrieving the canonical feature catalog;
- creating and updating a draft profile;
- validating and activating a profile;
- cloning a profile with its assignments and permissions;
- comparing two profiles;
- previewing the impact of a change;
- bulk-assigning users;
- replacing a profile during deactivation; and
- retrieving profile audit history.

All write operations must:

- validate the caller's administrator access in Apex;
- validate feature keys against the central catalog;
- enforce object and field security where applicable;
- use transactional save behavior;
- return actionable validation messages; and
- avoid relying only on client-side checks.

### 11.2 Lightning Web Components

Recommended component structure:

- `pwchronoProfileManager` — list, filters, summary cards, and actions;
- `pwchronoProfileWizard` — wizard state and navigation;
- `pwchronoFeatureSelector` — grouped feature cards and descriptions;
- `pwchronoPermissionMatrix` — recommended access and advanced overrides;
- `pwchronoApprovalConfiguration` — conditional routing setup;
- `pwchronoProfileImpactReview` — activation preview and warnings; and
- existing `pwchronoProfilePermissions` — refactored or retired after functionality moves into the manager.

The visual implementation should continue the portal's existing Bootstrap/Metronic language while using native Lightning inputs where they provide stronger validation and accessibility.

## 12. Data migration plan

### Phase 1: Correct schema drift

- Deploy `Portal_Profile_Feature__c.Is_Enabled__c` and confirm the other repository fields exist.
- Confirm field-level access for the portal profile and administrator users.
- Re-run live describe and targeted SOQL verification.

### Phase 2: Add profile identity and lifecycle fields

- Add the recommended `Portal_User_Profile__c` fields.
- Update page layouts, list views, permission sets/profiles, Apex queries, wrappers, and tests.
- Use `Display_Name__c` in all assignment selectors.

### Phase 3: Establish the canonical feature catalog

- Create the feature-definition metadata.
- Reconcile Apex and LWC feature-key constants.
- Remove free-text feature setup from the administrator workflow.
- Remove the `Admin` wildcard.

### Phase 4: Migrate existing profiles

- Convert `PUP-0000` into an agreed named profile, likely an HR or administrator profile after business confirmation.
- Convert `PUP-0001` into an agreed restricted employee profile.
- Preserve existing object permissions unless the impact review identifies an unsafe grant.
- Create feature assignments from approved templates.
- Add only necessary sensitive field-permission exceptions.

### Phase 5: Resolve user assignments

- Review the 6 unassigned Portal Users.
- Assign an approved active profile or deactivate obsolete/test users.
- Do not enable profile-only enforcement until every intended active user has a valid profile.

### Phase 6: Retire legacy paths

- Confirm no active component or Apex service reads role-based or per-user feature stores.
- Remove obsolete runtime fallbacks only after migration verification.
- Keep any migration utility isolated from the runtime access resolver.

## 13. Testing requirements

### 13.1 Apex tests

- Administrator authorization and unauthorized-call rejection
- Profile create, update, clone, activate, deactivate, and replacement
- Duplicate developer-key and feature-assignment prevention
- Feature dependency validation
- Approval routing and circular-routing rejection
- Bulk assignment and partial-failure behavior
- Active-profile enforcement
- Object and sensitive-field permission enforcement
- System-administrator lockout protection

### 13.2 LWC tests

- Profile list states and filtering
- Template selection
- Feature grouping and selection
- Automatic dependency application
- Advanced permission overrides
- Conditional approval step
- Draft restoration and unsaved-change warning
- Activation error summary and focus management
- Clone, compare, preview, and bulk assignment flows

### 13.3 Authenticated browser validation

Validate with at least:

- Employee Self Service user
- Line Manager user
- HR Manager user
- Payroll Administrator user
- System Administrator user
- user with no profile
- user assigned to an inactive profile

For each user, confirm navigation visibility, direct component/Apex authorization, own-versus-team record scope, responsive behavior, keyboard operation, and error handling.

## 14. Acceptance criteria

The work is complete when:

- an administrator can create a standard profile from a template in under five minutes;
- no administrator must type a feature key or API name for normal setup;
- every profile displays a meaningful name and description;
- feature keys are defined once and shared by Apex and LWC;
- all selected features have valid required permissions;
- unsafe profiles cannot be activated;
- profiles can be cloned and compared;
- administrators can preview affected users and access changes;
- all intended active Portal Users have one active profile;
- object and sensitive-field permissions are enforced in Apex;
- the last administrative access route cannot be removed accidentally;
- automated tests pass; and
- deployment, site publication, and authenticated browser validation are reported separately.

## 15. Recommended implementation order

1. Fix the live-org feature-field drift.
2. Add the profile identity, lifecycle, and approval fields.
3. Create and seed the canonical feature catalog.
4. Reconcile all Apex and navigation feature keys.
5. Build Profile Manager list and summary views.
6. Build the five-step setup wizard.
7. Integrate recommended object and sensitive-field permissions.
8. Add clone, compare, impact preview, and bulk assignment.
9. Migrate the two existing profiles and resolve the 6 unassigned users.
10. Run Apex, LWC, security, accessibility, and authenticated-browser validation.
11. Deploy the approved metadata and data migration.
12. Publish the Experience Cloud site and complete post-publication verification.

## 16. Decisions requiring business confirmation

Before migrating the existing records, confirm:

1. the intended names and responsibilities of `PUP-0000` and `PUP-0001`;
2. whether HR Manager and Payroll Administrator must remain separate in all environments;
3. the approval destination and scope for each manager/HR profile;
4. whether line managers may view only direct reports or wider department data;
5. which sensitive employee, payroll, bank, tax, and recruitment fields require explicit access; and
6. which current Portal Users should receive profiles versus being deactivated.
