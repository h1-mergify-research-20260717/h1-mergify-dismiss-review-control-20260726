#!/usr/bin/env bash
set -euo pipefail

status=$(curl --silent --show-error --output /tmp/h1-fork-token-response --write-out '%{http_code}' \
  --request POST \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  "${GITHUB_API_URL}/repos/${GH_REPOSITORY}/issues/${H1_TARGET_PR}/comments" \
  --data '{"body":"H1_FORK_TOKEN_WRITE_MARKER_20260727"}')

echo "H1_FORK_TOKEN_WRITE_STATUS=${status}"
rm -f /tmp/h1-fork-token-response
