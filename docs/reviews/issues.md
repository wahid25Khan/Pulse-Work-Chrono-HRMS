# PWChrono HRMS - Issues Tracker

This document tracks identified issues, code smells, and opportunities for improvement in the PWChrono HRMS codebase. It serves as a living document to guide refactoring, testing, and architectural enhancements.

## 🔍 Duplicate or Unnecessary Code

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **Duplicate Logic in Triggers** | Multiple triggers (e.g., `PWChrono_AppraisalTrigger`, `PWChrono_LeaveTrigger`) call handler classes, but the handler logic is duplicated in similar ways across modules. | `PWChrono_AppraisalTriggerHandler.cls`, `PWChrono_LeaveTriggerHandler.cls` | Medium |
| **Redundant `isExecuting` Guard** | The `isExecuting` flag is used in `PWChrono_AppraisalTriggerHandler` but not consistently in other trigger handlers like `PWChrono_LeaveTriggerHandler`. | `PWChrono_AppraisalTriggerHandler.cls`, `PWChrono_LeaveTriggerHandler.cls` | Low |
| **Missing Error Handling** | `PWChrono_SalarySlipTriggerHandler.cls` catches exceptions but logs them without rethrowing or handling them gracefully in a production context. | `PWChrono_SalarySlipTriggerHandler.cls` | Medium |
| **Hardcoded Constants** | Several constants are hardcoded in classes like `PWChrono_SalarySlipTriggerHandler.cls` (e.g., `Currency_Code__c`). | `PWChrono_SalarySlipTriggerHandler.cls`, `PWChrono_Constants.cls` | Low |

## ⚠️ Anti-Patterns and Violations

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **SOQL in Loops** | Potential SOQL in loop in `PWChrono_LeaveTriggerHandler.cls` within `updateLeaveAllocation` method. | `PWChrono_LeaveTriggerHandler.cls` | High |
| **Governor Limit Violations** | Use of `FOR UPDATE` in `PWChrono_AppraisalTriggerHandler.cls` without checking for bulkification. | `PWChrono_AppraisalTriggerHandler.cls` | Medium |
| **Missing Sharing** | Classes like `PWChrono_Logger.cls`, `PWChrono_DebugUtil.cls`, `PWChrono_Utils.cls` use `without sharing`, which may bypass org-wide sharing rules. | `PWChrono_Logger.cls`, `PWChrono_DebugUtil.cls`, `PWChrono_Utils.cls` | Medium |
| **System.debug() in Production Code** | `PWChrono_Logger.cls` uses `System.debug` instead of a proper logging framework or custom logger. | `PWChrono_Logger.cls` | Medium |
| **Inconsistent Naming** | Some classes use `PWChrono_` prefix, others do not (e.g., `PWChrono_ChatContact`, `PWChrono_ChatMessage`). | `force-app/main/default/classes/` | Low |

## 🛡️ Security & Compliance

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **Guest Session Validation** | `PWChrono_GuestSession.cls` validates session tokens but lacks rate limiting or brute-force protection. | `PWChrono_GuestSession.cls` | Medium |
| **Potential XSS in Debug Util** | `PWChrono_DebugUtil.cls` outputs raw user data without sanitization in `testOTPSend`. | `PWChrono_DebugUtil.cls` | Medium |
| **Unsecured Debug Endpoints** | `PWChrono_DebugUtil.cls` exposes sensitive endpoints (`getTestUsers`, `testOTPSend`) without adequate authorization checks beyond `isSalesforceInternalUser()`. | `PWChrono_DebugUtil.cls` | High |

## 🧪 Test Coverage & Quality

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **Missing Unit Tests** | `PWChrono_SalarySlipTriggerHandler.cls` lacks unit tests. | `PWChrono_SalarySlipTriggerHandler.cls` | High |
| **Incomplete Test Coverage** | Many controllers lack thorough test coverage for edge cases. | `force-app/main/default/classes/` | Medium |
| **Test Data Factory** | `PWChrono_TestDataFactory.cls` is marked as `@isTest` but is used in production code. | `PWChrono_TestDataFactory.cls` | High |

## 📦 Metadata & Configuration

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **Missing Metadata Files** | Some classes like `PWChrono_ChatContact.cls` and `PWChrono_ChatMessage.cls` lack `.cls-meta.xml` files. | `force-app/main/default/classes/` | Low |
| **Inconsistent Metadata** | Metadata files for some classes do not reflect their access levels or annotations. | `force-app/main/default/classes/` | Low |

## 🔄 Refactoring Opportunities

| Issue | Description | Location | Severity |
|-------|-------------|----------|----------|
| **Centralized Logging** | Consider replacing `System.debug()` calls with a centralized logging mechanism. | `PWChrono_Logger.cls`, `PWChrono_DebugUtil.cls` | Medium |
| **Shared Constants** | Move shared constants like currency codes to a centralized `Constants` class. | `PWChrono_Constants.cls`, `PWChrono_SalarySlipTriggerHandler.cls` | Low |
| **Refactor Shared Logic** | Extract common logic like `getCurrentEmployeeId` into a utility class. | `PWChrono_Utils.cls`, `PWChrono_AccessController.cls` | Medium |

## 🤖 Agents Details (Updated 2026-02-15)

The following agent responsibilities are used to keep issue tracking actionable and consistent:

| Agent | Responsibility | Primary Outcome |
|-------|----------------|-----------------|
| **Code Review Agent** | Detects anti-patterns, security risks, architecture inconsistencies, and accessibility issues. | Prioritized, reproducible findings with clear locations. |
| **QA & Coverage Agent** | Tracks test gaps and validates critical coverage for controllers, handlers, and triggers. | Reduced regression risk in high-impact modules. |
| **Repo & Release Agent** | Maintains commit hygiene, branch sync, and GitHub push/release readiness. | Reliable source control state and clean release flow. |

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

---

> ✅ This document is updated regularly as the codebase evolves. Please review and update as needed.
