#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Exports repository settings from GitHub's internal configuration into SETTINGS_FILE.
#
# Environment variables:
#   - GH_TOKEN:      GitHub token with permission to manage repository settings.
#   - SETTINGS_FILE: Path to the file where settings JSON will be written.
# =================================================================================================


mkdir -p "$(dirname "$SETTINGS_FILE")"

gh api "repos/$GITHUB_REPOSITORY" \
  | jq '{
      allow_squash_merge,
      allow_merge_commit,
      allow_rebase_merge,
      allow_auto_merge,
      allow_forking,
      allow_update_branch,
      delete_branch_on_merge,
      web_commit_signoff_required,
      squash_merge_commit_title,
      squash_merge_commit_message,
      merge_commit_title,
      merge_commit_message
    }' \
  > "$SETTINGS_FILE"

echo "Exported repository settings."
