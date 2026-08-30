# Pulse Work Chrono Technical Inventory

## Document control

| Property                   | Value                                                                          |
| -------------------------- | ------------------------------------------------------------------------------ |
| Product                    | Pulse Work Chrono                                                              |
| Salesforce project         | PWChrono-HRMS                                                                  |
| Document purpose           | Module, metadata, data-model, access, and dependency inventory                 |
| Status                     | Navigation reconciliation deployed and published; browser verification pending |
| Repository owner           | `wahid25Khan`                                                                  |
| Source of truth owner      | Pulse Work Chrono Technical Team                                               |
| Technical approver         | Pulse Work Chrono Technical Lead                                               |
| Security approver          | Pulse Work Chrono HR/System Administrator                                      |
| Last repository review     | 2026-08-30                                                                     |
| Last live-org verification | 2026-08-31                                                                     |
| Target org alias           | PWChrono                                                                       |
| Target site                | Pulse Work Chrono                                                              |
| Git repository             | `wahid25Khan/Pulse-Work-Chrono-HRMS`                                           |
| Review cadence             | Before each release and after every schema or access change                    |

## How to maintain this inventory

This file is the canonical index of Pulse Work Chrono features and
infrastructure. Update it in the same pull request as any change to an LWC,
Apex class, object, field, permission, route, tab, automation, or integration.

Use the following values consistently:

- **Implemented**: source exists and the feature has passed required validation.
- **Partial**: some production behavior is implemented, but a documented gap
  remains.
- **Placeholder**: the surface exists but uses mock, sample, or no persisted
  behavior.
- **Planned**: approved architecture with no completed implementation.
- **Deprecated**: retained temporarily for migration or compatibility.
- **Dormant**: source exists but is not bound to an active route or supported
  entry point.
- **Unknown**: requires source or live-org verification.

For every inventory row:

1. Use the exact Salesforce API or bundle name.
2. Link to the source file when possible.
3. Distinguish repository evidence from live-org evidence.
4. Never record credentials, OTP values, session tokens, or access tokens.
5. Record deployment, publication, and browser verification separately.
6. Remove `[TBD]` only after the value has been verified.

## System context

| Layer                 | Current implementation                                                | Owner                    | Status                         | Evidence                                           |
| --------------------- | --------------------------------------------------------------------- | ------------------------ | ------------------------------ | -------------------------------------------------- |
| Internal application  | `PWChrono_Portal` standard Lightning navigation app                   | PWChrono Technical Team  | Implemented                    | `applications/PWChrono_Portal.app-meta.xml`        |
| Experience site       | Pulse Work Chrono LWR site                                            | PWChrono Technical Team  | Implemented                    | `digitalExperiences/site/Pulse_Work_Chrono1`       |
| Portal authentication | Custom OTP session operating in Salesforce Guest runtime              | PWChrono Technical Team  | Implemented                    | `PWChrono_AuthController`, `PWChrono_GuestSession` |
| Portal identity       | `Portal_Users__c`                                                     | HR Operations            | Implemented                    | Object metadata and authentication controllers     |
| Portal access profile | `Portal_User_Profile__c`                                              | HR/System Administration | Partial                        | Profile lookup and permission records exist        |
| Shared site shell     | `pwchronoMainLayout`                                                  | PWChrono Technical Team  | Implemented                    | LWR page wrappers                                  |
| Shared UI assets      | SmartHR, Bootstrap, Font Awesome, Tabler, Feather                     | PWChrono Technical Team  | Implemented for LWR shell      | `pwchronoUiAssets`, `smarthr_assets`               |
| Navigation            | Standard Lightning tabs plus custom Experience navigation             | PWChrono Technical Team  | Reconciliation pending release | Application, tab, and NavigationMenu metadata      |
| Approval model        | Custom request approvers plus dormant Salesforce work-item controller | HR Management            | Partial                        | Request services and `PWChrono_ApprovalController` |

### Repository baseline and local-change provenance

| Scope                                    | Provenance                                | Current state                                                           | Evidence                             |
| ---------------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------ |
| Business modules and Salesforce metadata | Retrieved from the connected PWChrono org | Committed org baseline; not newly developed in the current batch        | Commit `2e9525f`                     |
| Frontend validation cleanup              | Repository reconciliation follow-up       | Committed; no new module introduced                                     | Commit `32b903d`                     |
| Portal navigation and route bindings     | Local reconciliation after org retrieval  | Deployed; Experience Cloud publication and browser verification pending | Deployment `0Afg800000BcmepCAB`      |
| New business functionality               | None in the current local batch           | No new business module should be attributed to this batch               | Working-tree review dated 2026-08-30 |

The local reconciliation changes connect existing components to navigation,
routes, tabs, and access checks. They do not represent new development of the
underlying Attendance, Leave, Payroll, Onboarding, Reports, or Administration
business modules.

## Module summary

| Module                           | Primary entry point                    | Runtime | Data state | Overall status | Functional owner         | Current-batch provenance                                      |
| -------------------------------- | -------------------------------------- | ------- | ---------- | -------------- | ------------------------ | ------------------------------------------------------------- |
| Portal shell and authentication  | Login and `pwchronoMainLayout`         | LWR     | Persisted  | Implemented    | PWChrono Technical Team  | Existing org baseline; local navigation reconciliation        |
| Dashboard                        | Dashboard tab and Home route           | Both    | Persisted  | Implemented    | HR Operations            | Existing org baseline; local tab/navigation visibility only   |
| Attendance                       | Attendance tab and attendance routes   | Both    | Mixed      | Partial        | HR Operations            | Existing org baseline; no new module development              |
| Leave management                 | Leaves tab and leave routes            | Both    | Persisted  | Implemented    | HR Operations            | Existing org baseline; local route/navigation binding only    |
| Holidays                         | Holidays tab and holiday route         | Both    | Persisted  | Implemented    | HR Operations            | Existing org baseline; local tab visibility only              |
| Employee directory and profile   | Directory and My Profile               | Both    | Persisted  | Implemented    | HR Operations            | Existing org baseline; no new module development              |
| Recruitment                      | Recruitment tab and recruitment routes | Both    | Persisted  | Implemented    | Recruitment/HR           | Existing org baseline; no new module development              |
| Onboarding                       | Onboarding tab and route               | Both    | Persisted  | Implemented    | HR Operations            | Existing org baseline; local route binding only               |
| Performance and goals            | Performance tab and routes             | Both    | Mixed      | Partial        | HR Management            | Existing org baseline; no new module development              |
| Training                         | Training tab and routes                | Both    | Mixed      | Partial        | Learning and Development | Existing org baseline; no new module development              |
| Expenses                         | Expenses tab and expense route         | Both    | Persisted  | Implemented    | Finance                  | Existing org baseline; local navigation entry only            |
| Payroll                          | Payroll tab and payroll route          | Both    | Persisted  | Implemented    | Payroll/Finance          | Existing org baseline; local route/navigation binding only    |
| Projects                         | Projects route and dashboard sections  | LWR     | Mixed      | Partial        | Project Operations       | Existing org baseline; no new module development              |
| Staffing and job requisitions    | Recruitment submodules                 | LWR     | Persisted  | Partial        | Recruitment/HR           | Existing org baseline; no new module development              |
| Administration and configuration | Configuration tab and admin routes     | Both    | Persisted  | Partial        | HR/System Administration | Existing org baseline; local navigation/access reconciliation |
| Reports                          | Reports Dashboard route                | LWR     | Persisted  | Partial        | HR Management            | Existing org baseline; local route binding only               |
| Approvals                        | Request-module approval views          | LWR     | Mixed      | Partial        | HR Manager               | Existing org baseline; architecture remains under review      |

## Standard module record

Copy this record when introducing a new business module.

### `[Module name]`

| Property                            | Value                                                   |
| ----------------------------------- | ------------------------------------------------------- |
| Business purpose                    | [TBD]                                                   |
| Business owner                      | [TBD]                                                   |
| Technical owner                     | [TBD]                                                   |
| Supported runtime                   | Lightning / LWR / Both                                  |
| Primary route                       | [TBD]                                                   |
| Lightning tab                       | [TBD]                                                   |
| Required Portal User feature        | [TBD]                                                   |
| Required profile object permissions | [TBD]                                                   |
| Guest accessible                    | Yes / No                                                |
| Data classification                 | Public / Internal / Confidential / Restricted           |
| Status                              | Implemented / Partial / Placeholder / Planned / Dormant |

#### Component inventory

| Component | Type                                     | Responsibility | Runtime | Apex or UI API dependency | Status  |
| --------- | ---------------------------------------- | -------------- | ------- | ------------------------- | ------- |
| `[TBD]`   | Container / Page / Form / List / Utility | [TBD]          | [TBD]   | [TBD]                     | Unknown |

#### Apex

| Class   | Responsibility | Sharing model | Guest boundary | Public methods | Test class |
| ------- | -------------- | ------------- | -------------- | -------------- | ---------- |
| `[TBD]` | [TBD]          | [TBD]         | [TBD]          | [TBD]          | [TBD]      |

#### Objects and fields

| Object  | Field   | Type  | Required | Read/write usage                | Access source                          | Used by |
| ------- | ------- | ----- | -------- | ------------------------------- | -------------------------------------- | ------- |
| `[TBD]` | `[TBD]` | [TBD] | Yes / No | Read / Create / Update / Delete | Portal profile / Salesforce permission | [TBD]   |

#### Dependencies and validation

| Dependency | Type                                                             | Direction          | Failure impact | Validation evidence |
| ---------- | ---------------------------------------------------------------- | ------------------ | -------------- | ------------------- |
| `[TBD]`    | Component / Apex / Object / Flow / Static resource / Integration | Inbound / Outbound | [TBD]          | [TBD]               |

## 1. Portal shell, authentication, and navigation

### Components

| Component            | Responsibility                                                    | Runtime       | Dependencies                                                               | Status      |
| -------------------- | ----------------------------------------------------------------- | ------------- | -------------------------------------------------------------------------- | ----------- |
| `pwchronoLogin`      | OTP login and portal-session initialization                       | LWR           | `PWChrono_AuthController`, `pwchronoSession`, `pwchronoUiAssets`           | Implemented |
| `pwchronoMainLayout` | Authentication boundary, shared header/sidebar, and content shell | LWR           | `PWChrono_AccessController`, `PWChrono_AuthController`, `pwchronoUiAssets` | Implemented |
| `pwchronoHeader`     | Header navigation, user actions, and logout                       | LWR           | Session utilities and router                                               | Implemented |
| `pwchronoSidebar`    | Feature-aware custom navigation                                   | LWR           | `PWChrono_NavigationController`, `pwchronoNavigationAccess`                | Implemented |
| `pwchronoUiAssets`   | Loads SmartHR, Bootstrap, and icon styles                         | LWR light DOM | `smarthr_assets` static resource                                           | Implemented |
| `pwchronoRouter`     | Shared route navigation utility                                   | Both          | Lightning navigation services                                              | Implemented |
| `pwchronoSession`    | Browser-side portal session contract                              | LWR           | Session storage and session events                                         | Implemented |

### Controllers and services

| Class                           | Responsibility                                         | Key dependencies                       | Status      |
| ------------------------------- | ------------------------------------------------------ | -------------------------------------- | ----------- |
| `PWChrono_AuthController`       | OTP authentication, session creation, and user context | `Portal_Users__c`, profile permissions | Implemented |
| `PWChrono_GuestSession`         | Server-side validation of Portal User sessions         | `Portal_Users__c`                      | Implemented |
| `PWChrono_AccessController`     | Resolves role and feature access                       | Profile and legacy access stores       | Partial     |
| `PWChrono_NavigationController` | Retrieves Experience navigation items                  | `NavigationLinkSet`                    | Implemented |
| `PWChrono_Utils`                | Shared Portal User resolution                          | `Portal_Users__c`, `User`              | Implemented |

### Key objects and fields

| Object                        | Important fields                                                                                   | Usage                                  | Dependencies                                      |
| ----------------------------- | -------------------------------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------------------- |
| `Portal_Users__c`             | `Email__c`, `Is_Active__c`, `Portal_User_Profile__c`, `Role__c`, `User__c`, session and OTP fields | Portal identity and custom session     | Profile, Salesforce User, authentication services |
| `Portal_User_Profile__c`      | Currently no custom configuration fields                                                           | Intended access and routing authority  | Portal Users and permission children              |
| `Portal_Object__c`            | `Object_API_Name__c`                                                                               | Registry of profile-controlled objects | Object permissions                                |
| `Portal_Object_Field__c`      | `Field_API_Name__c`, `Portal_Object__c`                                                            | Registry of profile-controlled fields  | Field permissions                                 |
| `Portal_Object_Permission__c` | Profile, object, CRUD flags                                                                        | Object-level portal access             | Profile and object registry                       |
| `Portal_Field_Permission__c`  | Profile, field, read/edit flags                                                                    | Field-level portal access              | Profile and field registry                        |

### Metadata dependencies

| Metadata                                    | Responsibility                            | Status                                              |
| ------------------------------------------- | ----------------------------------------- | --------------------------------------------------- |
| `PWChrono_Portal`                           | Standard Lightning navigation application | Implemented                                         |
| `PWChrono_Tab_Access`                       | Lightning tab and Apex access             | Partial review required                             |
| `PWChrono_Guest_Access`                     | Guest runtime permissions                 | Implemented; security review required per release   |
| `PWChrono_Portal_User_Access`               | Portal user permissions                   | Implemented; assignment model requires verification |
| `SFDC_Default_Navigation_Pulse_Work_Chrono` | LWR custom navigation                     | Implemented                                         |
| `Pulse_Work_Chrono1`                        | LWR site definition and views             | Implemented                                         |

## 2. Dashboard

| Category       | Inventory                                                                                                                                                 |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Components     | `pwchronoDashboard`, `pwchronoDashboardPage`, dashboard cards and table sections                                                                          |
| Controllers    | `PWChrono_DashboardController`, `PWChrono_AccessController`                                                                                               |
| Objects        | `Portal_Users__c`, `PWChrono_Leave_Allocation__c`, `PWChrono_Shift_Assignment__c`, `PWChrono_Salary_Slip__c`, `PWChrono_Goal__c`, `PWChrono_Appraisal__c` |
| Primary fields | Employee lookups, status fields, dates, leave balances, salary periods, goal/appraisal status                                                             |
| Entry points   | `PWChrono_Dashboard` tab, Home/dashboard Experience views                                                                                                 |
| Dependencies   | Portal session, profile features, shared navigation and UI assets                                                                                         |
| Status         | Implemented; standard-tab styling differs from LWR                                                                                                        |

## 3. Attendance

| Category                 | Inventory                                                                                                                                                                                                                                                    |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Components               | `pwchronoAttendanceTracker`, `pwchronoAttendanceAdmin`, `pwchronoAttendanceSettings`, `pwchronoAttendanceModal`, `pwchronoAttendanceRequestForm`, request list/detail components, `pwchronoOvertime`, `pwchronoTimesheets`, `pwchronoWorkFromHomeManagement` |
| Controllers and services | `PWChrono_AttendanceController`, `PWChrono_AttendanceSelector`, `PWChrono_AttendanceService`, `PWChrono_AttendanceValidator`, `PWChrono_RequestService`                                                                                                      |
| Objects                  | `PWChrono_Attendance_Request__c`, `PWChrono_Shift_Assignment__c`, `PWChrono_Shift_Type__c`, `PWChrono_Holiday__c`, `Portal_Users__c`                                                                                                                         |
| Primary fields           | Employee, approver, request type, status, request date, start/end time, comments, shift, overtime and WFH values                                                                                                                                             |
| Dependencies             | Portal session, request validation, notifications, attachments, comments                                                                                                                                                                                     |
| Status                   | Partial; overtime, WFH, and timesheet persistence require completion                                                                                                                                                                                         |

## 4. Leave management

| Category                 | Inventory                                                                                                                                                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Components               | `pwchronoLeaveManagement`, `pwchronoLeaveApplication`, `pwchronoLeaveEmployee`, `pwchronoLeaveAdmin`, `pwchronoLeaveRequestDetail`, `pwchronoLeaveCalendar`, `pwchronoLeaveBalanceWidget`, `pwchronoLeaveSettings` |
| Controllers and services | `PWChrono_LeaveController`, `PWChrono_LeaveSelector`, `PWChrono_LeaveService`, `PWChrono_LeaveValidator`, `PWChrono_LeaveBalanceService`, `PWChrono_LeaveLedgerService`, `PWChrono_RequestService`                 |
| Objects                  | `PWChrono_Leave__c`, `PWChrono_Leave_Type__c`, `PWChrono_Leave_Allocation__c`, `PWChrono_Leave_Block_Date__c`, `PWChrono_Leave_Ledger__c`, `Portal_Users__c`                                                       |
| Primary fields           | Employee, leave type, start/end date, total days, status, approver, approval comments, allocation totals, ledger transaction values                                                                                |
| Dependencies             | Holidays, attendance context, request comments, attachments, notifications                                                                                                                                         |
| Status                   | Implemented; approval routing must move to Portal User Profile                                                                                                                                                     |

## 5. Holidays

| Category       | Inventory                                                       |
| -------------- | --------------------------------------------------------------- |
| Components     | `pwchronoHolidayCalendar`, `pwchronoHolidays` and page wrappers |
| Controllers    | `PWChrono_HolidayController`                                    |
| Objects        | `PWChrono_Holiday__c`                                           |
| Primary fields | Name, holiday date, type, description, active status            |
| Dependencies   | Attendance and leave date validation                            |
| Status         | Implemented                                                     |

## 6. Employee directory and profile

| Category       | Inventory                                                                                                                                      |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Components     | `pwchronoEmployeeDirectory`, `pwchronoEmployeeDirectoryPage`, `pwchronoProfileUpdate`, `pwchronoProfileUpdatePage`, avatar and file components |
| Controllers    | `PWChrono_EmployeeDirectoryController`, `PWChrono_ProfileController`, `PWChrono_AdminController`                                               |
| Objects        | `Portal_Users__c`, `Account`, `Contact`, `User`, `ContentVersion`, `ContentDocument`, `ContentDistribution`                                    |
| Primary fields | Name, email, phone, department, designation, manager, joining date, address, emergency contact, profile photo/file IDs                         |
| Dependencies   | Portal session, file visibility, object and field permissions                                                                                  |
| Status         | Implemented                                                                                                                                    |

## 7. Recruitment

| Category                 | Inventory                                                                                                                                                                                         |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Components               | `pwchronoRecruitment`, `pwchronoRecruitmentPipeline`, `pwchronoJobOpeningsViewer`, `pwchronoInterviewScheduler`, `pwchronoOfferLetterGenerator`, `pwchronoEmployeeReferral`                       |
| Controllers and services | `PWChrono_RecruitmentController`, `PWChrono_RecruitmentService`, `PWChrono_EmployeeReferralController`                                                                                            |
| Objects                  | `PWChrono_Job_Opening__c`, `PWChrono_Job_Applicant__c`, `PWChrono_Interview__c`, `PWChrono_Offer_Letter__c`, `PWChrono_Employee_Referral__c`, `PWChrono_Department__c`, `PWChrono_Designation__c` |
| Primary fields           | Job, applicant/contact details, stage, source, interviewer, schedule, offer status, referral employee                                                                                             |
| Dependencies             | Onboarding creation, file storage, guest session and recruitment feature                                                                                                                          |
| Status                   | Implemented                                                                                                                                                                                       |

## 8. Onboarding

| Category       | Inventory                                                               |
| -------------- | ----------------------------------------------------------------------- |
| Components     | `pwchronoOnboardingChecklist`, onboarding page wrappers                 |
| Controllers    | `PWChrono_OnboardingController`, recruitment service onboarding handoff |
| Objects        | `PWChrono_Onboarding_Task__c`, `Portal_Users__c`                        |
| Primary fields | Employee, task, category, due date, completion date, status, owner      |
| Dependencies   | Recruitment, Portal User creation, notifications                        |
| Status         | Implemented                                                             |

## 9. Performance and goals

| Category       | Inventory                                                                            |
| -------------- | ------------------------------------------------------------------------------------ |
| Components     | `pwchronoAppraisalForm`, `pwchronoPerformanceAppraisal`, performance page components |
| Controllers    | `PWChrono_PerformanceController`                                                     |
| Objects        | `PWChrono_Appraisal__c`, `PWChrono_Goal__c`, `Portal_Users__c`                       |
| Primary fields | Employee, reviewer, review period, rating, status, goal target, completion, comments |
| Dependencies   | Manager relationship, dashboard summaries, notifications                             |
| Status         | Partial; some performance surfaces still use mock data                               |

## 10. Training

| Category       | Inventory                                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------ |
| Components     | `pwchronoTrainingRegistration`, `pwchronoTrainingManagement`, `trainingList`                                       |
| Controllers    | `PWChrono_TrainingController`                                                                                      |
| Objects        | `PWChrono_Training_Program__c`, `PWChrono_Training_Event__c`, `PWChrono_Training_Attendance__c`, `Portal_Users__c` |
| Primary fields | Program, event date, trainer, capacity, attendee, registration status, attendance status                           |
| Dependencies   | Portal profile feature access, dashboard/reporting                                                                 |
| Status         | Partial; `trainingList` and management placeholder require reconciliation                                          |

## 11. Expenses

| Category                 | Inventory                                                                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Components               | `pwchronoExpenseClaimPortal`, `pwchronoExpenseManagement`, claim list/form/detail/admin, line item editor, expense dashboard                |
| Controllers and services | `PWChrono_ExpenseController`, `PWChrono_ExpenseSelector`, `PWChrono_ExpenseService`, `PWChrono_ExpenseValidator`, `PWChrono_RequestService` |
| Objects                  | `PWChrono_Expense_Claim__c`, `PWChrono_Expense_Item__c`, `Portal_Users__c`                                                                  |
| Primary fields           | Employee, claim date, amount, currency, status, approver, comments, category, receipt/file reference                                        |
| Dependencies             | Attachments, comments, notifications, profile-based approval routing                                                                        |
| Status                   | Implemented; approval routing migration required                                                                                            |

## 12. Payroll

| Category       | Inventory                                                                                                        |
| -------------- | ---------------------------------------------------------------------------------------------------------------- |
| Components     | `pwchronoSalarySlipViewer`, payroll page and dashboard components                                                |
| Controllers    | `PWChrono_PayrollController`                                                                                     |
| Objects        | `PWChrono_Salary_Assignment__c`, `PWChrono_Salary_Slip__c`, `PWChrono_Structure_Component__c`, `Portal_Users__c` |
| Primary fields | Employee, salary structure, period, gross, deductions, net pay, component amounts, slip status                   |
| Dependencies   | Portal session, profile Payroll feature, file/download behavior                                                  |
| Status         | Implemented                                                                                                      |

## 13. Projects

| Category       | Inventory                                                                                      |
| -------------- | ---------------------------------------------------------------------------------------------- |
| Components     | `pwchronoProjectsGrid`, dashboard project/task components                                      |
| Controllers    | Project and dashboard methods in `PWChrono_AdminController` and `PWChrono_DashboardController` |
| Objects        | `PWChrono_Project__c`, `PWChrono_Invoice__c`, `Portal_Users__c`                                |
| Primary fields | Project name, manager, dates, status, progress, customer/account, financial values             |
| Dependencies   | Dashboard, employee directory, exports                                                         |
| Status         | Partial; feature contract and export behavior require completion                               |

## 14. Staffing plans and job requisitions

| Category       | Inventory                                                                                                                                           |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Components     | `pwchronoStaffingPlan`, `pwchronoJobRequisition` and page wrappers                                                                                  |
| Controllers    | `PWChrono_StaffingPlanController`, `PWChrono_JobRequisitionController`                                                                              |
| Objects        | `PWChrono_Staffing_Plan__c`, `PWChrono_Staffing_Plan_Detail__c`, `PWChrono_Job_Requisition__c`, `PWChrono_Department__c`, `PWChrono_Designation__c` |
| Primary fields | Plan period, department, designation, planned headcount, vacancies, requisition status, requested positions                                         |
| Dependencies   | Recruitment, HR Manager access, profile configuration                                                                                               |
| Status         | Partial                                                                                                                                             |

## 15. Administration, configuration, and reports

| Category       | Inventory                                                                                                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Components     | `pwchronoConfigurationCenter`, `pwchronoNewUserForm`, `pwchronoProfilePermissions`, `pwchronoAdminDashboard`, `pwchronoAdminDashboardReports`, legacy role/feature components   |
| Controllers    | `PWChrono_AdminController`, `PWChrono_ConfigurationController`, `PWChrono_ReportsDashboardController`, `PWChrono_PermissionController`, `PWChrono_RoleFeatureMappingController` |
| Objects        | Portal access objects, feature settings, role mappings, reporting module objects                                                                                                |
| Primary fields | `Portal_User_Profile__c`, active status, CRUD flags, field read/edit flags, module settings                                                                                     |
| Dependencies   | Verified admin portal session, Portal User Profile object permissions, custom metadata deployment callback, every business module                                               |
| Status         | Partial; Configuration Center user assignment now uses Portal User Profiles, while other legacy runtime access mechanisms still require consolidation                           |

## 16. Request comments, attachments, and notifications

| Category       | Inventory                                                                                                              |
| -------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Components     | Request comments, attachment panel, request action/header/status components                                            |
| Services       | `PWChrono_RequestCommentService`, `PWChrono_RequestAttachmentService`, `PWChrono_RequestService`                       |
| Objects        | `PWChrono_Request_Comment__c`, `ContentVersion`, `ContentDocumentLink`, `ContentDocument`, `TLG_Task_Notifications__c` |
| Primary fields | Parent record, author, comment, file identifiers, notification recipient, title, body, read state                      |
| Dependencies   | Leave, attendance, expense, Portal User to Salesforce User mapping                                                     |
| Status         | Implemented                                                                                                            |

## 17. Portal User Profile accessibility and configuration

### Canonical access model

`Portal_Users__c.Portal_User_Profile__c` must be the only runtime source for
feature visibility, object access, field access, and approval routing. The
target resolution contract is:

```text
Verified custom portal session
  -> Portal_Users__c
    -> Portal_User_Profile__c
      -> enabled features
      -> object permissions
      -> field permissions
      -> approval profile and routing settings
```

Do not introduce runtime fallbacks to:

- `Portal_Users__c.Role__c`
- `Portal_Users__c.Access_Features__c`
- `PWChrono_User_Feature_Access__c`
- `PWChrono_Role_Feature_Mapping__mdt`
- Salesforce `Profile` as the OTP Portal User identity
- `UserInfo.getUserId()` for custom Portal User approval identity

Legacy stores may be read only by a controlled migration utility and must not
remain part of the post-cutover access resolver.

### Implemented profile-assignment administration

The standard Salesforce `PWChrono_Admin` and `Configuration_Center` tabs both
load `pwchronoConfigurationCenter`. This active administration component now:

- lists the `Portal_User_Profile__c` assigned to every `Portal_Users__c` record;
- assigns an existing profile through
  `PWChrono_ConfigurationController.assignUserProfile`;
- requires a profile when creating a Portal User through
  `pwchronoNewUserForm`; and
- authorizes a guest caller in Apex only when the caller's assigned profile has
  view and edit permission for `Portal_Users__c`.

`pwchronoProfilePermissions` remains the profile-record component used to
maintain object and field permission records. Older per-user feature methods in
`PWChrono_ConfigurationController` remain temporarily for backward
compatibility, but the active Configuration Center and New User Form no longer
call them. They must be retired after all remaining legacy consumers are
migrated.

### Portal User Profile schema inventory

| Field                         | Type                                                         | Purpose                                                   | Required    | Current state | Migration source                 |
| ----------------------------- | ------------------------------------------------------------ | --------------------------------------------------------- | ----------- | ------------- | -------------------------------- |
| `Name`                        | Auto Number                                                  | Salesforce record identifier                              | Yes         | Existing      | Existing profile records         |
| `Display_Name__c`             | Text                                                         | Human-readable profile name                               | Yes         | Planned       | Role/profile mapping             |
| `Developer_Key__c`            | Text, unique                                                 | Stable programmatic profile key                           | Yes         | Planned       | New controlled values            |
| `Profile_Type__c`             | Restricted picklist                                          | Employee, Manager, HR Manager, and approved profile types | Yes         | Planned       | `Role__c`                        |
| `Enabled_Features__c`         | Restricted multi-select picklist or normalized profile child | Navigation and module feature access                      | Yes         | Planned       | Per-user and role feature stores |
| `Can_Approve__c`              | Checkbox                                                     | Whether profile members can approve requests              | Yes         | Planned       | New policy                       |
| `Default_Approval_Profile__c` | Self lookup                                                  | Destination profile for submitted requests                | Conditional | Planned       | `Reports_To__c` migration policy |
| `Approval_Scope__c`           | Restricted picklist                                          | Defines supported approval scope                          | Conditional | Planned       | New policy                       |
| `Is_Active__c`                | Checkbox                                                     | Enables or disables the profile                           | Yes         | Planned       | New policy                       |

Record the final decision on whether profile features are stored directly in
`Enabled_Features__c` or in a normalized child object. If a child object is
used, it must be owned by and queried exclusively through
`Portal_User_Profile__c`.

### Profile assignment inventory

| Profile key | Display name   | Profile type              | Active users | Inactive users | Permission records | Approval destination | Verified date |
| ----------- | -------------- | ------------------------- | -----------: | -------------: | ------------------ | -------------------- | ------------- |
| `PUP-0000`  | [TBD]          | Broad HR Admin usage      |            6 |              2 | 22 object, 0 field | [TBD]                | 2026-08-31    |
| `PUP-0001`  | [TBD]          | Restricted Employee usage |            2 |              0 | 1 object, 0 field  | [TBD]                | 2026-08-31    |
| Unassigned  | Not applicable | Mixed                     |            5 |              0 | None               | None                 | 2026-08-31    |

Current live-org review found 15 Portal Users, of which 10 have a profile and 5
do not. Resolve every unassigned user before enabling profile-only enforcement.
Five active, profiled users have non-placeholder email addresses suitable for
OTP delivery. Other active records either lack an email, use an `example.com`
address, or have no profile and are not considered fully test-ready.

### Feature-access matrix

| Profile    | Dashboard | Attendance | Leave | Expenses | Payroll | Recruitment | Onboarding | Performance | Training | Reports | Administration |
| ---------- | --------- | ---------- | ----- | -------- | ------- | ----------- | ---------- | ----------- | -------- | ------- | -------------- |
| Employee   | [TBD]     | [TBD]      | [TBD] | [TBD]    | [TBD]   | [TBD]       | [TBD]      | [TBD]       | [TBD]    | [TBD]   | [TBD]          |
| Manager    | [TBD]     | [TBD]      | [TBD] | [TBD]    | [TBD]   | [TBD]       | [TBD]      | [TBD]       | [TBD]    | [TBD]   | [TBD]          |
| HR Manager | [TBD]     | [TBD]      | [TBD] | [TBD]    | [TBD]   | [TBD]       | [TBD]      | [TBD]       | [TBD]    | [TBD]   | [TBD]          |

### Object-access matrix

Create one row per profile and portal object. The permission source must be a
`Portal_Object_Permission__c` record linked to the profile.

| Profile | Object  | View     | Create   | Edit     | Delete   | Record scope              | Verified date |
| ------- | ------- | -------- | -------- | -------- | -------- | ------------------------- | ------------- |
| `[TBD]` | `[TBD]` | Yes / No | Yes / No | Yes / No | Yes / No | Own / Team / All / Custom | [TBD]         |

### Field-access matrix

Create one row per restricted field. The permission source must be a
`Portal_Field_Permission__c` record linked to the profile.

| Profile | Object  | Field   | View     | Edit     | Masking rule          | Reason |
| ------- | ------- | ------- | -------- | -------- | --------------------- | ------ |
| `[TBD]` | `[TBD]` | `[TBD]` | Yes / No | Yes / No | None / Partial / Full | [TBD]  |

The 2026-08-30 live review found no field-permission records. Field-level
enforcement must not be considered configured until this table and the live
records are populated and tested.

### Guest and authenticated-user access

| Control            | Guest OTP user                                      | Internal Salesforce user                                 | Evidence             | Owner                           |
| ------------------ | --------------------------------------------------- | -------------------------------------------------------- | -------------------- | ------------------------------- |
| Session validation | `PWChrono_GuestSession` token and expiry validation | Salesforce session                                       | [TBD test/deploy ID] | PWChrono Technical Team         |
| Portal identity    | Verified `Portal_Users__c` ID                       | Mapped Portal User or explicitly supported internal path | [TBD]                | HR/System Administration        |
| Feature access     | Portal User Profile only                            | Document whether profile enforcement also applies        | [TBD]                | HR/System Administration        |
| Object access      | Profile object permissions plus Apex enforcement    | Salesforce CRUD/FLS and application policy               | [TBD]                | HR/System Administration        |
| Field access       | Profile field permissions plus Apex enforcement     | Salesforce FLS and application policy                    | [TBD]                | HR/System Administration        |
| Record access      | Explicit Apex scope rules                           | Sharing plus application policy                          | [TBD]                | PWChrono Technical Team         |
| Apex class access  | Guest permission set/profile                        | Permission set/profile                                   | [TBD]                | Salesforce System Administrator |
| File access        | Explicit file ownership/link checks                 | Salesforce file access                                   | [TBD]                | PWChrono Technical Team         |

### Approval routing matrix

| Request type | Source object                    | Submitter profile | Approver profile | Routing field          | Approval component        | Controller/service              | Status             |
| ------------ | -------------------------------- | ----------------- | ---------------- | ---------------------- | ------------------------- | ------------------------------- | ------------------ |
| Leave        | `PWChrono_Leave__c`              | [TBD]             | HR Manager       | Planned profile lookup | Leave approval views      | Leave and request services      | Migration required |
| Attendance   | `PWChrono_Attendance_Request__c` | [TBD]             | HR Manager       | Planned profile lookup | Attendance approval views | Attendance and request services | Migration required |
| Expense      | `PWChrono_Expense_Claim__c`      | [TBD]             | HR Manager       | Planned profile lookup | Expense approval views    | Expense and request services    | Migration required |
| Appraisal    | `PWChrono_Appraisal__c`          | [TBD]             | [TBD]            | [TBD]                  | Performance views         | Performance controller          | Review required    |
| Other        | `[TBD]`                          | [TBD]             | [TBD]            | [TBD]                  | [TBD]                     | [TBD]                           | Unknown            |

The supported custom approval implementation should store both the destination
profile and the actual Portal User who made the decision. Routing belongs to
the profile; the individual user field is retained only for audit history.

### Accessibility and configuration release checklist

- [ ] Every active Portal User has exactly one active Portal User Profile.
- [ ] Every profile has a stable developer key and display name.
- [ ] HR Manager is represented by an explicit profile value.
- [x] Configuration Center profile assignment writes only
      `Portal_Users__c.Portal_User_Profile__c`.
- [x] Guest profile assignment is authorized server-side through the caller's
      Portal User Profile object permission for `Portal_Users__c`.
- [ ] Feature access across every runtime module resolves only from the Portal
      User Profile contract.
- [ ] All active portal objects have profile object-permission records.
- [ ] Restricted fields have profile field-permission records.
- [ ] Guest Apex calls validate the server-issued portal session.
- [ ] Guest, employee, manager, HR Manager, and unauthorized cases are tested.
- [ ] Approval requests route to a profile, not `Reports_To__c` or Salesforce
      `ActorId`.
- [ ] The acting Portal User is recorded for approval audit history.
- [ ] Legacy access records are migrated and removed from runtime reads.
- [ ] Permission-denied responses do not expose restricted data.
- [ ] Deployment, site publication, and authenticated browser evidence are
      recorded separately.

## 18. Styling and runtime compatibility

| Concern               | Lightning tabs                           | LWR site                                | Required action                            |
| --------------------- | ---------------------------------------- | --------------------------------------- | ------------------------------------------ |
| Shared SmartHR assets | Direct tab roots often bypass the loader | Loaded by `pwchronoMainLayout`          | Treat LWR shell as canonical               |
| Bootstrap classes     | Unreliable across shadow boundaries      | Supported in consistent light-DOM pages | Standardize active LWR components          |
| Component CSS         | Mixed scoped and global assumptions      | Mixed                                   | Record render mode per component           |
| Navigation chrome     | Salesforce standard navigation           | Custom header/sidebar                   | Keep runtime-specific composition          |
| Browser verification  | [TBD]                                    | [TBD]                                   | Test supported runtime and viewport matrix |

For every component, add these runtime fields to its module inventory:

| Component | Shadow/light DOM | Loads shared assets  | Lightning target | Community target | Responsive review | Accessibility review |
| --------- | ---------------- | -------------------- | ---------------- | ---------------- | ----------------- | -------------------- |
| `[TBD]`   | Shadow / Light   | Yes / No / Inherited | [TBD]            | [TBD]            | [TBD]             | [TBD]                |

## 19. Integrations, resources, and automation

| Dependency         | Type                  | Used by                             | Authentication/configuration         | Failure behavior                                  | Owner                                     | Status          |
| ------------------ | --------------------- | ----------------------------------- | ------------------------------------ | ------------------------------------------------- | ----------------------------------------- | --------------- |
| `smarthr_assets`   | Static resource       | Shared LWR UI                       | Salesforce static resource           | Page falls back to partially unstyled UI          | PWChrono Technical Team                   | Implemented     |
| Salesforce Files   | Platform service      | Profile and request attachments     | Salesforce file permissions          | Upload/download error state                       | PWChrono Technical Team                   | Implemented     |
| Email/OTP delivery | Platform/integration  | Authentication                      | [TBD]                                | Login cannot complete                             | PWChrono Technical Team                   | Implemented     |
| Chart library      | Static resource       | Dashboard components                | Component-specific loaders           | Charts unavailable; data should remain readable   | PWChrono Technical Team                   | Partial         |
| Flows              | Salesforce automation | Notifications and onboarding        | Flow metadata                        | Module-specific                                   | HR Operations and PWChrono Technical Team | Review required |
| Approval Processes | Salesforce automation | Dormant generic approval controller | None found in live org on 2026-08-30 | Generic work-item dashboard has no process source | HR Management                             | Dormant         |

## 20. Complete object catalog

### Portal and configuration objects

- `Portal_Users__c`
- `Portal_User_Profile__c`
- `Portal_Object__c`
- `Portal_Object_Field__c`
- `Portal_Object_Permission__c`
- `Portal_Field_Permission__c`
- `PWChrono_User_Feature_Access__c`
- `PWChrono_Role_Feature_Mapping__mdt`
- `PWChrono_Feature_Settings__c`
- `PWChrono_Settings__mdt`

### Business objects

- `PWChrono_Appraisal__c`
- `PWChrono_Attendance_Request__c`
- `PWChrono_Company_Policy__c`
- `PWChrono_Department__c`
- `PWChrono_Designation__c`
- `PWChrono_Employee_Referral__c`
- `PWChrono_Expense_Claim__c`
- `PWChrono_Expense_Item__c`
- `PWChrono_Goal__c`
- `PWChrono_Holiday__c`
- `PWChrono_Interview__c`
- `PWChrono_Invoice__c`
- `PWChrono_Job_Applicant__c`
- `PWChrono_Job_Opening__c`
- `PWChrono_Job_Requisition__c`
- `PWChrono_Leave__c`
- `PWChrono_Leave_Allocation__c`
- `PWChrono_Leave_Block_Date__c`
- `PWChrono_Leave_Ledger__c`
- `PWChrono_Leave_Type__c`
- `PWChrono_Offer_Letter__c`
- `PWChrono_Onboarding_Task__c`
- `PWChrono_Project__c`
- `PWChrono_Request_Comment__c`
- `PWChrono_Salary_Assignment__c`
- `PWChrono_Salary_Slip__c`
- `PWChrono_Shift_Assignment__c`
- `PWChrono_Shift_Type__c`
- `PWChrono_Staffing_Plan__c`
- `PWChrono_Staffing_Plan_Detail__c`
- `PWChrono_Structure_Component__c`
- `PWChrono_Tax_Declaration__c`
- `PWChrono_Training_Attendance__c`
- `PWChrono_Training_Event__c`
- `PWChrono_Training_Program__c`
- `TLG_Task_Notifications__c`

### Salesforce platform objects

- `Account`
- `Contact`
- `User`
- `Event`
- `NavigationLinkSet`
- `ContentVersion`
- `ContentDocument`
- `ContentDocumentLink`
- `ContentDistribution`

### Dormant approval infrastructure

- `ProcessInstance`
- `ProcessInstanceWorkitem`

These approval objects are referenced by source but are not considered an
active portal approval implementation until an approved custom portal contract
or Salesforce Approval Process is configured and verified.

## 21. Release and verification history

| Date       | Scope                                   | Git commit           | Validation/deploy ID | Tests                        | Site published | Browser verified | Reviewer     |
| ---------- | --------------------------------------- | -------------------- | -------------------- | ---------------------------- | -------------- | ---------------- | ------------ |
| 2026-08-30 | Initial reconciliation dry run          | Not committed        | `0Afg800000BaxsrCAB` | 14/14 metadata, 5/5 Apex     | No             | No               | Codex review |
| 2026-08-30 | Pre-commit reconciliation revalidation  | Pending local commit | `0Afg800000BdRjZCAV` | 14/14 metadata, 5/5 Apex     | No             | No               | Codex review |
| 2026-08-30 | Portal navigation and access deployment | `fdce2a5`            | `0Afg800000BcmepCAB` | 14/14 metadata, 5/5 Apex     | No             | No               | Codex review |
| 2026-08-31 | Pulse Work Chrono site publication      | `f4b0f67`            | `08Pg800000JQ8U7EAL` | Deployment previously passed | Yes            | No               | Codex review |
| [TBD]      | [TBD]                                   | [TBD]                | [TBD]                | [TBD]                        | Yes / No       | Yes / No         | [TBD]        |

## 22. Open inventory actions

- [ ] Assign document, product, technical, and security owners.
- [ ] Verify every component target and render mode.
- [ ] Expand every module's field inventory from object metadata.
- [ ] Record CRUD/FLS and custom profile enforcement for each Apex method.
- [ ] Resolve the invalid `Portal_Object__c` record with no API name.
- [ ] Populate missing field-permission records.
- [ ] Assign all Portal Users to an approved profile.
- [ ] Reconcile the locally defined `Session_Locked_Until__c` field with the
      live org before deploying Apex classes that reference it.
- [ ] Complete the profile-only access migration plan.
- [ ] Complete the HR Manager profile approval-routing design.
- [ ] Mark placeholder and mock-backed modules explicitly.
- [ ] Record all active flows, scheduled jobs, triggers, and external services.
- [ ] Add authenticated browser evidence for supported LWR roles and viewports.
