# PWChrono HRMS module flows and development review

Review date: 15 September 2026. Audience: product owner, HR administrators, managers and implementation team.

## Executive summary

The portal has real Salesforce services for its main HR workflows, but several published pages were still connected to template demonstrations or incomplete presentation components. A button appearing on a page did not always mean that the action saved a record. The current remediation connects existing services, replaces misleading dashboard displays, and repairs navigation and menus.

Use this guide to understand the entry point, responsible user, prerequisites, action and resulting record for each module. Source review establishes the implemented flow; it does not certify that every business scenario has been exercised with every role. Live checks and release evidence are recorded separately in the accompanying review log.

### At a glance

- Employee identity is held in Portal_Users\_\_c. A portal role and profile feature grants determine available functions; the server still checks access.
- Employee requests generally move from draft to submission and then an approver decision. A dashboard count is a summary, not a separate transaction.
- Payroll, recruitment, training and reporting depend on configuration and underlying records. Empty results should be investigated by checking scope and data, not by adding demonstration numbers.

### Getting started

An administrator creates or maintains the employee, assigns a portal profile, sets the reporting manager, and grants the required features. The employee signs in through the portal login flow and receives a session. When that session expires or becomes invalid, the shell clears it and returns the user to login. On a fresh sign-in, the user should see only the navigation allowed by the assigned access.

## Key findings

### Broken actions and their causes

The manager dashboard contained fixed names and counts. Approvals and Configuration pointed to placeholders, and Training included a demonstration list. Several menus relied on Bootstrap behavior that did not work inside the components. Add Project referenced a missing handler. Leave type and training writes omitted required session arguments.

The repairs connect existing services, provide a leave and attendance approval queue, activate Configuration Center and training registration, and replace broken menus. Project details, employee email links, attendance reports, timesheet sorting and dashboard destinations are corrected. Performance now opens goals; Appraisals remains the appraisal workspace.

### Dashboard access failure

The HR administrator saw the correct navigation but dashboard queries reported access denied. Direct controller calls inherited Salesforce Guest visibility and could not read private identity and permission records. The repaired API verifies the portal session before invoking existing role, feature and ownership checks in the portal data context. Invalid sessions and unauthorized employee requests remain denied. No public record-sharing rule is added.

### Data meaning and presentation

The old dashboard confused approval status with punctuality and access roles with employment status. The revised view uses actual request status names and recorded dates. It removes fixed people, unsupported financial tiles and fabricated growth percentages.

The SmartHR reference informs the welcome panel, metric cards, department chart, spacing and responsive grids. PWChrono retains its branding and theme. Counts represent organization totals only where the server returns those totals.

### Business acceptance

Verify persistence after refresh, approver ownership, cross-user boundaries and empty/error states. Metadata deployment alone does not prove payroll processing or recruitment-to-onboarding handoffs. The process gaps described in this guide remain part of business acceptance.

## Module flows

### Access and employee administration

**Login and session.** Entry: Login. The employee uses the configured portal login flow. The shell loads access and user details after authentication. Expiry and invalid-session responses clear portal state and navigate to login. Logout revokes the matching server session. A fresh login is required to resume protected work.

**Employee directory.** Entry: Employee Directory. Authorized users search, filter and open employee profiles. Administrators use the available create/edit controls to maintain employee information. The saved employee appears in later directory queries. The Email action opens an email draft in the user's mail application; it does not send a message automatically.

**My profile.** Entry: My Profile. The employee reviews and updates the profile fields supported by the form. The page resolves the current employee; record-page use can supply an employee context. Save persists through the profile controller. Administrators should verify field-level edit expectations for their organization.

**Configuration Center.** Entry: Administration then Configuration. Administrators select a user, assign a portal profile and reporting manager, and save user setup. Global feature settings control which capabilities are enabled. Leave and attendance configuration are available as additional tabs. Assignment changes affect subsequent access checks and navigation.

**Role feature mapping and Admin Settings.** Entry: Administration. Authorized administrators maintain role-to-feature mappings and portal access flags. The configuration must agree with profile grants and the user's role ceiling. These controls determine eligibility to use features; granting access does not create leave allocations, shifts or payroll data.

### Attendance and time management

**My attendance.** Entry: Attendance or Employee Attendance. The employee reviews dates and recorded check-in/check-out times, filters the display and opens the attendance modal for a supported entry or correction. A saved request is retrieved again and displayed with its state. Report and CSV actions use the displayed data; the report is a selected/latest displayed day's summary.

**Attendance administration.** Entry: Attendance Admin. Authorized managers or administrators inspect employee attendance rows and drill into an employee's attendance view. Date and department filters narrow the displayed scope. The approval queue handles submitted attendance requests assigned to the current approver.

**Attendance approval.** Entry: Approvals, then Attendance requests. The queue loads submitted requests assigned to the signed-in approver. Open Approve or Reject, review the employee and reason, add comments and confirm. Rejection requires a reason in the revised UI. The server validates the actor and transition; a successful decision refreshes the queue.

**Shift roster and settings.** Entry: Shift Roster and Attendance Settings. The employee views weekly shift assignments. Administrators create or edit shift types, including the fields exposed by the settings form. Assignments must exist for the employee and relevant dates before the roster or dashboard can show them. Viewing a shift type alone does not assign it.

**Timesheets.** Entry: Timesheets. The employee selects a project, date and worked hours, then saves a work log. Authorized reviewers can decide eligible work logs. Search, project filters and sorting operate on retrieved rows. Export reflects the component's current export implementation. Confirm the selected project and employee before saving.

**Overtime and work from home.** Entry: Overtime or WFH Management. A user creates the corresponding work-log type with the required date, time/hours and supporting information. Reviewer controls depend on access and current status. Approved/rejected outcomes are saved through the work-log controller. These records do not themselves prove that a payroll adjustment has been calculated.

### Leave and approvals

**My leave.** Entry: Leave Management then the employee leave page. The employee chooses a leave type, dates and reason, supplies required supporting information, and saves or submits using the available controls. Validation checks the request. Submitted records are assigned to an approver; the employee can later review status and details.

**Team leave.** Entry: Leaves Admin. The reviewer sees requests assigned to them, with status and leave-type filters. The repaired query includes historical states, so approved and rejected counts can be meaningful. Approve/reject operations call the leave approval service. This page's queue is an approver view, not necessarily every leave record in the organization.

**Approval queue.** Entry: Approvals or Manager Dashboard. The revised queue provides separate leave and attendance request types, confirmation before a write, required rejection comments and an explicit result/error message. Only submitted items are actionable. It is not a replacement for all Salesforce approval-process work items or a completed appraisal-review workflow.

**Leave settings and entitlement.** Entry: Leave Settings. Administrators add/edit leave types, maximum days, carry-forward settings, approval/certificate requirements and active status. Session arguments accompany saves. Leave allocations are separate employee entitlement records; changing a leave type does not automatically allocate days to every employee.

**Holidays.** Entry: Holidays. Users view upcoming holiday records. Those dates provide business-calendar context for leave and attendance. Holiday maintenance and calendar scope must be configured by the administrator; the portal calendar is a viewing surface.

### Recruitment and onboarding

**Recruitment dashboard and pipeline.** Entry: Recruitment. The dashboard loads recruitment metrics; its tabs expose the associated planning and candidate workflows. Authorized recruiters view applicants and move them between supported pipeline states. A state change updates the applicant record. An applicant appearing in a column is not proof that an interview or offer exists.

**Staffing plans.** Entry: Recruitment then Staffing Plans. HR creates a plan with relevant designation/department entries, saves its details and moves it through available states. A plan provides headcount planning context for requisitions. Deletion and status changes use their specific server methods and must respect the current record state.

**Job requisitions and openings.** Entry: Recruitment then Job Requisitions; Job Openings for published/open positions. HR records a requirement, optionally associates a staffing plan, and updates its state. Openings and applicants are related recruitment records. The implementation should be checked before assuming that every requisition state automatically creates or publishes an opening.

**Employee referrals.** Entry: Recruitment then Referrals. Authorized users create a referral, associate the relevant designation or applicant where available, and save it. The referral is tracked independently from the applicant pipeline; a referral alone does not mark an applicant as hired.

**Interview scheduling.** Entry: Interview Scheduler. Select an applicant, review existing interviews, choose interviewers and complete the scheduling form. Save calls the recruitment scheduling service. Treat calendar invitations and outbound notifications as separate behaviors to verify; the existence of an interview record does not prove delivery of an invitation.

**Offer letters.** Entry: Offer Letter. Select the applicant and relevant designation and complete the offer details. Generate invokes the recruitment service. Review the generated result before any external communication. The offer-generation action is distinct from accepting an offer or completing employee onboarding.

**Onboarding.** Entry: Onboarding. The employee checklist loads only tasks assigned to the signed-in employee through a session-validated portal endpoint. The screen shows total, open, completed and overdue counts, progress, mandatory badges, due dates, search and status filters, and loading, error and empty states. Selecting **Mark complete** persists `Status__c = Completed`, refreshes the checklist and updates the progress summary. Completed task records feed the admin dashboard. Employee creation, task-template assignment and recruitment handoff require configured records and automation; test those prerequisites as one sequence before claiming automatic hire-to-onboard processing.

### Performance and training

**Performance goals.** Entry: Performance. The view displays the real Goal Management component with SmartHR-style summary cards, status pills, search, responsive goal cards, target dates and progress bars. Employees create or edit goals, set a target date/status and update progress with the slider; progress changes derive Not Started, In Progress or Completed status and persist through the server API. Refresh reloads the authoritative records, while error and no-match states keep the workflow understandable. The server owns persistence and access checks. Dashboard active-goal counts can then reflect the employee's records.

**Appraisals.** Entry: Appraisals. Employees review or save their appraisal fields and ratings through the appraisal controller. The separate legacy template now preserves existing edit values and no longer pretends to delete a record only in browser memory. Reviewer completion is a process gap: the existing team-review query selects completed records, and the existing save method does not generally authorize an assigned reviewer to edit someone else's appraisal. A dedicated, permission-tested reviewer transition is still needed.

**Training.** Entry: Training. The repaired page uses real upcoming training events and the employee's registrations. Register creates a training attendance/registration record; cancel removes the user's eligible future registration through the controller. Training events/programs must exist first. The former in-memory Add Training demonstration is no longer the routed registration experience. Administrative course creation is not supplied by the registration page.

### Payroll and employee services

**Payslips.** Entry: Payroll. Employees view their own salary slips and details; users with the relevant payroll access can use the permitted employee selection. The viewer reads payroll configuration and related slip data. Sending a payslip email is an explicit separate action. The viewer does not constitute a Run Payroll engine or a verified bank-payment integration.

**Tax declarations.** Entry: Tax Declaration. The employee loads declarations, creates or edits the relevant declaration and submits it through the tax controller. Submission is distinct from tax validation and payroll application. Financial calculations and jurisdiction-specific rules require separate business validation.

**Expenses.** Entry: Expense Management. The employee creates a claim, adds line items and supporting files, and submits through the claim workflow. A reviewer opens team claims and processes eligible actions. Claim decisions and reimbursement/payment are separate steps; confirm downstream payroll/accounting integration before treating approval as payment.

**Projects.** Entry: Projects List. Users switch list/grid views, filter or sort, and open project details. Authorized managers create/edit/delete projects and upload logos after saving a project. Add Project now calls the implemented handler. CSV exports use the filtered/sorted project list. Project display and timesheet records are separate data sources.

**Policies and reports.** Entry: Policies and Reports Dashboard. Policies are retrieved for viewing/filtering. Reports aggregate the available HR data under the caller's access. Report labels, dates and denominators must match their queries. Neither a policy listing nor a dashboard automatically establishes acknowledgement or compliance completion.

**Chat and notifications.** Entry: header controls. Notifications load actual records, and supported read actions update them. Chat opens the organization's Salesforce Chatter destination, which can require Salesforce sign-in. It is not a separate custom employee messaging service.

## Recommendations

### Operational acceptance

Use dedicated test records for an employee, their manager and an administrator. For each write, save, reload, verify the persisted record, then check that another unauthorized employee cannot access or change it. Cover rejected requests, missing configuration, invalid dates and expired sessions. Exercise keyboard navigation and narrow-screen layouts as well as pointer clicks.

### Outstanding process decisions

Complete and test the appraisal reviewer workflow. Establish the intended training-administration process. Verify recruitment handoffs, leave allocation automation, payroll generation and reimbursement integration rather than assuming these are implied by existing viewers. Agree on precise attendance measures before presenting late/absent or attendance-rate analytics across reports.

A source-wide review is broader than the controls repaired in this release. Unrouted template components still exist in the repository and should not be added to live pages without an action/data audit. Their presence is not evidence of a delivered module.

## Appendix

### Dashboard definitions

Employee dashboard: upcoming shift assignments overlapping the next seven days; goals in Not Started/In Progress; draft or in-progress appraisals; assigned pending requests; current leave allocations; recent salary slips; today's recorded attendance. Empty values depend on both records and access. The recent-slip query returns up to three records, not a guaranteed three-month time window.

Admin dashboard: active employee count, leave/attendance request summaries, project count, completed onboarding tasks, top ten departments, recent projects and five recent applicants. Attendance approval categories are shown with their recorded date. The admin attendance endpoint can fall back to an earlier recorded day; the UI discloses that behavior. Refresh reloads queries; cacheable server methods can retain platform caching semantics.

Manager dashboard: personal summary plus assigned leave/attendance approval queue. It does not fabricate team headcount, leave totals or active-project metrics when a verified team-scoped query is not available.

### Sources

PWChrono source: force-app/main/default/lwc, classes and digitalExperiences/site/Pulse_Work_Chrono1. Primary controllers include PWChrono_DashboardController, PWChrono_AdminController, PWChrono_LeaveController, PWChrono_AttendanceController, PWChrono_WorkLogController, PWChrono_PerformanceController, PWChrono_TrainingController and the recruitment/payroll/expense controllers referenced by each routed component.

SmartHR visual reference: https://smarthr.dreamstechnologies.com/html/index.html, inspected during this review. The reference is a presentation template; its sample employees and metrics are not PWChrono business data.

Existing project references: docs/SMARTHR_UI_EXECUTION.md, docs/PWChrono_HRMS_Business_Process_Flow.md and docs/PWCHRONO_TECHNICAL_INVENTORY.md. Earlier documents were used for orientation; current implementation and live metadata take precedence where they differ.
