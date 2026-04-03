## Exported GitHub rulesets to `$RULESETS_DIR`.

The rulesets associated with this repository were manually updated.
As a result, the versions in `$RULESETS_DIR` have become out-of-sync.
[github-rules](https://github.com/SgtSwagrid/github-rules) has exported the changes to `$RULESETS_DIR`, so that the in-source versions can remain the single source-of-truth.

### Trigger

This pull request was triggered manually, through the [Export Rulesets](https://github.com/SgtSwagrid/github-rules/.github/workflows/export-rulesets.yml) workflow.
It is advised that this _always_ be done following any manual ruleset change.

### Warning

This change is potentially destructive, as rulesets which aren't loaded by GitHub will be deleted.
Please review carefully.
