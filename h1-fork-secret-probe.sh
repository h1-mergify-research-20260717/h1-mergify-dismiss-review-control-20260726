#!/usr/bin/env bash
set -euo pipefail
# H1_EXTERNAL_FORK_ZERO_ACCESS_CONTROL_20260727
if [[ -n "${H1_FORK_BOUNDARY_CANARY:-}" ]]; then
  echo "H1_FORK_SECRET_PRESENT=true"
else
  echo "H1_FORK_SECRET_PRESENT=false"
fi
