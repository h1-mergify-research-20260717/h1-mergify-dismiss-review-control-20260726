#!/usr/bin/env bash
set -euo pipefail

repository="${GITHUB_REPOSITORY}"
pr_number="${GITHUB_REF#refs/pull/}"
pr_number="${pr_number%%/*}"
api_url="${GITHUB_API_URL:-https://api.github.com}"
payload='{"body":"H1_FORK_TOKEN_WRITE_MARKER_20260727"}'

status=$(curl --silent --show-error \
  --output /tmp/h1-fork-token-write-response.json \
  --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header 'Accept: application/vnd.github+json' \
  --header 'X-GitHub-Api-Version: 2022-11-28' \
  --data "$payload" \
  "${api_url}/repos/${repository}/issues/${pr_number}/comments")
rm -f /tmp/h1-fork-token-write-response.json

echo "H1_FORK_TOKEN_WRITE_STATUS=${status}"
if [[ "$status" == "201" ]]; then
  echo 'H1_FORK_TOKEN_WRITE_GRANTED=true'
else
  echo 'H1_FORK_TOKEN_WRITE_GRANTED=false'
fi
