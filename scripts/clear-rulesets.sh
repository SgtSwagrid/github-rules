RULESET_IDS=$(gh api "repos/$GITHUB_REPOSITORY/rulesets" \
  --jq '.[].id' 2>/dev/null || true)

if [ -z "$RULESET_IDS" ]; then
  echo "No rulesets found."
  exit 0
fi

for ID in $RULESET_IDS; do
  RULESET_NAME=$(gh api "repos/$GITHUB_REPOSITORY/rulesets/$ID" --jq '.name')
  gh api "repos/$GITHUB_REPOSITORY/rulesets/$ID" --method DELETE
  echo "Deleted ruleset '$RULESET_NAME'."
done
