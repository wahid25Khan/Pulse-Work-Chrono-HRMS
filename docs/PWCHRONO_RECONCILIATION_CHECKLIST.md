# Pulse Work Chrono Reconciliation Checklist

Last source review: 2026-08-30

This is the persistent reconciliation list for the Lightning apps and the
Pulse Work Chrono Experience Cloud site. Source, validation, deployment, site
publication, and browser verification are tracked as separate gates so a local
change is never mistaken for a live release.

## Current reconciliation batch

- [x] Restore feature-aware filtering in `pwchronoSidebar`.
- [x] Bind `/leaves-admin` to `pwchronoLeaveAdmin` and pass the custom portal
      session to its Apex calls.
- [x] Bind `/onboarding` to the controller-backed
      `pwchronoOnboardingChecklist`.
- [x] Bind `/payroll` to the controller-backed `pwchronoSalarySlipViewer`.
- [x] Add Expenses and Payroll to the custom portal navigation.
- [x] Bind `/reports-dashboard` to `pwchronoAdminDashboardReports`.
- [x] Secure Role Feature Mapping for custom portal sessions and bind the
      correct component to `/role-feature-mapping`.
- [x] Add Dashboard, Leaves, and Holidays visibility to
      `PWChrono_Tab_Access` so it covers every tab currently configured in
      `PWChrono_Portal`.
- [x] Complete Salesforce check-only validation for this batch (latest dry-run
      job `0Afg800000BdRjZCAV`: 14/14 components and 5/5 Apex tests passed).
- [ ] Deploy the validated batch to the intended PWChrono org.
- [ ] Publish the Pulse Work Chrono Experience Cloud site.
- [ ] Verify employee, manager, HR admin, and unauthorized-user navigation in
      an authenticated browser session.

## Portal routes still needing component bindings

- [ ] Bind `/admin-settings` to the approved admin settings parent.
- [ ] Bind `/configuration` to `pwchronoConfigurationCenter` or another
      approved functional parent; do not bind the placeholder
      `pwchronoConfiguration`.
- [ ] Decide whether `/home-dashboard` is required or remove the duplicate
      empty route in favor of the existing Home dashboard.
- [ ] Bind `/job-openings` to `pwchronoJobOpeningsViewer`.
- [ ] Bind or remove the duplicate `/leaves-employees` route.
- [ ] Bind `/new-user-form` to `pwchronoNewUserForm`.
- [ ] Bind `/offer-letter` to `pwchronoOfferLetterGenerator`.
- [ ] Bind `/policies` to `pwchronoCompanyPolicies`.
- [ ] Bind `/shift-roster` to `pwchronoShiftRosterView`.
- [ ] Bind `/tax-declaration` to `pwchronoTaxDeclarationForm`.
- [ ] Remove the duplicate `pwchronoMainLayout` instance from the Interview
      Scheduler view after checking the active theme layout in Experience
      Builder.

## Modules still in active development

### Attendance

- [ ] Replace Overtime sample records and hardcoded statistics with an Apex
      contract and persisted records.
- [ ] Replace WFH sample/local-only requests with an Apex contract and
      persisted records.
- [ ] Connect Timesheets to a real parent/Apex data source.
- [ ] Implement Timesheet create, edit, delete, PDF, and Excel actions.
- [ ] Replace placeholder break/overtime calculations in Attendance Admin and
      Attendance Tracker.

### Training

- [ ] Replace mock records in `trainingList` with
      `PWChrono_TrainingController` data.
- [ ] Replace the placeholder `pwchronoTrainingManagement` surface.
- [ ] Decide whether the portal landing component is Training Catalog,
      Training Registration, or a role-aware parent containing both.

### Administration and approvals

- [ ] Design a custom-portal approval contract. The current
      `PWChrono_ApprovalController` rejects Guest execution and resolves
      Salesforce approval work by `UserInfo.getUserId()`, which does not
      represent the OTP portal user.
- [ ] Only after that contract is implemented, bind `/approvals` to
      `pwchronoManagerApprovalDashboard` and add it to the Administration
      submenu.
- [ ] Replace the placeholder `pwchronoReportsDashboard` component or retire it
      in favor of `pwchronoAdminDashboardReports`.
- [ ] Decide whether Admin Settings, Configuration, Reports, and Role Feature
      Mapping should remain separate submenu destinations or be composed in
      one Administration workspace.

### Performance and projects

- [ ] Replace mock data in `pwchronoPerformanceManagement`.
- [ ] Decide how Goals should be reached in the portal and whether it remains a
      separate Lightning app tab.
- [ ] Add a deliberate Projects feature to the feature-access contract; until
      then the sidebar treats Dashboard access as sufficient for Projects.
- [ ] Create a `pwchronoProjectsGrid` custom Lightning tab only if Projects
      should be a component workspace rather than the existing object tab.
- [ ] Implement Projects PDF export or remove the unavailable action.

## Parent destinations awaiting navigation decisions

- [ ] Role-based dashboard parent (`pwchronoRoleDashboardPage`).
- [ ] HR Dashboard and Project Manager Dashboard.
- [ ] Help Desk Dashboard.
- [ ] Recruitment Dashboard and Career Portal.
- [ ] Staffing Plan and Job Requisition standalone pages.
- [ ] Employee Promotion, Transfer, Separation, Exit Interview, and Full &
      Final Settlement pages.

These should normally be submenus or deep links, not additional top-level
business modules.

## Lightning app and permissions cleanup

- [ ] Confirm that `PWChrono_Portal` is the employee-facing module app and that
      `Pulse_Work_Chrono` remains the object-administration app.
- [ ] Decide whether Manager Dashboard, Attendance Admin, and Goals belong as
      flat Lightning app tabs.
- [ ] Keep Admin Dashboard Design hidden or development-only.
- [ ] Review permission entries for Bonus, Goals, Manager Dashboard, and System
      Admin that are visible in `PWChrono_Tab_Access` but absent from
      `PWChrono_Portal`.
- [ ] Remove test classes from production-facing Apex class access in
      `PWChrono_Tab_Access` unless there is a documented deployment need.

## Quality and release gates

- [x] Add LWC Jest coverage for sidebar feature filtering.
- [ ] Add LWC Jest coverage for each reconciled parent component.
- [ ] Expand Jest coverage beyond the current Training List and navigation
      access suites.
- [ ] Establish a focused Prettier baseline; the repository-wide formatting
      check currently includes thousands of retrieved org files.
- [ ] Refresh `docs/pulse-work-chrono-go-live-audit.md`; its site bundle and
      permission-set inventory is stale.
- [ ] Run relevant Apex tests for every controller changed by a batch.
- [ ] Run a check-only Salesforce deployment before every real deployment.
- [ ] Publish the site after Experience metadata deployment.
- [ ] Record authenticated browser evidence separately from deployment and
      publication evidence.
