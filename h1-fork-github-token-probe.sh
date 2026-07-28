#!/usr/bin/env bash
set -u

payload='{"body":"H1_FORK_GITHUB_TOKEN_WRITE_MARKER_20260728"}'
status="$(
  curl --silent --show-error \
    --output /tmp/h1-fork-github-token-response.json \
    --write-out '%{http_code}' \
    --request POST \
    --header "Accept: application/vnd.github+json" \
    --header "Authorization: Bearer ${H1_GITHUB_TOKEN}" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${H1_REPOSITORY}/issues/${H1_TARGET_ISSUE_NUMBER}/comments" \
    --data "${payload}"
)"
rm -f /tmp/h1-fork-github-token-response.json

echo "H1_FORK_GITHUB_TOKEN_WRITE_STATUS=${status}"
if [[ "${status}" == "201" ]]; then
  echo "H1_FORK_GITHUB_TOKEN_WRITE_SUCCEEDED=true"
else
  echo "H1_FORK_GITHUB_TOKEN_WRITE_SUCCEEDED=false"
fi
exit 0
