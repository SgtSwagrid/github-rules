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

jq 'del(._comment) | del(.actions_enabled, .actions_allowed, .actions_default_workflow_permissions, .actions_can_approve_pull_request_reviews)' "$SETTINGS_FILE" \
  | gh api "repos/$GITHUB_REPOSITORY" --method PATCH --input - > /dev/null

jq 'del(._comment) | {enabled: .actions_enabled, allowed_actions: .actions_allowed} | del(.[] | nulls)' "$SETTINGS_FILE" \
  | gh api "repos/$GITHUB_REPOSITORY/actions/permissions" --method PUT --input - > /dev/null

jq 'del(._comment) | {default_workflow_permissions: .actions_default_workflow_permissions, can_approve_pull_request_reviews: .actions_can_approve_pull_request_reviews} | del(.[] | nulls)' "$SETTINGS_FILE" \
  | gh api "repos/$GITHUB_REPOSITORY/actions/permissions/workflow" --method PUT --input - > /dev/null

echo "Imported repository settings."
