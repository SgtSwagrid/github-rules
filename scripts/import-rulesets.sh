for file in .github/rulesets/*.json; do

  RULESET_NAME=$(jq -r '.name' "$file")

  EXISTING_ID=$(gh api "repos/$GITHUB_REPOSITORY/rulesets" \
    --jq ".[] | select(.name == \"$RULESET_NAME\") | .id" 2>/dev/null || true)

  if [ -n "$EXISTING_ID" ]; then
    echo "Ruleset '$RULESET_NAME' already exists. Skipping."
    continue
  fi

  jq 'del(._comment)' "$file" \
    | gh api "repos/$GITHUB_REPOSITORY/rulesets" --method POST --input -

  echo "Ruleset '$RULESET_NAME' updated successfully."

done
