#!/usr/bin/env bash
set -euo pipefail
set +x

aud="${H1_OIDC_AUDIENCE:-h1-mergify-owned-oidc-control-20260728}"

if [[ -z "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" || -z "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:-}" ]]; then
  echo "H1_OIDC_REQUEST_AVAILABLE=false"
  echo "H1_OIDC_HTTP_STATUS=unavailable"
  echo "H1_OIDC_TOKEN_RECEIVED=false"
  exit 0
fi

echo "H1_OIDC_REQUEST_AVAILABLE=true"
tmp="$(mktemp)"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

separator='?'
if [[ "$ACTIONS_ID_TOKEN_REQUEST_URL" == *'?'* ]]; then
  separator='&'
fi

status="$(curl --silent --show-error \
  --output "$tmp" \
  --write-out '%{http_code}' \
  -H "Authorization: bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
  "${ACTIONS_ID_TOKEN_REQUEST_URL}${separator}audience=${aud}" || true)"

echo "H1_OIDC_HTTP_STATUS=${status:-request-error}"

python3 - "$tmp" <<'PYCODE'
import base64
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
try:
    document = json.loads(path.read_text())
except Exception:
    print("H1_OIDC_TOKEN_RECEIVED=false")
    raise SystemExit(0)

token = document.get("value")
if not isinstance(token, str) or token.count(".") < 2:
    print("H1_OIDC_TOKEN_RECEIVED=false")
    raise SystemExit(0)

print("H1_OIDC_TOKEN_RECEIVED=true")
payload = token.split(".", 2)[1]
payload += "=" * ((4 - len(payload) % 4) % 4)
try:
    claims = json.loads(base64.urlsafe_b64decode(payload.encode()))
except Exception:
    print("H1_OIDC_SELECTED_CLAIMS={}")
    raise SystemExit(0)

allowed = [
    "aud",
    "sub",
    "repository",
    "repository_owner",
    "repository_id",
    "repository_owner_id",
    "ref",
    "sha",
    "event_name",
    "workflow_ref",
    "job_workflow_ref",
    "actor",
    "actor_id",
    "head_ref",
    "base_ref",
    "run_id",
    "run_number",
    "run_attempt",
]
selected = {key: claims.get(key) for key in allowed if key in claims}
print("H1_OIDC_SELECTED_CLAIMS=" + json.dumps(selected, sort_keys=True, separators=(",", ":")))
PYCODE
