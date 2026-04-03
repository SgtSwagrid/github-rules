for file in .github/rulesets/*.json; do

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
