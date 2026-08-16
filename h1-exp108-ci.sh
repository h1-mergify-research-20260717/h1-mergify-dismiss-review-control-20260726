#!/usr/bin/env bash
set -euo pipefail
payload=$(printf 'EXP108 GITHUB_TOKEN write boundary marker\n' | base64 -w0)
export EXP108_PAYLOAD="$payload"
body=$(python3 - <<PY
import json,os
print(json.dumps({'message':'EXP108 token boundary marker','content':os.environ['EXP108_PAYLOAD'],'branch':os.environ['H1_EXP108_SIDE_BRANCH']},separators=(',',':')))
PY
)
code=$(curl -sS -o /tmp/exp108-write-response.json -w '%{http_code}' -X PUT \
  -H 'Accept: application/vnd.github+json' \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H 'Content-Type: application/json' \
  --data "$body" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/contents/$H1_EXP108_MARKER_PATH")
echo "EXP108_TOKEN_WRITE_HTTP=$code"
exit 0
