RULESETS=$(gh api "repos/$GITHUB_REPOSITORY/rulesets" 2>/dev/null || true)

if [ -z "$RULESETS" ] || [ "$RULESETS" = "[]" ]; then
  echo "No rulesets found."
  exit 0
fi

rm -rf .github/rulesets
mkdir -p .github/rulesets

echo "$RULESETS" | jq -c '.[]' | while read -r RULESET; do
  ID=$(echo "$RULESET" | jq -r '.id')
  RULESET_NAME=$(echo "$RULESET" | jq -r '.name')

  gh api "repos/$GITHUB_REPOSITORY/rulesets/$ID" \
    | jq 'del(.id, .source, .source_type, .created_at, .updated_at, .links, .node_id, .current_user_can_bypass)' \
    > ".github/rulesets/$RULESET_NAME.json"

  echo "Exported ruleset '$RULESET_NAME'."
done
