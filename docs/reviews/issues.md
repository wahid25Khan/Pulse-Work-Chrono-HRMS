# PWChrono HRMS - Issues Tracker

This document tracks identified issues, code smells, and opportunities for improvement in the PWChrono HRMS codebase. It serves as a living document to guide refactoring, testing, and architectural enhancements.

## 🔍 Duplicate or Unnecessary Code

| Issue                             | Description                                                                                                                                                | Location                                                                   | Severity                  |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------- |
| **Duplicate Logic in Triggers**   | Revalidated: this is primarily a pattern-level similarity; current appraisal/leave handlers remain intentionally domain-specific and not exact duplicates. | `PWChrono_AppraisalTriggerHandler.cls`, `PWChrono_LeaveTriggerHandler.cls` | Medium (Partially Closed) |
| **Redundant `isExecuting` Guard** | Revalidated: `isExecuting` guard exists in both `PWChrono_AppraisalTriggerHandler` and `PWChrono_LeaveTriggerHandler` in current source.                   | `PWChrono_AppraisalTriggerHandler.cls`, `PWChrono_LeaveTriggerHandler.cls` | Low (Closed)              |
| **Missing Error Handling**        | Revalidated: salary-slip history failures now surface record-level errors via `addError(...)` across impacted records.                                     | `PWChrono_SalarySlipTriggerHandler.cls`                                    | Medium (Closed)           |
| **Hardcoded Constants**           | Revalidated: salary-history currency now resolves through centralized runtime constant utility (`getEffectiveCurrencyCode`).                               | `PWChrono_SalarySlipTriggerHandler.cls`, `PWChrono_Constants.cls`          | Low (Closed)              |

## ⚠️ Anti-Patterns and Violations

| Issue                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Location                               | Severity                         |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | -------------------------------- |
| **SOQL in Loops**                     | Revalidated: original leave-trigger SOQL-in-loop finding is not reproducible in current source.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `PWChrono_LeaveTriggerHandler.cls`     | High (Closed - Not Reproducible) |
| **Governor Limit Violations**         | Revalidated: appraisal `FOR UPDATE` usage was tightened to lock only active salary-assignment rows being updated.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `PWChrono_AppraisalTriggerHandler.cls` | Medium (Closed)                  |
| **Missing Sharing**                   | Revalidated: utility/debug classes use caller-context sharing (`inherited sharing`) and controller layer has been bulk-aligned from `without sharing` to `inherited sharing`. Continued into non-controller helpers by converting `PWChrono_AppraisalTriggerHandler`, `PWChrono_LeaveTriggerHandler`, `PWChrono_SalarySlipTriggerHandler`, `PWChrono_EmailHandler`, `PWChrono_Mdt_Deploy_Callback`, and `PWChrono_TestDataFactory` to `inherited sharing`. Remaining `without sharing` classes are treated as intentional exceptions pending review (guest/session/security utilities, and batch/schedulable + select guest-oriented services). | `force-app/main/default/classes/`      | Medium (Partially Closed)        |
| **System.debug() in Production Code** | Revalidated: direct production `System.debug` usage has been centralized into `PWChrono_Logger` only; non-logger classes were remediated.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | `PWChrono_Logger.cls`                  | Medium (Closed)                  |
| **Inconsistent Naming**               | Some classes use `PWChrono_` prefix, others do not (e.g., `PWChrono_ChatContact`, `PWChrono_ChatMessage`).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `force-app/main/default/classes/`      | Low                              |

## 🛡️ Security & Compliance

| Issue                           | Description                                                                                                                       | Location                                       | Severity        |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | --------------- |
| **Guest Session Validation**    | Revalidated: session-token validation now includes failed-attempt tracking and temporary lockout after repeated invalid attempts. | `PWChrono_GuestSession.cls`, `Portal_Users__c` | Medium (Closed) |
| **Potential XSS in Debug Util** | Revalidated: debug utility responses are sanitized/masked and no longer expose raw unsafe output paths.                           | `PWChrono_DebugUtil.cls`                       | Medium (Closed) |
| **Unsecured Debug Endpoints**   | Revalidated: centralized strict authorization gate now protects debug endpoints.                                                  | `PWChrono_DebugUtil.cls`                       | High (Closed)   |

## 🧪 Test Coverage & Quality

| Issue                        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Location                                                                                                                                        | Severity                         |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| **Missing Unit Tests**       | Revalidated: dedicated unit tests now exist for `PWChrono_SalarySlipTriggerHandler`, `PWChrono_AppraisalTriggerHandler`, and guest-session hardening paths; continue expanding edge-case coverage in remaining controllers.                                                                                                                                                                                                                                                                             | `PWChrono_SalarySlipTriggerHandler.cls`, `PWChrono_AppraisalTriggerHandler.cls`, `PWChrono_GuestSession.cls`, `force-app/main/default/classes/` | Medium (Partially Closed)        |
| **Incomplete Test Coverage** | Revalidated: targeted gaps were reduced with new tests (`SalarySlipTriggerHandler`, `AppraisalTriggerHandler`, `GuestSession`, `DebugUtil`, `Auth` edge paths, `NavigationController`, `ReportsDashboardController`, `ChatController`, `ApprovalController` edge paths, `AttendanceController` approval edges, `EmployeeDirectoryController` search/access paths, `ExpenseController` claim/item/ownership edges, `RoleFeatureMappingController` metadata paths); broader controller edge cases remain. | `force-app/main/default/classes/`                                                                                                               | Medium (Partially Closed)        |
| **Test Data Factory**        | Revalidated: `PWChrono_TestDataFactory` remains test-scoped and references were not found in production runtime paths.                                                                                                                                                                                                                                                                                                                                                                                  | `PWChrono_TestDataFactory.cls`                                                                                                                  | High (Closed - Not Reproducible) |

## 📦 Metadata & Configuration

| Issue                      | Description                                                                                                            | Location                          | Severity                        |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ------------------------------- |
| **Missing Metadata Files** | Revalidated: previously flagged class metadata files exist in current source.                                          | `force-app/main/default/classes/` | Low (Closed - Not Reproducible) |
| **Inconsistent Metadata**  | Revalidated: no active deployment-impacting annotation/access mismatch found in currently reviewed class metadata set. | `force-app/main/default/classes/` | Low (Partially Closed)          |

## 🔄 Refactoring Opportunities

| Issue                     | Description                                                                                                                       | Location                                                                                         | Severity                  |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------- |
| **Centralized Logging**   | Revalidated: direct `System.debug` in non-logger classes has been replaced with centralized logger usage.                         | `PWChrono_Logger.cls`, `PWChrono_DebugUtil.cls`                                                  | Medium (Closed)           |
| **Shared Constants**      | Revalidated: key hardcoded runtime values were centralized (e.g., effective currency and OTP/session controls).                   | `PWChrono_Constants.cls`, `PWChrono_SalarySlipTriggerHandler.cls`, `PWChrono_AuthController.cls` | Low (Closed)              |
| **Refactor Shared Logic** | Revalidated: `getCurrentEmployeeId` is centralized in `PWChrono_Utils`; remaining opportunities are minor call-site cleanup only. | `PWChrono_Utils.cls`, `PWChrono_AccessController.cls`                                            | Medium (Partially Closed) |

## 🤖 Agents Details (Updated 2026-02-15)

The following agent responsibilities are used to keep issue tracking actionable and consistent:

| Agent                    | Responsibility                                                                                 | Primary Outcome                                          |
| ------------------------ | ---------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| **Code Review Agent**    | Detects anti-patterns, security risks, architecture inconsistencies, and accessibility issues. | Prioritized, reproducible findings with clear locations. |
| **QA & Coverage Agent**  | Tracks test gaps and validates critical coverage for controllers, handlers, and triggers.      | Reduced regression risk in high-impact modules.          |
| **Repo & Release Agent** | Maintains commit hygiene, branch sync, and GitHub push/release readiness.                      | Reliable source control state and clean release flow.    |

### Agent Operating Rules

1. Map every issue to concrete files/classes/components.
2. Prioritize security, data-access, and accessibility blockers first.
3. Keep issue statuses updated after each audit cycle.
4. Include remediation guidance with severity and impact.

## 📌 Recommendations

1. **Implement a Centralized Logger**: Replace `System.debug()` with a robust logging framework or wrapper.
2. **Add Missing Unit Tests**: Prioritize unit tests for critical handlers like `SalarySlipTriggerHandler`.
3. **Secure Debug Utilities**: Remove or restrict access to debug utilities in production environments.
4. **Apply Consistent Sharing Rules**: Evaluate and apply `with sharing` where appropriate.
5. **Bulkify SOQL Queries**: Refactor SOQL queries in loops to improve governor limit compliance.

## ✅ Execution Status (2026-02-16)

- **Completed in current cycle**
  - Accessibility fixes implemented and validated:
    - `pwchronoTrainingList` label-control associations
    - `pwchronoDashboardTasksStatistics` label-control associations
    - `pwchronoAdminDashboardReports` table header semantics and progress role cleanup
    - `pwchronoDashboard` clickable container semantics replaced with native buttons
- **Current in progress**
  - High-severity Apex/security-performance remediation from this tracker.
  - `SOQL in loops` finding for `PWChrono_LeaveTriggerHandler.cls` re-validated against current codebase and marked **not reproducible** (no active leave trigger file and allocation logic uses aggregate SOQL outside loops).
  - `Unsecured debug endpoints` in `PWChrono_DebugUtil.cls` remediated with centralized strict authorization gate (`requireDebugAccess`) across all debug methods.
  - `Potential XSS in Debug Util` mitigated by sanitizing text outputs (`escapeHtml4`), masking emails in debug responses, and replacing raw exception messages with generic errors.
  - Added missing tests for salary slip trigger handler:
    - `force-app/main/default/classes/PWChrono_SalarySlipTriggerHandler_Test.cls`
    - Covers positive/negative history-creation paths and empty-input behavior.
  - Added dedicated appraisal trigger handler tests:
    - `force-app/main/default/classes/PWChrono_AppraisalTriggerHandler_Test.cls`
    - Covers completed-appraisal salary increment assignment creation and performance-bonus record creation.
  - `Missing Error Handling` in `PWChrono_SalarySlipTriggerHandler.cls` improved:
    - failures now mark all involved salary slip records with `addError(...)` (no single-record silent masking).
  - Missing-sharing safe remediation completed for utility/debug classes by replacing unconditional bypass with caller-context sharing:
    - `PWChrono_Utils` → `inherited sharing`
    - `PWChrono_Logger` → `inherited sharing`
    - `PWChrono_DebugUtil` → `inherited sharing`
  - Centralized logger hardening completed in `PWChrono_Logger`:
    - gated logging via custom permission `PWChrono_Enable_Logs`
    - normalized/truncated log payloads
    - safer exception logging without raw stack-trace output
  - Hardcoded currency usage reduced in salary-history flow:
    - `PWChrono_Constants.getEffectiveCurrencyCode()` added
    - `PWChrono_SalarySlipTriggerHandler` now uses runtime effective currency code
  - Guest-session brute-force mitigation strengthened in OTP auth flow:
    - added explicit resend cooldown constant (`OTP_RESEND_COOLDOWN_MINUTES`)
    - invalid OTP attempts now invalidate issued OTP and require a fresh request
    - replaced raw auth debug traces with centralized logger calls
  - Guest session token validation hardened with persistent lockout controls:
    - added `Session_Failed_Attempts__c` and `Session_Locked_Until__c` on `Portal_Users__c`
    - `PWChrono_GuestSession` now increments failed attempts and enforces timed lockout after threshold
    - successful OTP/session issuance now resets failed-attempt state
  - Added dedicated guest session tests:
    - `force-app/main/default/classes/PWChrono_GuestSession_Test.cls`
    - Covers non-guest portal-id passthrough, lockout threshold behavior, and lockout-state reset.
  - Hardened non-guest portal-id handling in guest session helper:
    - `PWChrono_GuestSession.requireVerifiedPortalUserId` now returns controlled `AuraHandledException` for invalid non-guest `portalUserId` input.
    - Added invalid-id path test in `PWChrono_GuestSession_Test`.
  - Tightened guest lockout threshold assertions:
    - `PWChrono_GuestSession_Test` now verifies `Session_Failed_Attempts__c` is reset when lockout is applied.
  - Added dedicated debug utility coverage:
    - `force-app/main/default/classes/PWChrono_DebugUtil_Test.cls`
    - Covers `getDebugInfo` execution and controlled-failure paths for `testOTPSend` / `testFeatureAssignment`.
    - Also covers `getTestUsers` execution with sanitized payload key assertions.
  - Added dedicated navigation controller coverage:
    - `force-app/main/default/classes/PWChrono_NavigationController_Test.cls`
    - Covers safe return behavior for blank/custom menu names in no-network test context.
  - Added dedicated reports dashboard controller coverage:
    - `force-app/main/default/classes/PWChrono_ReportsDashboardController_Test.cls`
    - Covers dashboard summary and individual metric endpoints in default no-data execution paths.
  - Added dedicated chat controller coverage:
    - `force-app/main/default/classes/PWChrono_ChatController_Test.cls`
    - Covers wrapper execution paths for `getContacts`, `getMessages`, and `sendMessage`.
  - Expanded approval controller edge-case coverage:
    - `force-app/main/default/classes/PWChrono_ApprovalController_Test.cls`
    - Covers controlled invalid-workitem handling and safe no-pending-approvals list-return behavior.
  - Expanded attendance controller approval edge-case coverage:
    - `force-app/main/default/classes/PWChrono_AttendanceController_Test.cls`
    - Covers reject-action status transition and invalid-request-id controlled error behavior.
  - Added dedicated employee directory coverage:
    - `force-app/main/default/classes/PWChrono_EmployeeDirectoryController_Test.cls`
    - Covers blank/prefix search behavior and record-access true/false paths.
  - Expanded expense controller edge-case coverage:
    - `force-app/main/default/classes/PWChrono_ExpenseController_Test.cls`
    - Covers explicit employee-id claim retrieval, unknown-claim item lookup, and server-side ownership enforcement on save.
  - Added dedicated role-feature mapping controller coverage:
    - `force-app/main/default/classes/PWChrono_RoleFeatureMappingController_Test.cls`
    - Covers metadata mapping list retrieval and save/delete deployment request paths.
  - Bulk-aligned controller sharing to caller context:
    - Converted `PWChrono_*Controller` classes from `without sharing` to `inherited sharing` to respect org sharing by default.
  - Continued sharing sweep into non-controller helpers:
    - Converted `PWChrono_AppraisalTriggerHandler`, `PWChrono_LeaveTriggerHandler`, `PWChrono_SalarySlipTriggerHandler`, `PWChrono_EmailHandler`, `PWChrono_Mdt_Deploy_Callback`, and `PWChrono_TestDataFactory` from `without sharing` to `inherited sharing`.
  - Expanded auth success-path coverage:
    - `force-app/main/default/classes/PWChrono_AuthController_Test.cls`
    - Verifies successful OTP login clears `Session_Failed_Attempts__c` and `Session_Locked_Until__c`.
    - Verifies `sendOTP` trims incoming email input before user lookup.
  - Expanded appraisal trigger edge-case coverage:
    - `force-app/main/default/classes/PWChrono_AppraisalTriggerHandler_Test.cls`
    - Verifies no salary-assignment or bonus creation when status does not transition to `Completed`.
    - Verifies no salary/bonus creation for `Completed` appraisals with zero proposed amount.
  - `FOR UPDATE` usage in appraisal processing tightened:
    - `PWChrono_AppraisalTriggerHandler` now locks only active `PWChrono_Salary_Assignment__c` rows being updated, instead of broader employee-row locking.
- **Next target order**
  1.  Continue medium-severity remediations with controller edge-case coverage gaps
  2.  Revalidate open medium findings after each implementation batch
  3.  Start next remediation pass from updated medium-priority list

## 🧾 Finding Revalidation Snapshot (2026-02-16)

| Finding                                                           | Revalidation Outcome   | Notes                                                                                                                                              |
| ----------------------------------------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Duplicate logic in triggers                                       | Partially stale        | Leave trigger metadata path is currently absent; appraisal/leave handlers remain domain-specific and not merged by design.                         |
| SOQL in loops (`PWChrono_LeaveTriggerHandler`)                    | Not reproducible       | Current code path uses aggregate query in service; no active leave trigger file in metadata folder.                                                |
| Unsecured debug endpoints (`PWChrono_DebugUtil`)                  | Resolved               | Added strict `requireDebugAccess()` and restricted endpoint behavior.                                                                              |
| Potential XSS in Debug Util                                       | Resolved               | Added output sanitization, masked emails, removed raw exception leakage.                                                                           |
| Debug utility hardened-path coverage                              | Resolved               | Added `PWChrono_DebugUtil_Test` for endpoint execution and controlled-failure behavior.                                                            |
| Missing unit tests (`PWChrono_SalarySlipTriggerHandler`)          | Resolved               | Added `PWChrono_SalarySlipTriggerHandler_Test` with key behavior coverage.                                                                         |
| Missing unit tests (`PWChrono_AppraisalTriggerHandler`)           | Resolved               | Added `PWChrono_AppraisalTriggerHandler_Test` for salary increment and bonus creation paths.                                                       |
| Appraisal trigger edge-case coverage gap                          | Resolved               | Extended `PWChrono_AppraisalTriggerHandler_Test` to verify no side effects on non-completed status transitions.                                    |
| Appraisal zero-amount completed edge case                         | Resolved               | Added coverage to ensure no financial records are created when completed appraisals have zero proposed amount.                                     |
| Missing sharing (Utils/Logger/DebugUtil)                          | Resolved (safe subset) | Moved to `inherited sharing` to avoid unconditional sharing bypass.                                                                                |
| Direct `System.debug` in production classes                       | Resolved               | Replaced with `PWChrono_Logger` in auth/chat/navigation paths.                                                                                     |
| Redundant `isExecuting` guard                                     | Not reproducible       | Guard now present in both appraisal and leave trigger handlers.                                                                                    |
| Hardcoded salary-history currency                                 | Resolved               | Introduced runtime `getEffectiveCurrencyCode()` and replaced fixed usage.                                                                          |
| Guest session validation brute-force risk                         | Resolved               | Added failed-attempt counter + lockout window in `PWChrono_GuestSession` and reset on successful auth.                                             |
| Guest session lockout coverage                                    | Resolved               | Added `PWChrono_GuestSession_Test` for lockout and reset paths.                                                                                    |
| Guest session invalid non-guest id handling                       | Resolved               | Added controlled invalid-id handling in `PWChrono_GuestSession` and test coverage in `PWChrono_GuestSession_Test`.                                 |
| Guest lockout threshold reset assertion                           | Resolved               | Added explicit test assertion that failed-attempt counter resets when lockout is enforced.                                                         |
| Auth session-reset coverage gap                                   | Resolved               | Extended `PWChrono_AuthController_Test.verifyOTPSuccess` to assert lockout-state reset on successful OTP verification.                             |
| Auth input-normalization coverage gap                             | Resolved               | Added `PWChrono_AuthController_Test.testSendOTPTrimsEmailInput` to validate trimmed-email handling.                                                |
| Navigation controller test coverage gap                           | Resolved               | Added `PWChrono_NavigationController_Test` for safe menu-loading behavior and empty-list fallback paths.                                           |
| Reports dashboard controller coverage gap                         | Resolved               | Added `PWChrono_ReportsDashboardController_Test` for summary + individual metric endpoint default paths.                                           |
| Chat controller coverage gap                                      | Resolved               | Added `PWChrono_ChatController_Test` covering wrapper paths for contacts/messages/send message behavior.                                           |
| Approval controller edge-case coverage gap                        | Resolved               | Expanded `PWChrono_ApprovalController_Test` for invalid-workitem controlled error paths and safe no-pending list behavior.                         |
| Attendance controller approval edge-case coverage gap             | Resolved               | Expanded `PWChrono_AttendanceController_Test` for reject-path status transition and invalid-request-id controlled exception behavior.              |
| Employee directory controller coverage gap                        | Resolved               | Added `PWChrono_EmployeeDirectoryController_Test` for search filters and record-access true/false behavior.                                        |
| Expense controller edge-case coverage gap                         | Resolved               | Expanded `PWChrono_ExpenseController_Test` for explicit employee-id retrieval, unknown-claim item lookup, and ownership-enforcement save path.     |
| Role-feature mapping controller coverage gap                      | Resolved               | Added `PWChrono_RoleFeatureMappingController_Test` for mappings retrieval and metadata deployment request paths (`saveMapping` / `deleteMapping`). |
| Missing metadata (`PWChrono_ChatContact`, `PWChrono_ChatMessage`) | Not reproducible       | `.cls-meta.xml` files exist in current source.                                                                                                     |
| TestDataFactory used in production                                | Not reproducible       | References found in test classes only.                                                                                                             |

---

> ✅ This document is updated regularly as the codebase evolves. Please review and update as needed.
