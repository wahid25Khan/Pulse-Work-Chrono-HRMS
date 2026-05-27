# PWChrono HRMS

Salesforce Experience Cloud HRMS portal — built with LWC, Apex, and Bootstrap 5.

## Orgs

| Alias                             | Purpose                      |
| --------------------------------- | ---------------------------- |
| `corestack@thelodestonegroup.com` | Primary / source org         |
| `demo@partners.com`               | Demo org (Pulse Work Chrono) |

## Docs

- [`docs/guest-user-permissions.md`](docs/guest-user-permissions.md) — Guest user permission setup
- [`docs/pwchrono-navigation-tab-guide.md`](docs/pwchrono-navigation-tab-guide.md) — Navigation tab structure
- [`docs/pulse-work-chrono-go-live-audit.md`](docs/pulse-work-chrono-go-live-audit.md) — Go-live audit checklist
- [`docs/PWChrono_HRMS_Business_Process_Flow.md`](docs/PWChrono_HRMS_Business_Process_Flow.md) — Data model and business process flows

## Team VS Code Setup

Recommended extensions:

- Salesforce Extension Pack (`salesforce.salesforcedx-vscode`)
- XML (`redhat.vscode-xml`)
- ESLint (`dbaeumer.vscode-eslint`)
- Prettier (`esbenp.prettier-vscode`)
- Markdown Lint (`davidanson.vscode-markdownlint`)
- Mermaid Preview (`vstirbu.vscode-mermaid-preview`)

Keep only baseline extensions enabled day-to-day. Run shared tasks via **Terminal → Run Task**:

- `Quality Gate` — JS lint, LWC tests, Prettier check, docs lint
- `Format: Prettier Write` — formats supported files
