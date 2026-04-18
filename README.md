<div align="center">
  <h1>⚖️ GitHub Rules</h1>
  <p>A tool to define GitHub <a href="https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository">rulesets</a> and <a href="https://docs.github.com/en/rest/repos/repos#update-a-repository">settings</a> in-source.</p>
</div>

## 🚨 Problem

GitHub rulesets define how different people are allowed to interact with specific branches and tags, and repository settings control features such as merge strategies, PR behaviour, and wikis.
An important limitation, however, is that they can only be configured in the settings tab on GitHub, and not from the repository's source code.
This can limit scalability in cases where the same settings must be manually configured across multiple projects.
It is possible to export/import rules in JSON format, but this isn't as seemless as having the rules defined directly in the repository itself.

## 💡 Solution

_GitHub Rules_ instead supports a workflow whereby _all_ rulesets and settings are defined exclusively in-source.
Every `*.json` file in `.github/rulesets` is automatically applied as a ruleset, and `.github/settings.json` defines repository-level settings.
Both are kept in sync by a GitHub workflow watching for changes, and the link is bidirectional; manual changes to the configuration can also be exported back to source.

## ⬇️ Installation

### 1. Add the ruleset _import_ and _export_ workflows

Create two new workflow definitions in `.github/workflows`: `import-rulesets.yml` and `export-rulesets.yml`:

```yaml
# import-rulesets.yml

name: Import Rulesets
on:
  push:
    paths:
      - .github/rulesets/**
      - .github/settings.json
  workflow_dispatch:

jobs:
  import:
    uses: SgtSwagrid/github-rules/.github/workflows/import-rulesets.yml@main
    secrets: inherit
```

```yaml
# export-rulesets.yml

name: Export Rulesets
on:
  workflow_dispatch:

jobs:
  export:
    uses: SgtSwagrid/github-rules/.github/workflows/export-rulesets.yml@main
    secrets: inherit
```

### 2. Create a Personal Access Token

In order for GitHub Actions to automatically manage rulesets and create pull requests,
you'll need a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) (PAT) with at least the following permissions in your repository:
- `Contents` with access `Read and write`.
- `Pull requests` with access `Read and write`.
- `Administration` with access `Read and write`.

You can manage your tokens [here](https://github.com/settings/personal-access-tokens).
Once created, add it as a repository secret named `GH_TOKEN` under:
> **Settings → Secrets and variables → Actions → New repository secret**

## 🔨 Usage

Rulesets can be manually created under:
> **Settings → Rules → Rulesets**

From the **Actions** tab on GitHub, you can run the `Export Rulesets` workflow to export your rulesets to `.github/rulesets` and your settings to `.github/settings.json`.
Conversely, changes to these files on the default branch are automatically imported.

### Settings

`.github/settings.json` supports the following fields (all optional):

```json
{
  "description": "My repository description.",
  "homepage": "https://example.com",
  "has_issues": true,
  "has_projects": true,
  "has_wiki": true,
  "has_discussions": false,
  "allow_squash_merge": true,
  "allow_merge_commit": true,
  "allow_rebase_merge": true,
  "allow_auto_merge": false,
  "allow_forking": false,
  "allow_update_branch": true,
  "delete_branch_on_merge": false,
  "web_commit_signoff_required": false,
  "squash_merge_commit_title": "PR_TITLE",
  "squash_merge_commit_message": "PR_BODY",
  "merge_commit_title": "PR_TITLE",
  "merge_commit_message": "PR_BODY"
}
```

### New repositories

Imports run before `GH_TOKEN` is added will fail, in which case you may need to run `Import Rulesets` manually once to load the initial state.

## 🚩 Limitations

The synchronisation is only automatic in a single direction.
Direct changes to your repository's configuration on GitHub aren't reflected in `.github/rulesets` or `.github/settings.json`
until you manually run the `Export Rulesets` workflow.
This is because configuration changes can't serve as a workflow trigger.
Pushes to these files on the default branch in the interim will cause any manual changes to be reverted.

## 👁️ See also

- See [GitHub Graph](https://github.com/SgtSwagrid/github-graph) for a similar a tool to duplicate files across multiple GitHub repositories.
- This project is configured by [GitHub Config](https://github.com/SgtSwagrid/github-config), using the above.
