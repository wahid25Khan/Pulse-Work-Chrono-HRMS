# PWChrono HRMS — Guest User Profile Permissions

This document covers every permission required for the Experience Cloud **Guest User profile** to run the PWChrono portal. Apply these when configuring a new site.

---

## How Guest User Permissions Work

The PWChrono portal uses a custom OTP-based auth layer (`Portal_Users__c` + session tokens). From Salesforce's perspective, **every API call — including post-login — runs as the site Guest User**. This means the Guest User must have access to all objects and Apex classes the app uses.

**Two places to configure:**

| What                  | Where                                                                                             |
| --------------------- | ------------------------------------------------------------------------------------------------- |
| Apex Class Access     | Guest User Profile directly (Setup → Sites → [Site] → Guest User Profile → Apex Class Access)     |
| Object / Field Access | Assign `PWChrono_Guest_Access` permission set to the Guest User, or set on the Guest User Profile |

> **Note:** Custom Metadata Types (`PWChrono_Settings__mdt`, `PWChrono_Role_Feature_Mapping__mdt`, `Predefined_Tag__mdt`) are readable by all profiles including Guest — no action required.

---

## Section A — Apex Classes (44 classes)

Add all of the following to **Guest User Profile → Apex Class Access**.

| #   | Class Name                              | Purpose                           |
| --- | --------------------------------------- | --------------------------------- |
| 1   | `PWChrono_AccessController`             | Portal access / permission checks |
| 2   | `PWChrono_AdminController`              | Admin dashboard                   |
| 3   | `PWChrono_ApprovalController`           | Leave / expense approvals         |
| 4   | `PWChrono_AttendanceController`         | Attendance tracking               |
| 5   | `PWChrono_AttendanceService`            | Attendance business logic         |
| 6   | `PWChrono_AttendanceValidator`          | Attendance validation             |
| 7   | `PWChrono_AuthController`               | OTP login / session management    |
| 8   | `PWChrono_ChatController`               | Chat / messaging                  |
| 9   | `PWChrono_ConfigurationController`      | System configuration              |
| 10  | `PWChrono_DashboardController`          | Employee dashboard                |
| 11  | `PWChrono_DebugUtil`                    | Debug panel                       |
| 12  | `PWChrono_EmployeeDirectoryController`  | Employee directory                |
| 13  | `PWChrono_ExpenseController`            | Expense claims                    |
| 14  | `PWChrono_ExpenseService`               | Expense business logic            |
| 15  | `PWChrono_ExpenseValidator`             | Expense validation                |
| 16  | `PWChrono_GuestSession`                 | Guest session token validation    |
| 17  | `PWChrono_HRDashboardController`        | HR admin dashboard                |
| 18  | `PWChrono_HelpDeskDashboardController`  | Help desk dashboard               |
| 19  | `PWChrono_HolidayController`            | Holiday calendar                  |
| 20  | `PWChrono_LeaveBalanceService`          | Leave balance calculations        |
| 21  | `PWChrono_LeaveController`              | Leave applications                |
| 22  | `PWChrono_LeaveLedgerService`           | Leave ledger / history            |
| 23  | `PWChrono_LeaveValidator`               | Leave validation                  |
| 24  | `PWChrono_NavigationController`         | Sidebar / navigation              |
| 25  | `PWChrono_NewMgrDashboardCtrl`          | Manager dashboard                 |
| 26  | `PWChrono_NotificationController`       | In-app notifications              |
| 27  | `PWChrono_OnboardingController`         | Employee onboarding               |
| 28  | `PWChrono_PMDashboardController`        | Project Manager dashboard         |
| 29  | `PWChrono_PayrollController`            | Payroll / salary slips            |
| 30  | `PWChrono_PayrollDashboardController`   | Payroll admin dashboard           |
| 31  | `PWChrono_PerformanceController`        | Performance appraisals            |
| 32  | `PWChrono_PermissionController`         | Dynamic field/object permissions  |
| 33  | `PWChrono_PolicyController`             | Company policies                  |
| 34  | `PWChrono_ProfileController`            | Employee profile management       |
| 35  | `PWChrono_ProjectController`            | Projects                          |
| 36  | `PWChrono_RecruitmentController`        | Recruitment pipeline              |
| 37  | `PWChrono_RecruitmentService`           | Recruitment business logic        |
| 38  | `PWChrono_ReportsDashboardController`   | Reports dashboard                 |
| 39  | `PWChrono_RequestAttachmentService`     | File attachments on requests      |
| 40  | `PWChrono_RequestCommentService`        | Comments on requests              |
| 41  | `PWChrono_RoleFeatureMappingController` | Role-based feature access         |
| 42  | `PWChrono_TaxController`                | Tax declarations                  |
| 43  | `PWChrono_TrainingController`           | Training programs                 |
| 44  | `PWChrono_Utils`                        | Shared utilities                  |

---

## Section B — Objects Requiring Read Access

| Object                               | Used By                              |
| ------------------------------------ | ------------------------------------ |
| `Portal_Users__c`                    | Login, session lookup, user profile  |
| `Portal_User_Profile__c`             | Permission profiles                  |
| `Portal_Object__c`                   | Dynamic object permission system     |
| `Portal_Object_Field__c`             | Dynamic field permission system      |
| `Portal_Object_Permission__c`        | Object-level permission records      |
| `Portal_Field_Permission__c`         | Field-level permission records       |
| `PWChrono_Feature_Settings__c`       | Feature module flags                 |
| `PWChrono_User_Feature_Access__c`    | Per-user feature overrides           |
| `PWChrono_Department__c`             | Employee directory, profiles         |
| `PWChrono_Designation__c`            | Employee profiles                    |
| `PWChrono_Shift_Type__c`             | Attendance / shift info              |
| `PWChrono_Shift_Assignment__c`       | Assigned shifts per employee         |
| `PWChrono_Leave_Type__c`             | Leave module                         |
| `PWChrono_Leave__c`                  | Leave applications                   |
| `PWChrono_Leave_Allocation__c`       | Leave balances                       |
| `PWChrono_Leave_Ledger__c`           | Leave history                        |
| `PWChrono_Leave_Block_Date__c`       | Leave blackout dates                 |
| `PWChrono_Leave_Period__c`           | Leave period definitions             |
| `PWChrono_Leave_Policy__c`           | Leave policy rules                   |
| `PWChrono_Attendance_Request__c`     | Attendance correction requests       |
| `PWChrono_Holiday__c`                | Individual holidays                  |
| `PWChrono_Holiday_List__c`           | Holiday list groupings               |
| `PWChrono_Expense_Claim__c`          | Expense claims                       |
| `PWChrono_Expense_Item__c`           | Line items on expense claims         |
| `PWChrono_Salary_Slip__c`            | Payroll salary slips                 |
| `PWChrono_Salary_Assignment__c`      | Salary structure assignments         |
| `PWChrono_Salary_Structure__c`       | Salary structure definitions         |
| `PWChrono_Salary_Component__c`       | Salary components (Basic, HRA, etc.) |
| `PWChrono_Structure_Component__c`    | Component-structure mappings         |
| `PWChrono_Salary_History__c`         | Salary change history                |
| `PWChrono_Bonus__c`                  | Bonus records                        |
| `PWChrono_Tax_Declaration__c`        | Tax declaration forms                |
| `PWChrono_Appraisal__c`              | Performance appraisals               |
| `PWChrono_Appraisal_Notification__c` | Appraisal notifications              |
| `PWChrono_Performance_Cycle__c`      | Performance review cycles            |
| `PWChrono_Goal__c`                   | Employee goals                       |
| `PWChrono_Training_Program__c`       | Training programs                    |
| `PWChrono_Training_Event__c`         | Training event instances             |
| `PWChrono_Training_Attendance__c`    | Training attendance records          |
| `PWChrono_Job_Opening__c`            | Job openings                         |
| `PWChrono_Job_Applicant__c`          | Job applicants                       |
| `PWChrono_Interview__c`              | Interview scheduling                 |
| `PWChrono_Offer_Letter__c`           | Offer letters                        |
| `PWChrono_Onboarding_Task__c`        | Onboarding checklists                |
| `PWChrono_Company_Policy__c`         | Company policy documents             |
| `PWChrono_Project__c`                | Projects                             |
| `PWChrono_Invoice__c`                | Invoices                             |
| `PWChrono_Request_Comment__c`        | Comments on requests                 |
| `ContentVersion`                     | File uploads / downloads             |
| `ContentDocumentLink`                | File-to-record associations          |

---

## Section C — Objects Requiring Create / Edit / Delete Access

| Object                            | Create | Edit | Delete | Reason                                 |
| --------------------------------- | :----: | :--: | :----: | -------------------------------------- |
| `Portal_Users__c`                 |        |  ✓   |        | Session token, OTP, last login updates |
| `PWChrono_Leave__c`               |   ✓    |  ✓   |        | Employees apply and edit leave         |
| `PWChrono_Leave_Allocation__c`    |   ✓    |  ✓   |        | Leave balance management               |
| `PWChrono_Attendance_Request__c`  |   ✓    |  ✓   |        | Attendance correction requests         |
| `PWChrono_Expense_Claim__c`       |   ✓    |  ✓   |   ✓    | Full expense claim lifecycle           |
| `PWChrono_Expense_Item__c`        |   ✓    |  ✓   |   ✓    | Line items on expense claims           |
| `PWChrono_Goal__c`                |   ✓    |  ✓   |   ✓    | Employee self-managed goals            |
| `PWChrono_Tax_Declaration__c`     |   ✓    |  ✓   |        | Annual tax declaration forms           |
| `PWChrono_Training_Attendance__c` |   ✓    |  ✓   |        | Training registration                  |
| `PWChrono_Request_Comment__c`     |   ✓    |  ✓   |   ✓    | Comments on any request                |
| `PWChrono_Onboarding_Task__c`     |        |  ✓   |        | Mark tasks complete                    |
| `PWChrono_Interview__c`           |   ✓    |  ✓   |        | Interview scheduling                   |
| `PWChrono_Job_Applicant__c`       |   ✓    |  ✓   |        | Job applications                       |
| `PWChrono_Offer_Letter__c`        |   ✓    |  ✓   |        | Offer letter generation                |
| `ContentVersion`                  |   ✓    |      |        | File uploads                           |
| `ContentDocumentLink`             |   ✓    |      |        | Link files to records                  |

---

## Section D — Standard Objects

| Object                | Access Needed | Reason                         |
| --------------------- | ------------- | ------------------------------ |
| `User`                | Read          | Display names, manager lookups |
| `ContentVersion`      | Read, Create  | File upload/download           |
| `ContentDocumentLink` | Read, Create  | File-to-record links           |
| `Case`                | Read, Create  | Help desk tickets              |

---

## Section E — Custom Metadata Types (No Action Required)

These are automatically readable by all profiles including Guest User — **no permission configuration needed**.

| Metadata Type                        | Purpose                           |
| ------------------------------------ | --------------------------------- |
| `PWChrono_Settings__mdt`             | Org-level configuration defaults  |
| `PWChrono_Role_Feature_Mapping__mdt` | Role-based feature access mapping |
| `Predefined_Tag__mdt`                | Pre-defined tag values            |

---

## Section F — Current State of `PWChrono_Guest_Access` Permission Set

As of the current deployment, the permission set contains:

| Item                                   | Status         |
| -------------------------------------- | -------------- |
| Apex class: `PWChrono_AdminController` | ✓ Included     |
| All other 43 Apex classes              | ✗ Missing      |
| Object permissions                     | ✗ None defined |
| Field permissions                      | ✗ None defined |

The permission set file is at:

```
force-app/main/default/permissionsets/PWChrono_Guest_Access.permissionset-meta.xml
```

---

## Section G — Site Setup Checklist

When creating the Experience Cloud site, complete these steps in order:

### 1. Create & Activate the Site

- Go to Setup → Digital Experiences → All Sites → New
- Choose the appropriate template
- Activate the site

### 2. Assign Permission Set to Guest User

- Setup → Sites → [Your Site] → Guest User Profile
- Click **Edit** → Permission Set Assignments → Add `PWChrono_Guest_Access`
- Or: Setup → Permission Sets → `PWChrono Guest Access` → Manage Assignments → Add the Guest User

### 3. Add Apex Class Access to Guest User Profile

- Setup → Sites → [Your Site] → Guest User Profile
- Scroll to **Apex Class Access** → Edit
- Add all 44 classes listed in Section A

### 4. Configure Object Permissions on Guest User Profile

- Still in Guest User Profile → **Object Settings**
- Set Read / Create / Edit / Delete per the tables in Sections B and C

### 5. Enable Field-Level Security

For each object in Section B & C, ensure all relevant fields are **Visible** and **Editable** (where write access is needed) on the Guest User Profile or the `PWChrono_Guest_Access` permission set.

### 6. Enable Content Delivery

- Guest User Profile → Check **Upload Files** and **Use Content** if available
- Or grant via the `PWChrono_Guest_Access` permission set

### 7. Configure Sharing Settings (Critical)

- Setup → Sharing Settings → set `Portal_Users__c` to **Public Read/Write** or use OWD + sharing rules
- Guest Users cannot access records they don't own unless sharing is configured
- Recommended: Create a **Guest User Sharing Rule** for all portal objects giving the Guest User read access to all records

### 8. Enable Guest User Record Creation

- For objects where Guest User needs to Create records, go to:
  Setup → Digital Experiences → [Site] → Administration → Preferences
  → Check **Allow guest users to create records**

### 9. Assign `PWChronoAUth` Permission Set to Guest User (if needed)

- This controls OTP / authentication-specific access

---

## Section H — Known Gotchas

| Issue                                                   | Fix                                                                                                 |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Guest User gets "Insufficient Privileges" on Apex calls | Apex class not added to Guest User Profile (Section A)                                              |
| Guest User can call Apex but gets no data               | Object sharing not configured — add Guest User Sharing Rules                                        |
| File uploads fail                                       | `ContentVersion` Create not granted on Guest User Profile                                           |
| OTP emails not sent                                     | `PWChrono_AuthController` not in Guest User Apex Class Access                                       |
| Session token not persisting                            | `Portal_Users__c` Edit not granted — can't write `Session_Token__c`                                 |
| Features appear disabled                                | `PWChrono_Feature_Settings__c` Read not granted                                                     |
| Empty navigation / sidebar                              | `PWChrono_NavigationController` or `PWChrono_RoleFeatureMappingController` not in Apex Class Access |
