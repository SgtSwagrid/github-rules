<div align="center">
  <h1>⚖️ GitHub Rules</h1>
  <p>A tool to define GitHub <a href="https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository">rulesets</a> in source. </p>
</div>

## 🚨 Problem

GitHub rulesets define how different people are allowed to interact with specific branches and tags.
An important limitation, however, is that they can only be configured in the settings tab on GitHub, and not from the repository's source code.
This can limit scalability in cases where the same settings must be manually configured across multiple projects.
It is possible to export/import rules in JSON format, but this isn't as seemless as having the rules defined directly in the repository itself.

## 💡 Solution

_GitHub Rules_ instead supports a workflow whereby _all_ rulesets are defined exclusively in source.
Every `*.json` file in `.github/rulesets` is automatically applied as a ruleset, and is kept in sync by a GitHub action watching for changes.


## 🚩 Limitations

The synchronisation is applied only in a single direction.
Direct changes to your repository's configuration on GitHub aren't reflected in `.github/rulesets`,
and in fact will promptly be automatically reverted to reflect the existing contents of `.github/rulesets` as the single source of truth.
If you wish to use GitHub's UI or API to update a ruleset, you'll need to explicitly export is as JSON when you're done and commit it to the repository.
