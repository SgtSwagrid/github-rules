#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Imports rulesets from RULESETS_DIR into GitHub's internal configuration.
#
# Environment variables:
#   - GH_TOKEN:     GitHub token with permission to manage rulesets.
#   - RULESETS_DIR: Path to the directory containing ruleset JSON files.
# =================================================================================================


shopt -s nullglob
for file in "$RULESETS_DIR"/*.json; do

  RULESET_NAME=$(jq -r '.name' "$file")

  EXISTING_ID=$(gh api "repos/$GITHUB_REPOSITORY/rulesets" \
    --jq ".[] | select(.name == \"$RULESET_NAME\") | .id" 2>/dev/null || true)

  if [ -n "$EXISTING_ID" ]; then
    echo "Skipping ruleset '$RULESET_NAME' because it already exists."
    continue
  fi

  jq 'del(._comment)' "$file" \
    | gh api "repos/$GITHUB_REPOSITORY/rulesets" --method POST --input - > /dev/null

  echo "Imported ruleset '$RULESET_NAME'."

done
