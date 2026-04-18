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

REPO=$(gh api "repos/$GITHUB_REPOSITORY")
PERMISSIONS=$(gh api "repos/$GITHUB_REPOSITORY/actions/permissions")
WORKFLOW=$(gh api "repos/$GITHUB_REPOSITORY/actions/permissions/workflow")

jq -n \
  --argjson r "$REPO" \
  --argjson p "$PERMISSIONS" \
  --argjson w "$WORKFLOW" \
  '{
    allow_squash_merge:              $r.allow_squash_merge,
    allow_merge_commit:              $r.allow_merge_commit,
    allow_rebase_merge:              $r.allow_rebase_merge,
    allow_auto_merge:                $r.allow_auto_merge,
    allow_update_branch:             $r.allow_update_branch,
    delete_branch_on_merge:          $r.delete_branch_on_merge,
    web_commit_signoff_required:     $r.web_commit_signoff_required,
    squash_merge_commit_title:       $r.squash_merge_commit_title,
    squash_merge_commit_message:     $r.squash_merge_commit_message,
    merge_commit_title:              $r.merge_commit_title,
    merge_commit_message:            $r.merge_commit_message,
    actions_enabled:                 $p.enabled,
    actions_allowed:                 $p.allowed_actions,
    actions_default_workflow_permissions:    $w.default_workflow_permissions,
    actions_can_approve_pull_request_reviews: $w.can_approve_pull_request_reviews
  }' \
  > "$SETTINGS_FILE"

echo "Exported repository settings."
