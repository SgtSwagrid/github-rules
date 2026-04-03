#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Commits the changes locally and opens a pull request if there is anything to merge.
#
# Environment variables:
#   - GH_TOKEN:      GitHub token with permission to create pull requests.
#   - BASE_BRANCH:   The branch into which we wish to merge.
#   - UPDATE_BRANCH: The name of the temporary branch used to stage the pull request.
#   - PR_TITLE:      The title for the pull request.
#   - PR_BODY_FILE:  Path to a file containing the pull request body.
# =================================================================================================

# 0. Setup

PR_BODY=$(cat "$PR_BODY_FILE")

git config user.name  "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git switch -C "$UPDATE_BRANCH"
git add -A

# 1. If something has changed, commit and push the changes to UPDATE_BRANCH.

if git diff --cached --quiet; then

  echo "No changes to commit."

else

  git commit -m "$PR_TITLE"
  git push --force origin "$UPDATE_BRANCH"

  # 2. Open a new pull request if there isn't one already.
  #    If the last pull request from us hasn't yet been merged,
  #    no action is required as we use the same branch.

  # Determine whether there already exists a PR.
  pr_exists=$(gh pr list \
    --repo "$GITHUB_REPOSITORY" \
    --head "$UPDATE_BRANCH" \
    --state open \
    --json number \
    --jq 'length > 0')

  # If not, create one.
  if [[ "$pr_exists" == "false" ]]; then
    gh pr create \
      --repo "$GITHUB_REPOSITORY" \
      --head "$UPDATE_BRANCH" \
      --base "$BASE_BRANCH" \
      --title "$PR_TITLE" \
      --body "$PR_BODY"
    echo "Opened a new pull request."
  else
    echo "A pull request is already open."
  fi

fi
