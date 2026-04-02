#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Commits the changes locally and opens a pull request if there is anything to merge.
#
# Environment variables:
#   - PR_TITLE:    The title for the pull request.
#   - BASE_BRANCH: The branch into which we wish to merge.
#   - SYNC_BRANCH: The name of the temporary branch used to stage the pull request.
#
# Requirements:
#   - templates/pull-request-body.md should contain the pull request body template.
# =================================================================================================


# =================================================================================================
# Setup
# =================================================================================================

PR_BODY=$(cat templates/pull-request-body.md)

git config user.name  "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git checkout -B "$SYNC_BRANCH"
[ -d .github/rulesets ] && git add .github/rulesets/ || true

# =================================================================================================
# 1. If something has changed, commit and push the changes to SYNC_BRANCH.
# =================================================================================================

if git diff --cached --quiet; then

  echo "No changes to commit."

else

  git commit -m "$PR_TITLE"
  git push --force origin "$SYNC_BRANCH"

  # =================================================================================================
  # 2. Open a new pull request if there isn't one already.
  #    If the last pull request from us hasn't yet been merged,
  #    no action is required as we use the same branch.
  # =================================================================================================

  # Determine whether there already exists a PR.
  pr_exists=$(gh pr list \
    --repo "$GITHUB_REPOSITORY" \
    --head "$SYNC_BRANCH" \
    --state open \
    --json number \
    --jq 'length > 0')

  # If not, create one.
  if [[ "$pr_exists" == "false" ]]; then
    gh pr create \
      --repo "$GITHUB_REPOSITORY" \
      --head "$SYNC_BRANCH" \
      --base "$BASE_BRANCH" \
      --title "$PR_TITLE" \
      --body "$PR_BODY"
    echo "Opened a new pull request to merge exported rulesets."
  else
    echo "A pull request is already open for exported rulesets."
  fi

fi
