# PWChrono HRMS — Issues Tracker

> Last updated: 2026-05-25
> Legend: ✅ Fixed · 🔴 Open · 🟡 Partial

---

## P0 — Critical (Broken Functionality)

### 1. AttendanceCalendar — Missing Auth Params in Apex Call ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoAttendanceCalendar/pwchronoAttendanceCalendar.js`
**Method:** `loadCalendarData()`
**Issue:** `getAttendanceTrackerData()` was called with only `startDate` and `endDate`. The Apex method requires four parameters: `startDate`, `endDate`, `employeeId`, `sessionToken`. For portal (guest) users, the call always failed silently — the calendar never loaded attendance data.
**Fix:** Imported `getEmployeeId` and `getSessionToken` from `c/pwchronoSession`. Both are now resolved in `connectedCallback` and passed to the Apex call.

---

### 2. LeaveEmployee — Hardcoded Balance Values ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveEmployee/pwchronoLeaveEmployee.js`
**Issue:** The four leave balance metrics were hardcoded as class properties. `getMyLeaveBalance` was never called, so every employee always saw the same static numbers regardless of their actual allocation.
**Fix:** Added `loadLeaveBalance()` which calls `getMyLeaveBalance({ employeeId, sessionToken })` imperatively. Results are mapped to the metric properties by leave type name (annual/medical/other). All four properties now initialise to `0`.

---

### 3. PerformanceAppraisal — Fully Mock Data, No Apex Connection ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoPerformanceAppraisal/pwchronoPerformanceAppraisal.js`
**Issue:** The component was wired entirely to hardcoded static data. No Apex import existed. The save modal did nothing. Appraisal records were never read from or written to Salesforce.
**Fix:** Replaced mock data with `@wire(getMyAppraisals, {...})`. Records now mapped from live `PWChrono_Appraisal__c` data. Save modal calls `saveAppraisal()` with competency ratings serialised into `Achievements__c` and average rating into `Self_Rating__c`. Updated Apex SOQL to include employee relationship fields.

---

## P1 — High (Wrong Data Mapping / Silent Failures)

### 4. Dashboard — Shifts Missing `dateFormatted` and `dayOfWeek` ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoDashboard/pwchronoDashboard.js`
**Issue:** The HTML template binds `{shift.dateFormatted}` and `{shift.dayOfWeek}` but neither was computed — both rendered blank.
**Fix:** Added `dateFormatted` (UTC day number) and `dayOfWeek` (3-letter abbreviation from module-level `DAY_NAMES` constant) derived from `shift.From_Date__c`.

---

### 5. LeaveAdmin — Wrong Field Name in Date Filter ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveAdmin/pwchronoLeaveAdmin.js`
**Issue:** Date filter compared `l.Start_Date__c`. `PWChrono_Leave__c` has no `Start_Date__c` field — correct field is `From_Date__c`. Every date-filtered result set was empty.
**Fix:** Changed to `l.From_Date__c`.

---

### 6. LeaveEmployee — Wrong Field Names in Leave Record Mapping ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveEmployee/pwchronoLeaveEmployee.js`
**Issue:** Leave records mapped `record.Start_Date__c`/`record.End_Date__c`. Both date columns in the leave list always rendered blank.
**Fix:** Changed to `record.From_Date__c` and `record.To_Date__c`.

---

### 7. LeaveEmployee — "New Leave" Button is Non-Functional Placeholder ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveEmployee/pwchronoLeaveEmployee.js`
**Issue:** "New Leave" button showed a "coming soon" toast. No modal, no leave submission logic.
**Fix:** Added Bootstrap modal with Leave Type dropdown (wired to `getActiveLeaveTypes`), From/To Date, Reason, Half Day checkbox. Submit calls `saveLeaveApplication()`. On success, list and balances both refresh in parallel via `Promise.all`.

---

### 8. ProfileUpdate — Address Fields Not Populated or Saved ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoProfileUpdate/pwchronoProfileUpdate.js`
**Issue:** City, State, Country, PostalCode form controls exist but `Portal_Users__c` has none of these fields. Inputs were silently non-functional.
**Fix:** Removed orphan controls from both JS `formState` and HTML template. `Address__c` field (already correctly wired) covers address input.

---

## P2 — Medium (Design — Tailwind CSS Instead of Bootstrap/SmartHR)

> The project uses Bootstrap 5 + SmartHR theme loaded via `smarthr_assets` static resource.
> Tailwind CSS is **not** loaded anywhere in the shell. Any Tailwind class silently does nothing.

### 9. AttendanceCalendar — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoAttendanceCalendar/pwchronoAttendanceCalendar.html`
**Fix:** Rewritten with Bootstrap `card`, spinner, and utility classes. Custom calendar CSS classes (`calendar-grid`, `calendar-header`, `day-number`, etc.) preserved as-is.

---

### 10. AttendanceRequest — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoAttendanceRequest/pwchronoAttendanceRequest.html`
**Fix:** Converted to Bootstrap `card`, `row`/`col-*` grid, `btn btn-outline-secondary` pagination, Bootstrap spinner, `alert alert-danger` error block.

---

### 11. AttendanceSettings — Tailwind Layout + SLDS Modal ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoAttendanceSettings/pwchronoAttendanceSettings.html`
**Fix:** Converted Tailwind table and layout to Bootstrap `table table-hover`. Replaced SLDS modal (`dialog`/`slds-modal`) with Bootstrap modal structure (`modal fade show d-block` + `modal-backdrop`).

---

### 12. CompanyPolicies — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoCompanyPolicies/pwchronoCompanyPolicies.html`
**Fix:** Removed Tailwind from breadcrumb, card, and accordion sections. Converted to Bootstrap `card`, standard `page-breadcrumb`, Bootstrap spinner and alert.

---

### 13. ConfigurationCenter — Tailwind Layout + Tailwind Tab Classes ✅ Fixed

**Files:** `force-app/main/default/lwc/pwchronoConfigurationCenter/pwchronoConfigurationCenter.html`, `.js`
**Fix:** Converted tabs to Bootstrap `nav nav-tabs`/`nav-link active`. Replaced Tailwind grid, modals, and cards throughout with Bootstrap equivalents. `getNavTabClass()` now returns `"nav-link active"` or `"nav-link"`. Replaced custom fixed-position modal with Bootstrap `modal fade show d-block` + backdrop. Tabler icons replace `lightning-icon` in tab nav.

---

### 14. ExpenseClaimPortal — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoExpenseClaimPortal/pwchronoExpenseClaimPortal.html`
**Fix:** Converted all Tailwind classes to Bootstrap. Replaced custom fixed-position modal overlay with Bootstrap modal structure. Filter inputs use `form-control form-control-sm` and `form-label`. Expense items table uses `table table-sm`.

---

### 15. HolidayCalendar — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoHolidayCalendar/pwchronoHolidayCalendar.html`
**Fix:** Converted to Bootstrap `card`, `avatar avatar-md bg-soft-primary`, Bootstrap `badge bg-soft-info`. Inline SVG calendar icon replaced with `ti ti-calendar` Tabler icon.

---

### 16. LeaveCalendar — Tailwind Layout ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveCalendar/pwchronoLeaveCalendar.html`
**Fix:** Converted to Bootstrap `card`, spinner, `d-flex` navigation header. Custom calendar CSS classes preserved. Empty state uses `ti ti-calendar-off` icon.

---

### 17. AttendanceManagement — Lightning Layout Instead of Bootstrap ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoAttendanceManagement/pwchronoAttendanceManagement.html`
**Fix:** Removed `lightning-card`, `lightning-layout`, and `lightning-layout-item`. Replaced with Bootstrap `row g-3` / `col-12 col-lg-8` / `col-12 col-lg-4` grid. Added `lwc:render-mode="light"`.

---

## P3 — Low (Best Practice / Minor)

### 18. LeaveBalanceWidget — Non-Reactive Wire Parameters ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoLeaveBalanceWidget/pwchronoLeaveBalanceWidget.js`
**Fix:** Added `@track` to both `employeeId` and `sessionToken`.

---

### 19. RecruitmentPipeline — Non-Reactive Wire Parameters ✅ Fixed

**File:** `force-app/main/default/lwc/pwchronoRecruitmentPipeline/pwchronoRecruitmentPipeline.js`
**Fix:** Added `@track` to `portalUserId` and `sessionToken`.

---

### 20. Mixed Icon Systems Across Components ✅ Fixed

**Files:**

- `force-app/main/default/lwc/pwchronoNewManagerDashboard/pwchronoNewManagerDashboard.html` — `fa-caret-up/down` → `ti ti-caret-up/down`
- `force-app/main/default/lwc/pwchronoLeaveSettings/pwchronoLeaveSettings.html` — already pure Tabler (no changes needed)
- `force-app/main/default/lwc/pwchronoAttendanceAdmin/pwchronoAttendanceAdmin.html` — 14 FA icon types → Tabler equivalents
- `force-app/main/default/lwc/pwchronoPerformanceReview/pwchronoPerformanceReview.html` — `fa-plus` → `ti ti-plus`
- `force-app/main/default/lwc/pwchronoDashboardTasksStatistics/pwchronoDashboardTasksStatistics.html` — `fa-calendar-days` → `ti ti-calendar-event`, `fa-circle` → `ti ti-circle-filled`

---

## Summary

| Priority             | Total  | Fixed  | Open  |
| -------------------- | ------ | ------ | ----- |
| P0 — Critical        | 3      | 3      | 0     |
| P1 — High            | 5      | 5      | 0     |
| P2 — Medium (Design) | 9      | 9      | 0     |
| P3 — Low             | 3      | 3      | 0     |
| **Total**            | **20** | **20** | **0** |
