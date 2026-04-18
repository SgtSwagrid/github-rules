#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Imports repository settings from SETTINGS_FILE into GitHub's internal configuration.
#
# Environment variables:
#   - GH_TOKEN:      GitHub token with permission to manage repository settings.
#   - SETTINGS_FILE: Path to the file containing settings JSON.
# =================================================================================================


if [ ! -f "$SETTINGS_FILE" ]; then
  echo "No settings file found at '$SETTINGS_FILE'."
  exit 0
fi

REPO=$(jq '
  del(._comment, .actions_enabled, .actions_allowed, .actions_default_workflow_permissions, .actions_can_approve_pull_request_reviews) |
  if .allow_squash_merge == false then del(.squash_merge_commit_title, .squash_merge_commit_message) else . end |
  if .allow_merge_commit == false then del(.merge_commit_title, .merge_commit_message) else . end |
  with_entries(select(.value != null))
' "$SETTINGS_FILE")
echo "Importing repository settings..."
echo "$REPO" | gh api "repos/$GITHUB_REPOSITORY" --method PATCH --input - > /dev/null

ACTIONS_PERMISSIONS=$(jq '{enabled: .actions_enabled, allowed_actions: .actions_allowed} | with_entries(select(.value != null))' "$SETTINGS_FILE")
if [ "$ACTIONS_PERMISSIONS" != "{}" ]; then
  echo "Importing Actions permissions..."
  echo "$ACTIONS_PERMISSIONS" \
    | gh api "repos/$GITHUB_REPOSITORY/actions/permissions" --method PUT --input - > /dev/null
fi

ACTIONS_WORKFLOW=$(jq '{default_workflow_permissions: .actions_default_workflow_permissions, can_approve_pull_request_reviews: .actions_can_approve_pull_request_reviews} | with_entries(select(.value != null))' "$SETTINGS_FILE")
if [ "$ACTIONS_WORKFLOW" != "{}" ]; then
  echo "Importing Actions workflow permissions..."
  echo "$ACTIONS_WORKFLOW" \
    | gh api "repos/$GITHUB_REPOSITORY/actions/permissions/workflow" --method PUT --input - > /dev/null
fi

echo "Imported repository settings."
