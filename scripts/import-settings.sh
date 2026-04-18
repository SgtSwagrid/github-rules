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

jq 'del(._comment)' "$SETTINGS_FILE" \
  | gh api "repos/$GITHUB_REPOSITORY" --method PATCH --input - > /dev/null

echo "Imported repository settings."
