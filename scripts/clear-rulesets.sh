RULESET_IDS=$(gh api "repos/${{ github.repository }}/rulesets" \
  --jq '.[].id' 2>/dev/null || true)

if [ -z "$RULESET_IDS" ]; then
  echo "No existing rulesets found."
  exit 0
fi

for ID in $RULESET_IDS; do
  RULESET_NAME=$(gh api "repos/${{ github.repository }}/rulesets/$ID" --jq '.name')
  gh api "repos/${{ github.repository }}/rulesets/$ID" --method DELETE
  echo "Deleted ruleset '$RULESET_NAME'."
done
