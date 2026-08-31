# PWChrono HRMS Navigation Tab Guide

This guide recommends which PWChrono components should be used as **main parent tabs** and which should be placed under **sub-tabs**, with **functional modules kept as the main tabs**.

It is based on the current metadata and navigation setup in:

- `force-app/main/default/applications/PWChrono_Portal.app-meta.xml`
- `force-app/main/default/navigationMenus/SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`
- `force-app/main/default/tabs/PWChrono_*.tab-meta.xml`
- the page wrapper LWCs in `force-app/main/default/lwc/*Page/`

---

## Important first note

There are **two different navigation models** in this project:

### 1. Lightning App navigation

This is controlled by `PWChrono_Portal.app-meta.xml`.

- It supports **top-level tabs**.
- It does **not** give you a true parent/sub-tab dropdown experience in the standard Lightning app navbar.
- So for the Lightning app, keep **modules as main tabs**.

### 2. Experience Cloud / Portal navigation

This is controlled by `SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`.

- It **does support parent items with submenus**.
- So if you want **parent tab + sub-tab navigation**, this is the right place to implement it.

**Recommendation:**

- Use the **Lightning App** for top-level module access.
- Use the **Portal Navigation Menu** for module parent tabs and their sub-tabs.

---

## Recommended parent tabs and sub-tabs

## 1. Dashboard

**Use as parent tab:** `Dashboard`

**Recommended sub-tabs:**

| Sub-tab                      | Primary component                                            | Notes                                      |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------ |
| Employee Dashboard           | `pwchronoDashboard` or `pwchronoDashboardPage`               | Standard employee landing view             |
| Manager Dashboard            | `pwchronoManagerDashboard` or `pwchronoManagerDashboardPage` | Manager-specific summary                   |
| Admin Dashboard              | `pwchronoAdminDashboard`                                     | Admin/operations overview                  |
| Role Dashboard (optional)    | `pwchronoRoleDashboardPage`                                  | Use only if you want auto-routing by role  |
| Reports Dashboard (optional) | `pwchronoReportsDashboard` / `pwchronoReportsDashboardPage`  | Better under Admin if access is restricted |

**Why:** dashboard is a cross-module entry point, so it works best as one parent with role-based children.

---

## 2. Attendance Management

**Use as parent tab:** `Attendance`

**Main tab anchor component:** `pwchronoAttendanceTracker`

**Recommended sub-tabs:**

| Sub-tab               | Primary component                                                   | Notes                                                 |
| --------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| My Attendance         | `pwchronoAttendanceTracker`                                         | Employee attendance view                              |
| Attendance Admin      | `pwchronoAttendanceAdmin`                                           | Admin/manager attendance control                      |
| Attendance Management | `pwchronoAttendanceManagement` / `pwchronoAttendanceManagementPage` | Full attendance workspace                             |
| Attendance Requests   | `pwchronoAttendanceRequest`                                         | Request intake                                        |
| Request Details       | `pwchronoAttendanceRequestDetail`                                   | Detail page; usually linked, not always shown in menu |
| Overtime              | `pwchronoOvertime`                                                  | Good standalone sub-tab                               |
| Work From Home        | `pwchronoWorkFromHomeManagement`                                    | Good standalone sub-tab                               |
| Timesheets            | `pwchronoTimesheets`                                                | Good standalone sub-tab                               |
| Shift Roster          | `pwchronoShiftRosterView`                                           | Optional admin sub-tab                                |
| Attendance Calendar   | `pwchronoAttendanceCalendar`                                        | Optional if you want calendar view                    |
| Attendance Settings   | `pwchronoAttendanceSettings`                                        | Admin-only                                            |

---

## 3. Leave Management

**Use as parent tab:** `Leave Management`

**Main tab anchor component:** `pwchronoLeaveManagement`

**Recommended sub-tabs:**

| Sub-tab              | Primary component                                    | Notes                                                           |
| -------------------- | ---------------------------------------------------- | --------------------------------------------------------------- |
| Apply Leave          | `pwchronoLeaveApplication`                           | Employee action page                                            |
| My Leaves            | `pwchronoLeaveManagement` or `pwchronoLeaveEmployee` | Employee self-service                                           |
| Leave Admin          | `pwchronoLeaveAdmin`                                 | Admin/manager leave processing                                  |
| Leave Calendar       | `pwchronoLeaveCalendar`                              | Calendar view                                                   |
| Leave Request Detail | `pwchronoLeaveRequestDetail`                         | Detail page; can stay hidden from top menu                      |
| Leave Balance        | `pwchronoLeaveBalanceWidget`                         | Usually embed inside Leave pages, not always a separate sub-tab |
| Leave Settings       | `pwchronoLeaveSettings`                              | Admin-only                                                      |

---

## 4. Holidays

**Use as parent tab:** `Holidays`

**Recommended sub-tabs:**

| Sub-tab          | Primary component                           | Notes                                          |
| ---------------- | ------------------------------------------- | ---------------------------------------------- |
| Holiday List     | `pwchronoHolidays` / `pwchronoHolidaysPage` | Main holiday page                              |
| Holiday Calendar | `pwchronoHolidayCalendar`                   | Optional if you want a calendar-specific child |

**Recommendation:** keep this as its own module only if employees access it frequently. Otherwise it can sit under Leave Management.

---

## 5. Employee Directory

**Use as parent tab:** `Employee Directory`

**Main tab anchor component:** `pwchronoEmployeeDirectory`

**Recommended sub-tabs:**

| Sub-tab                  | Primary component                                             | Notes                                                       |
| ------------------------ | ------------------------------------------------------------- | ----------------------------------------------------------- |
| Directory                | `pwchronoEmployeeDirectory` / `pwchronoEmployeeDirectoryPage` | Main searchable directory                                   |
| New User Form (optional) | `pwchronoNewUserForm`                                         | Move here only if HR owns user onboarding through directory |

**Recommendation:** keep this simple; usually one sub-tab is enough.

---

## 6. Recruitment

**Use as parent tab:** `Recruitment`

**Main tab anchor component:** `pwchronoRecruitmentPipeline`

**Recommended sub-tabs:**

| Sub-tab                | Primary component                                 | Notes                        |
| ---------------------- | ------------------------------------------------- | ---------------------------- |
| Recruitment Dashboard  | `pwchronoRecruitment` / `pwchronoRecruitmentPage` | Good high-level landing page |
| Candidate Pipeline     | `pwchronoRecruitmentPipeline`                     | Core recruitment view        |
| Job Openings           | `pwchronoJobOpeningsViewer`                       | Public/internal openings     |
| Interview Scheduler    | `pwchronoInterviewScheduler`                      | Hiring operations            |
| Offer Letter Generator | `pwchronoOfferLetterGenerator`                    | HR action tool               |

---

## 7. Onboarding

**Use as parent tab:** `Onboarding`

**Main tab anchor component:** `pwchronoOnboardingChecklist`

**Recommended sub-tabs:**

| Sub-tab              | Primary component                                         | Notes                       |
| -------------------- | --------------------------------------------------------- | --------------------------- |
| Onboarding Home      | `pwchronoOnboarding` / `pwchronoOnboardingPage`           | Main landing page           |
| Onboarding Checklist | `pwchronoOnboardingChecklist`                             | Core task tracker           |
| Company Policies     | `pwchronoCompanyPolicies` / `pwchronoCompanyPoliciesPage` | Good fit here for new hires |

---

## 8. Performance

**Use as parent tab:** `Performance`

**Main tab anchor component:** `pwchronoAppraisalForm`

**Recommended sub-tabs:**

| Sub-tab                | Primary component                                                     | Notes                         |
| ---------------------- | --------------------------------------------------------------------- | ----------------------------- |
| Appraisals             | `pwchronoAppraisalForm`                                               | Current tab-backed component  |
| Performance Management | `pwchronoPerformanceManagement` / `pwchronoPerformanceManagementPage` | Broader performance workspace |
| Performance Reviews    | `pwchronoPerformanceReview`                                           | Review-specific flow          |
| Goals                  | `pwchronoGoalManagement`                                              | Best grouped here             |

---

## 9. Training

**Use as parent tab:** `Training`

**Main tab anchor component:** `pwchronoTrainingRegistration`

**Recommended sub-tabs:**

| Sub-tab               | Primary component                                               | Notes                  |
| --------------------- | --------------------------------------------------------------- | ---------------------- |
| Training Catalog      | `pwchronoTrainingList`                                          | Best first page        |
| Training Registration | `pwchronoTrainingRegistration`                                  | Main action page       |
| Training Management   | `pwchronoTrainingManagement` / `pwchronoTrainingManagementPage` | Admin/coordinator area |

---

## 10. Expenses

**Use as parent tab:** `Expenses`

**Main tab anchor component:** `pwchronoExpenseClaimPortal`

**Recommended sub-tabs:**

| Sub-tab            | Primary component                                             | Notes                                    |
| ------------------ | ------------------------------------------------------------- | ---------------------------------------- |
| My Expense Claims  | `pwchronoExpenseClaimList`                                    | Best employee landing page               |
| New Expense Claim  | `pwchronoExpenseClaimForm`                                    | Create action                            |
| Expense Details    | `pwchronoExpenseClaimDetail`                                  | Detail page; can be hidden from top menu |
| Expense Management | `pwchronoExpenseManagement` / `pwchronoExpenseManagementPage` | Admin or power-user view                 |
| Expense Dashboard  | `pwchronoExpenseDashboard`                                    | Reporting/summary                        |
| Expense Admin      | `pwchronoExpenseClaimAdmin`                                   | Admin-only                               |

---

## 11. Payroll

**Use as parent tab:** `Payroll`

**Main tab anchor component:** `pwchronoSalarySlipViewer`

**Recommended sub-tabs:**

| Sub-tab           | Primary component                         | Notes                     |
| ----------------- | ----------------------------------------- | ------------------------- |
| Salary Slips      | `pwchronoSalarySlipViewer`                | Core payroll self-service |
| Payroll Workspace | `pwchronoPayroll` / `pwchronoPayrollPage` | Broader payroll view      |
| Payroll Dashboard | `pwchronoPayrollDashboard`                | Management/reporting      |
| Tax Declaration   | `pwchronoTaxDeclarationForm`              | Good payroll child        |

---

## 12. My Profile

**Use as parent tab:** `My Profile`

**Main tab anchor component:** `pwchronoProfileUpdate`

**Recommended sub-tabs:**

| Sub-tab                            | Primary component                                                           | Notes                              |
| ---------------------------------- | --------------------------------------------------------------------------- | ---------------------------------- |
| Profile Overview                   | `pwchronoProfileCard`                                                       | Optional summary sub-tab           |
| Update Profile                     | `pwchronoProfileUpdate` / `pwchronoProfileUpdatePage`                       | Main profile page                  |
| Salesforce Profile Sync (optional) | `pwchronoProfileUpdateSalesforce` / `pwchronoProfileUpdateSalesforceAction` | Keep only if required              |
| Permissions (admin-only)           | `pwchronoProfilePermissions`                                                | Usually not a general employee tab |

---

## 13. Administration

**Use as parent tab:** `Administration`

**Why:** instead of exposing separate top-level tabs for `Configuration`, `System Admin`, and design/admin variants, combine them into one admin module.

**Recommended sub-tabs:**

| Sub-tab              | Primary component                                           | Notes                                                      |
| -------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| Admin Dashboard      | `pwchronoAdminDashboard`                                    | Main admin landing page                                    |
| Configuration Center | `pwchronoConfigurationCenter`                               | Assigns Portal User Profiles; current config tab component |
| Configuration        | `pwchronoConfiguration` / `pwchronoConfigurationPage`       | Operational setup page                                     |
| Admin Settings       | `pwchronoAdminSettings` / `pwchronoAdminSettingsPanel`      | Settings area                                              |
| Role Feature Mapping | `pwchronoRoleFeatureMapping`                                | Admin-only                                                 |
| Reports Dashboard    | `pwchronoReportsDashboard` / `pwchronoReportsDashboardPage` | Good admin child                                           |
| New User Form        | `pwchronoNewUserForm`                                       | Creates a Portal User with a required Portal User Profile  |
| Debug Panel          | `pwchronoDebugPanel`                                        | Do not expose in production navigation unless required     |
| Design Preview       | `pwchronoAdminDashboardDesign`                              | Keep hidden or dev-only                                    |

---

## Components that should NOT become parent tabs

These are shared, layout, or embedded components and should not be exposed as main navigation tabs:

- `pwchronoHeader`
- `pwchronoSidebar`
- `pwchronoMainLayout`
- `pwchronoPageShell`
- `pwchronoRouter`
- `pwchronoAvatar`
- `pwchronoNotificationBell`
- `pwchronoWelcomeBanner`
- `pwchronoRequestActionBar`
- `pwchronoRequestComments`
- `pwchronoRequestHeader`
- `pwchronoRequestStatusBadge`
- `pwchronoFileUploadPanel`
- `pwchronoBootstrapCompat`
- `pwchronoUiAssets`
- `pwchronoConstants`
- `pwchronoErrorHandler`
- `pwchronoMiniStatCard`
- `pwchronoStatCard`
- `pwchronoStyledCard`
- `pwchronoPlaceholderCard`
- dashboard section components such as `pwchronoDashboardCounters`, `pwchronoDashboardBirthdays`, `pwchronoDashboardTasksStatistics`, etc.

These are building blocks, not navigation destinations.

---

## Recommended final navigation structure

```text
Dashboard
├── Employee Dashboard
├── Manager Dashboard
├── Admin Dashboard
└── Reports Dashboard (optional)

Attendance
├── My Attendance
├── Attendance Admin
├── Attendance Management
├── Attendance Requests
├── Overtime
├── Work From Home
├── Timesheets
├── Shift Roster
└── Attendance Settings

Leave Management
├── Apply Leave
├── My Leaves
├── Leave Admin
├── Leave Calendar
└── Leave Settings

Holidays
├── Holiday List
└── Holiday Calendar

Employee Directory
└── Directory

Recruitment
├── Recruitment Dashboard
├── Candidate Pipeline
├── Job Openings
├── Interview Scheduler
└── Offer Letter Generator

Onboarding
├── Onboarding Home
├── Onboarding Checklist
└── Company Policies

Performance
├── Appraisals
├── Performance Management
├── Performance Reviews
└── Goals

Training
├── Training Catalog
├── Training Registration
└── Training Management

Expenses
├── My Expense Claims
├── New Expense Claim
├── Expense Management
├── Expense Dashboard
└── Expense Admin

Payroll
├── Salary Slips
├── Payroll Workspace
├── Payroll Dashboard
└── Tax Declaration

My Profile
├── Profile Overview
└── Update Profile

Administration
├── Admin Dashboard
├── Configuration Center
├── Configuration
├── Admin Settings
├── Role Feature Mapping
├── Reports Dashboard
└── New User Form
```

---

## Complete implementation steps

## A. Decide where to configure the hierarchy

### If you want real parent/sub-tab behavior

Use the **Experience Cloud navigation menu**:

- File: `force-app/main/default/navigationMenus/SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`
- Parent items should use: `<type>MenuLabel</type>`
- Child items should go inside: `<subMenu>`

### If you want simple top navigation in the Lightning app

Use the **custom app**:

- File: `force-app/main/default/applications/PWChrono_Portal.app-meta.xml`
- Keep only the **main modules** as app tabs
- Do not try to force dropdown sub-tabs here, because standard app tabs are flat

---

## B. Set the main module tabs in the Lightning app

1. Open `PWChrono_Portal.app-meta.xml`.
2. Keep the app navigation focused on module-level tabs only.
3. Recommended top-level tabs to keep in the app:
   - Dashboard
   - Attendance
   - Leaves
   - Holidays
   - Employee Directory
   - Recruitment
   - Onboarding
   - Performance
   - Training
   - Expenses
   - Payroll
   - My Profile
   - Administration
4. If needed, replace scattered admin tabs with one admin-facing entry model.
5. Save and deploy the app metadata.

**Important:** if you keep `Configuration`, `System Admin`, and `Admin Dashboard` as separate top-level app tabs, the app will feel crowded.

---

## C. Build the parent/sub-tab menu in the portal

1. Open `SFDC_Default_Navigation_Pulse_Work_Chrono.navigationMenu-meta.xml`.
2. For each module, create a parent menu item with:
   - module label as the parent name
   - `<type>MenuLabel</type>`
3. Add child items inside `<subMenu>`.
4. Point each child item to the correct route, page, or page wrapper component.
5. Keep child ordering business-friendly: employee actions first, admin/settings last.
6. Save and deploy the navigation menu metadata.

---

## D. Use page wrappers for sub-tab destinations

For portal navigation, prefer using the existing page wrapper components when available, because they already include shared layout.

### Examples

| Recommended route target | Preferred wrapper component        |
| ------------------------ | ---------------------------------- |
| Dashboard page           | `pwchronoDashboardPage`            |
| Manager dashboard page   | `pwchronoManagerDashboardPage`     |
| Attendance page          | `pwchronoAttendanceManagementPage` |
| Employee directory page  | `pwchronoEmployeeDirectoryPage`    |
| Expense page             | `pwchronoExpenseManagementPage`    |
| Recruitment page         | `pwchronoRecruitmentPage`          |
| Onboarding page          | `pwchronoOnboardingPage`           |
| Training page            | `pwchronoTrainingManagementPage`   |
| Payroll page             | `pwchronoPayrollPage`              |
| Reports page             | `pwchronoReportsDashboardPage`     |
| Profile page             | `pwchronoProfileUpdatePage`        |
| Configuration page       | `pwchronoConfigurationPage`        |
| Holidays page            | `pwchronoHolidaysPage`             |
| Company policies page    | `pwchronoCompanyPoliciesPage`      |

If no wrapper exists for a destination, you can route directly to the underlying functional component page.

---

## E. Recommended sequencing for implementation

1. **Clean the top-level app tabs first**
   - keep only module-level tabs in the app
2. **Set up portal parent tabs**
   - Dashboard
   - Attendance
   - Leave Management
   - Holidays
   - Employee Directory
   - Recruitment
   - Onboarding
   - Performance
   - Training
   - Expenses
   - Payroll
   - My Profile
   - Administration
3. **Add sub-tabs under each parent**
4. **Test visibility by role**
   - employee
   - manager
   - admin/HR
5. **Hide admin-only items from general users**
6. **Keep utility components off the navigation**

---

## F. Role-based visibility recommendation

### Employee users should mainly see

- Dashboard > Employee Dashboard
- Attendance > My Attendance, Overtime, Timesheets
- Leave Management > Apply Leave, My Leaves
- Holidays
- Employee Directory
- Training
- Expenses
- Payroll > Salary Slips, Tax Declaration
- My Profile

### Manager users should additionally see

- Dashboard > Manager Dashboard
- Attendance > Attendance Admin
- Leave Management > Leave Admin
- Recruitment > Candidate Pipeline, Interview Scheduler
- Performance > Appraisals, Reviews, Goals

### Admin / HR users should additionally see

- Dashboard > Admin Dashboard
- Attendance Settings
- Leave Settings
- Expense Admin
- Payroll Dashboard
- Administration module

---

## G. Best-practice recommendation

Use this rule when deciding what becomes a parent tab:

- **Parent tab = business module**
- **Sub-tab = user task or page inside that module**
- **Embedded/shared UI = never a tab**

A good quick test is:

- If the component represents a full workflow, it can be a sub-tab.
- If the component is just a card, widget, layout piece, or helper, do not make it a tab.

---

## Final recommendation

If you want the cleanest structure for PWChrono HRMS, use this model:

- **Main tabs:** module names only
- **Sub-tabs:** user-facing workflow pages inside each module
- **Portal menu:** use for the real parent/sub-tab experience
- **Lightning app tabs:** keep flat and module-based

That will give you the cleanest navigation, the least duplication, and a much more understandable UX for employees, managers, and admins.
