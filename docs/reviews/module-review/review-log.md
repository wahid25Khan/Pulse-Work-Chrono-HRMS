# PWChrono module review and release evidence

Review date: 15 September 2026. Target: PWChrono Developer Edition, org `00DHr0000018UO8MAM`. Site: Pulse Work Chrono.

## Delivered changes

- Replaced demo admin/manager dashboard content with Salesforce query results, explicit error and empty states, correct request-status labels, and responsive SmartHR-style cards and sections.
- Repaired the Guest-runtime sharing context through `PWChrono_PortalApi`: validate the session before delegated queries/writes; preserve existing feature, role, identity, ownership and transition guards. Added only API class access to the existing site guest profile; no public record sharing was introduced.
- Connected the Approvals and Configuration pages, removed the routed demo training list, and corrected the Performance route to Goals.
- Repaired Add Project, project details, filtered project CSV exports, employee email links, attendance reports, timesheet sorting, and native export/filter menus.
- Added session arguments to leave-type and training actions. Added approval confirmation, rejection comments, duplicate-submit protection, keyboard focus and Escape handling.
- Connected Configuration table sorting, restored its Administration navigation entry, corrected page-size selections, clarified missing carry-forward limits, and aligned the personal dashboard approval count with the leave/attendance queue.
- Completed the twelve-page Word module-flow guide. Rendered and inspected all twelve pages, including contents, page references, and the six module groups.

## Automated validation

| Check                   | Result                                            |
| ----------------------- | ------------------------------------------------- |
| ESLint                  | Passed                                            |
| LWC Jest                | 61 tests passed across 12 suites                  |
| Scoped Apex validation  | 99 passed, 0 failures                             |
| New portal API coverage | 202 of 251 locations covered, approximately 80.5% |
| Metadata validation     | Passed                                            |
| Git whitespace check    | Passed                                            |

The Apex run covered PortalApi, AdminController, AttendanceController, LeaveController, PerformanceController, TrainingController, AccessController, GuestSession and DashboardController tests. Negative cases cover unverified guests and employee attempts to access administrator data. Test fixtures were corrected for ambiguous Salesforce-to-employee mappings and dates that could fall entirely on a weekend. Production authorization and working-day validation were not weakened.

## Deployments and publication

| Stage                                  | Salesforce job       | Result              |
| -------------------------------------- | -------------------- | ------------------- |
| Initial UI/site validation             | `0Afg800000DUA0rCAH` | Succeeded           |
| Initial UI/site deploy                 | `0Afg800000DUBD3CAP` | Succeeded           |
| Initial publication                    | `08Pg800000Ml5KiEAJ` | Complete            |
| Portal API scoped validation           | `0Afg800000DVgLFCA1` | Succeeded, 99 tests |
| Portal API deploy                      | `0Afg800000DVc9aCAD` | Succeeded           |
| Portal API publication                 | `08Pg800000MmfR6EAJ` | Complete            |
| Configuration and UI polish validation | `0Afg800000Db4MvCAJ` | Succeeded           |
| Configuration and UI polish deploy     | `0Afg800000Db52rCAB` | Succeeded           |

Final publication `08Pg800000MwFIEEA3` reached **Complete**. After publication, Configuration appeared under Administration, the page-size selector displayed 10, and Name sorting changed from ascending to descending with the row order changing accordingly.

## Authenticated live checks

Verified through the existing signed-in HR administrator session:

- Admin dashboard: all five original access errors disappeared. Actual results displayed 15 active employees, 6 projects, 12 pending leave/attendance requests, 7 overdue leave approvals and 2 completed onboarding tasks. Departments totaled 15. The attendance section disclosed its fallback recorded date of 27 December 2025 instead of implying current punctuality.
- Onboarding checklist: completed the employee-facing flow with session-validated task retrieval, progress and summary metrics, mandatory and overdue states, search/filter controls, persisted completion, and responsive SmartHR-style cards. The page preserves explicit loading, error and no-match states; task templates and employee assignment remain the configured prerequisite for populated checklists.
- Onboarding release validation: focused Apex validation succeeded with `PWChrono_OnboardingController_Test` (3/3 tests) and no coverage warnings. Deployment job `0Afg800000DclHpCAJ` succeeded; Experience Cloud publication job `08Pg800000MyNmlEAF` was running at verification time.
- Performance goals: replaced the utility-class-heavy employee view with component-owned SmartHR-style cards and responsive layout; added working refresh/search/status filters, explicit error and empty states, corrected Lightning input value handling, immutable progress updates with rollback on API failure, and a separate saving state for the goal modal. Deployment job `0Afg800000DdHntCAF` succeeded; publication job `08Pg800000MxnowEAB` completed. Live `/performance` verified summary cards, empty state, filter controls, New goal modal and Cancel path.
- Responsive admin dashboard: inspected desktop, 768-pixel tablet and 390-pixel mobile layouts. Tablet used two columns and mobile one; tablet document width matched viewport width without horizontal overflow.
- Dashboard Review approvals navigated to the real queue; assigned leave queue loaded its empty state without errors.
- Employee and manager dashboards loaded personal empty states without fabricated records. Manager included its approval queue.
- Projects loaded six records; Add Project opened the actual form with client/date/status fields and appropriate save-first logo guidance.
- Leave Settings loaded configured types; Add Leave Type opened the editable form and was canceled without changing HR configuration.
- Training tabs loaded. Salesforce independently confirmed zero currently scheduled future training events, matching the empty upcoming list.
- Configuration Center loaded users, reporting managers and actual global settings; its tabs worked.
- Performance opened My Goals; New Goal opened its creation form.

These checks did not approve/reject live HR requests, send emails, generate payroll, or create business records. Scoped Apex tests validate the covered writes. Empty-state and administrator checks do not substitute for every role's end-to-end business acceptance.

## Remaining process gaps and acceptance scope

1. Appraisal reviewer completion needs a dedicated, permission-tested transition. The existing reviewer query selects completed records and the general save method does not authorize an arbitrary assigned reviewer to edit another employee's appraisal.
2. The Training page handles registration; an administrative program/event creation workflow is not supplied by this page.
3. Recruitment handoffs, leave allocation automation, payroll generation/payment and expense reimbursement must be accepted as separate business processes. Existing viewers do not establish that these processes are complete.
4. Unrouted template components and legacy cosmetic controls remain in the source tree. This release is not a claim that every control in every source component has been exercised. Cross-role browser testing and write-persistence acceptance remain necessary before a broader production rollout.

The module-flow guide explains what each surface currently does and which prerequisites or follow-on processes are required.
