#!/usr/bin/env bash
set -euo pipefail

# =================================================================================================
# Commits the changes locally and opens a pull request if there is anything to merge.
#
# Environment variables:
#   - GH_TOKEN:      GitHub token with permission to create pull requests.
#   - REPO_DIR:      Path to the repository to commit and open a pull request in.
#   - BASE_BRANCH:   The branch into which we wish to merge.
#   - UPDATE_BRANCH: The name of the temporary branch used to stage the pull request.
#   - PR_TITLE:      The title for the pull request.
#   - PR_BODY_FILE:  Path to a file containing the pull request body.
# =================================================================================================

# 0. Setup

PR_TITLE=$(echo "$PR_TITLE" | envsubst)
PR_BODY=$(envsubst < "$PR_BODY_FILE")

git -C "$REPO_DIR" config user.name  "github-actions[bot]"
git -C "$REPO_DIR" config user.email "github-actions[bot]@users.noreply.github.com"
git -C "$REPO_DIR" switch -C "$UPDATE_BRANCH"
git -C "$REPO_DIR" add -A

# 1. If something has changed, commit and push the changes to UPDATE_BRANCH.

if git -C "$REPO_DIR" diff --cached --quiet; then

  echo "No changes to commit."

else

  git -C "$REPO_DIR" commit -m "$PR_TITLE"
  git -C "$REPO_DIR" push --force origin "$UPDATE_BRANCH"

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
