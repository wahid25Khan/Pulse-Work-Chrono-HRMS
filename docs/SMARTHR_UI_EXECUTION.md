# PWChrono SmartHR visual parity tracker

## Scope and completion gate

UI/UX implementation only. Preserve data contracts, role filtering, navigation,
and existing worktree changes. No schema, licensing, Apex, or permission changes
in this batch. Deferred Apex test-class work does not remove the need for frontend
checks. Do not label compilation or deployment as pixel-perfect verification.

Reference: https://smarthr.dreamstechnologies.com/html/candidates-grid.html

Every page needs reference and portal captures at the same browser, viewport,
zoom, scroll position, and comparable data state. Check desktop (1440 and 1280),
tablet (768), and mobile (390). Compare geometry, typography, spacing, colors,
icons, controls, overlays, and responsive behavior. Keep PWChrono branding and
real portal data; do not copy template demonstration records or add inert actions.

## Reference observations — 5 September 2026

The live reference rendered with `data-layout=modern`, `data-sidebar=darkgreen`,
`data-card=shadow`, and a white topbar. Observed desktop sidebar width: 252px;
content padding: 24px; Roboto body font. Sidebar background: #111926.
Primary orange: #f26522. Search width: 259px at the inspected desktop viewport.
The profile precedes Menu/Chats/Inbox. These observations establish the baseline;
they are not proof that PWChrono currently matches it.

## Existing implementation

- Bundled SmartHR Bootstrap, theme CSS, Tabler and Font Awesome assets.
- Shared LWC layout, header, sidebar, asset loader, and route-aware navigation.
- Employee and admin attendance screens and other HR module components.
- Existing permission filtering and backend changes remain outside this UI batch.
- Portal browser currently requires OTP verification before authenticated review.

## Batch 1 — shared shell

Implemented and deployed to the development org:

- Activated bundled modern/dark-sidebar/card-shadow variants on the portal wrapper,
  without changing Salesforce document-level theme attributes.
- Replaced custom peach header colors and shadow with neutral SmartHR styling.
- Matched sidebar profile/tab ordering and enabled flex-based navigation scrolling
  without introducing the template's jQuery scroll plugin.
- Added menu styling adapters for the flat permission-filtered LWC menu structure.
- Added scoped keyboard focus and reduced-motion safeguards.
- Corrected missing-logo fallback and supplied search/toggle accessible defaults.
- Restored the reference sidebar-toggle icon and header spacing.
- Added three header regression checks for logo states and the existing toggle event.

Validation:

- Initial Salesforce dry-run: 5/5 components, NoTestRun, succeeded.
  Job: `0Afg800000CPtC5CAL` in org `00DHr0000018UO8MAM`.
- Metadata deployment: 5/5 components succeeded, job `0Afg800000CPuL3CAL`.
- Site publication request accepted, job `08Pg800000Ki1BaEAJ`; asynchronous
  completion is not independently confirmed. Network status was Live.
- Header regression tests: 3/3 passed. Scoped ESLint, formatting, and whitespace
  checks passed. No Apex tests run because this batch changes no Apex.
- Authenticated visual, mobile, keyboard, and interaction verification: pending.
- Font loading, deployed Tabler glyph rendering, and nested page-wrapper checks:
  still require rendered verification.

## Multi-page delivery — 6 September 2026

Implemented and deployed in scoped job `0Afg800000CUUHtCAP` (six components:
four page modules, CSV utility, and shared stylesheet). Initial five-LWC dry-run
`0Afg800000CUTfBCAX` passed. No Apex, permissions, or site-page metadata included.
Publication request accepted: `08Pg800000KyM8QEAV`. Asynchronous completion and
the authenticated rendered result remain unconfirmed.

| Page/surface           | Existing                                            | Added or fixed in this batch                                                                                                                                                                                                          | Verification still needed                                                             |
| ---------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Recruitment candidates | Server-backed applicants and drag/drop board        | Responsive grid; search/status/sort/reset; load more; grid/board toggle; real record fields; CSV export; board styles                                                                                                                 | Authenticated screenshots with populated data; server-backed board moves; role checks |
| Employee directory     | List/grid/detail, server filters, pagination, forms | Replaced grid demo productivity widgets with record cards and View profile; removed hardcoded date; corrected list title; CSV; synchronized filters/search; responsive cards                                                          | Live list/grid/detail screenshots; pagination/filter and edit/save regression         |
| My Leaves              | Balances, requests, save method                     | Rebuilt summary cards, date/status/search filters, reset, badges, CSV, loading/error/empty states; removed inert edit/delete/selection controls; native validated form and keyboard handling; corrected repeated balance accumulation | Live date-bound queries, populated states, authorized request submission              |
| Job Openings           | Openings and referral method                        | Search/reset; responsive cards; error state; neutral referral modal with native controls; required validation; duplicate-submit guard; icon-click job selection and Light DOM fixes                                                   | Live data, modal screenshots, authorized referral submission                          |

Automated coverage: candidate grid/filter/reset/view/empty state, CSV escaping and
formula neutralization, job search/referral opening/required validation, leave
badge/search/required validation, and existing header regression tests. Sixteen
tests passed; no Apex test classes were changed or run.

The earlier authenticated shell review found low-contrast menu text, missing
active-tab fill, doubled LWR gutters, and mobile drawer overlay behavior. Scoped
adapters were added. Employee attendance was also updated to remove hardcoded
trend/festival/timeline demo data and show an explicit empty state. Its backend
calculations, export/report buttons, and writes still need a completion pass.

Browser verification for this batch is blocked by expired portal authentication:
the open Chrome tab shows Sign In. These pages are **deployed, not yet certified
pixel-matched or end-to-end verified**. The original shell was seen authenticated
on 5 September; that does not verify this newer batch.

Known gaps: recruitment's existing permissive client-access fallback needs a
separate RBAC audit; the retained board needs a keyboard-accessible status-change
workflow. Employee detail/modals and other recruitment subtabs were not redesigned
in this batch. Do not count these as completed.

## Remaining sequence

| Batch | Work                                                    | Acceptance                                                                                             |
| ----- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1     | Finish shared shell comparison                          | Header, expanded/collapsed sidebar, mobile drawer, content offsets, fonts verified                     |
| 2     | Attendance employee/admin and manager-visible state     | Matching cards, filters, table/timeline, modal states; existing access boundaries preserved            |
| 3     | Employee directory and recruitment                      | Compare grid/list patterns against corresponding SmartHR pages; real search/filter/pagination retained |
| 4     | Leave, approvals, overtime, WFH, timesheets             | Consistent controls, status badges, summaries, validation, modal layout                                |
| 5     | Dashboards, projects, performance, onboarding, training | Shared card/chart/list hierarchy; disclose placeholder or backend blockers                             |
| 6     | Payroll, expenses, profile, policies, settings          | Consistent forms/tables, long-content handling, access-specific views                                  |
| 7     | Cross-portal regression and handoff                     | Role-by-role route review, responsive screenshots, no dead controls, final audit and release record    |

Before each batch, inspect its actual components and the corresponding reference
page; the candidates grid is the shared design reference, not a substitute for
attendance or settings UX. Functional gaps discovered during UI work must be
recorded separately rather than concealed with static sample content.

## Finishing pass — 6 September 2026

Per the user's latest direction, finish the four in-progress pages only; do not
begin another module or project. The remaining sequence above is a backlog, not
authorization to start it during this pass.

Live review at 1514px confirmed real candidate cards and grid/board controls.
It exposed an oversized recruitment header/summary stack, smaller candidate
headings, and two rendered sets of navigation on Employee Directory. The latter
was traced to its page wrapper mounting a second main layout inside the site's
existing authenticated theme.

Implemented:

- Candidates: condensed duplicate headings, collapsible recruitment metrics,
  horizontally scrollable workflow navigation, SmartHR orange/radii, 16px card
  names, compact status badges, readable dates and long-title handling.
- Directory: removed the redundant page-level shell (the Experience theme still
  owns authentication/navigation); added persistent load failure and retry,
  unavailable metrics instead of false zeros, selected view semantics, and
  protection against stale filter responses.
- My Leaves: request failures no longer also show an empty-result table; failed
  balances show unavailable values and a retry action. Older filter responses
  cannot overwrite newer results. Preserve actual zero-day values.
- Job Openings: 24px grid gutters, 20px card padding, consistent titles and
  responsive long text; referral dialog now has an accessible title, focus
  placement, Tab containment, Escape handling and focus restoration.

Validation: 22/22 focused LWC tests across six suites; scoped ESLint and
`git diff --check` passed. Salesforce dry-run `0Afg800000CVX5fCAH` passed.
Actual deployment `0Afg800000CVy5pCAD`: 6/6 LWC bundles succeeded in verified dev
org `00DHr0000018UO8MAM`. No Apex, schema, permission or site metadata deployed.
Site publication `08Pg800000L53CcEAJ`: `BackgroundOperation.Status = Complete`.
Post-release browser checks confirmed a single directory header/sidebar and the
new directory/leave error states. At 390px, the directory error layout had no
document horizontal overflow (385px scroll width); candidate cards stacked in
one column and workflow navigation scrolled horizontally. Candidate records
remained visible, potentially from cache, so this does not prove a refreshed
server session. Responsive review also prompted warning-color contrast,
directory metric-icon sizing, and mobile refresh-button ordering corrections.
Those final CSS corrections were deployed in `0Afg800000CVhBTCA1` (3/3 bundles).
Final publication `08Pg800000L4YCiEAN` also reached `Complete`. The browser's
temporary viewport override was cleared before handing back the OTP session.

The later browser session displays a retained HR Admin identity but no menu
items and failed data requests. Do not treat that retained identity as proof of
a valid server session. Asked the user to sign in again; the tab subsequently
reached OTP verification. Full matched-viewport comparison and server-backed
interactions remain open.
The leave modal was inspected without submitting any HR record. This is not a
pixel-perfect or full RBAC sign-off.

## OTP investigation — 7 September 2026

Read-only investigation in verified org `00DHr0000018UO8MAM`:

- Deployed `PWChrono_AuthController` calls `Messaging.sendEmail` without
  `setOrgWideEmailAddressId`, and returns `Success_NoEmail` when it fails.
- Both login and resend display the misleading instruction to find the OTP in
  debug logs. The sender does not log OTP values; do not add code logging.
- The org has one existing organization-wide sender named `Default Email`;
  `IsVerified = true`, `IsAllowAllProfiles = true`, `Purpose = UserSelection`.
- Current single-email quota: 13 remaining of 15. This rules out quota exhaustion
  at inspection time, not at an earlier failure time.
- Latest available Apex logs are from 5 September, so they cannot establish the
  exact Salesforce error behind the new reported failure.
- Salesforce documents that guest Apex email must explicitly use a verified
  org-wide sender. The missing selection is a confirmed implementation gap and
  leading explanation, not yet a reproduced runtime root cause.
- No OTPs, authentication fields, email settings or permissions were changed.
  Sender integration and a fresh end-to-end send need approval/verification.

Resolution released after user approval:

- `PWChrono_AuthController.sendOTPEmail` now applies the existing shared
  organization-wide sender helper before `Messaging.sendEmail`; the helper finds
  the portal sender or the profile-wide fallback at runtime, with no hardcoded
  sender ID.
- `pwchronoLogin` no longer directs users to debug logs for an OTP. Its recovery
  text tells users to retry after the resend cooldown or contact HR support.
- Targeted Apex run `707g800000eT9mv`: 20/20 passed. Scoped validation
  `0Afg800000CXH82CAH`: 2/2 components and 19/19 deployment tests passed.
  Actual deployment `0Afg800000CXI2TCAX`: 2/2 components and 19/19 deployment
  tests passed.
- First publish `08Pg800000LJ9lvEAD` failed with Salesforce publication error
  `2000821307-661141 (-1963558448)`. One retry `08Pg800000LJOFrEAP` completed.
  The Apex change was already active independently of site publication.
- End-to-end delivery to a real recipient has intentionally not been triggered
  by automation because that would send an authentication code. Ask the user to
  request a fresh OTP in the portal and confirm arrival.

Post-OTP visual evidence from the preceding review: candidates displayed eight
records; search reduced them to one and reset/grid-board switching worked.
At 1514px, reference and portal candidate-card widths both measured 284.25px;
reference height was 194.51px versus portal 199px. Portal cards begin lower due
to the retained recruitment-workflow navigation. Six job-opening cards loaded;
the referral dialog showed its accessible title and initial focus correctly.
These observations do not complete directory/leave populated-state or full
responsive parity verification. No HR records were submitted or changed.

## Release discipline

Deploy only reviewed bundles and required static resources. Keep metadata deploy,
site publication, and authenticated visual verification as separate statuses.
Do not deploy all dirty Apex/site metadata or push Git changes as part of this UI
batch. A final pixel-parity claim requires completed screenshot comparison, not
an estimated percentage or a successful deploy command.

## Attendance completion release — 8 September 2026

The employee tracker, team/admin attendance view, and shared attendance request
modal were finalized as one scoped module release. Existing Apex-backed RBAC was
preserved: employees retain personal attendance only; managers receive their
server-authorized team scope; only attendance administrators can add or edit
records. The release adds filtered CSV export, restores the employee request
modal path, makes native time fields render persisted Salesforce time values,
and retains native validation plus duplicate-save protection.

Validation recorded before deployment: Prettier, scoped ESLint, and diff
whitespace checks passed. The repository Jest command discovered unrelated,
archived TestCafe files under `.sf/.../Sortablemaster` which lack the TestCafe
package; LWC suites that were run passed 32 tests. No Apex behavior changed and
no Apex tests are required for this UI-only release. Authenticated browser
regression remains a manual post-release step because the portal session had
returned to login at the time of release.
