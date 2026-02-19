# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Team VS Code Setup (PWChrono HRMS)

This repository uses a shared VS Code workspace setup for Salesforce + reporting workflows.

### Recommended baseline extensions

- Salesforce Extension Pack (`salesforce.salesforcedx-vscode`)
- XML (`redhat.vscode-xml`)
- ESLint (`dbaeumer.vscode-eslint`)
- Prettier (`esbenp.prettier-vscode`)
- Markdown Lint (`davidanson.vscode-markdownlint`)
- Mermaid Preview (`vstirbu.vscode-mermaid-preview`)

### Extension policy (aggressive minimal)

- Keep only baseline extensions enabled for day-to-day work.
- Optional power-user extensions (for example Apex log analyzers) should be installed only if your role needs them.

### Shared tasks

Use **Terminal → Run Task** in VS Code and run:

- `Quality Gate` (runs JS lint, LWC tests, Prettier check, docs lint)
- `Format: Prettier Write` (formats supported files)

### Process flow + status reporting

- Create and maintain process diagrams in `docs/reviews/system_flow.md` using Mermaid.
- Use `docs/reviews/status_report_template.md` as the standard weekly/project status format.
- Keep updates PR-friendly: small commits, clear section headings, and explicit blockers/risks.
