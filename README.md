<div align="center">
  <h1>⚖️ GitHub Rules</h1>
  <p>A tool to define GitHub <a href="https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository">rulesets</a> in-source. </p>
</div>

## 🚨 Problem

GitHub rulesets define how different people are allowed to interact with specific branches and tags.
An important limitation, however, is that they can only be configured in the settings tab on GitHub, and not from the repository's source code.
This can limit scalability in cases where the same settings must be manually configured across multiple projects.
It is possible to export/import rules in JSON format, but this isn't as seemless as having the rules defined directly in the repository itself.

## 💡 Solution

_GitHub Rules_ instead supports a workflow whereby _all_ rulesets are defined exclusively in-source.
Every `*.json` file in `.github/rulesets` is automatically applied as a ruleset, and is kept in sync by a GitHub workflow watching for changes.
The link is bidirectional; manual changes to the configuration can also be exported to this directory.

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
  workflow_dispatch:

jobs:
  sync:
    uses: SgtSwagrid/github-rules/.github/workflows/import-rulesets.yml@main
    secrets: inherit
```

```yaml
# export-rulesets.yml

name: Export Rulesets
on:
  workflow_dispatch:

jobs:
  sync:
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

## 🚩 Limitations

The synchronisation is only automatic in a single direction.
Direct changes to your repository's configuration on GitHub aren't reflected in `.github/rulesets`
until you manually run the `Export Rulesets` workflow.
This is because ruleset changes can't serve as a workflow trigger.
Pushes to the `.github/rulesets` directory on the default branch in the interim will cause any manual changes to be reverted.
