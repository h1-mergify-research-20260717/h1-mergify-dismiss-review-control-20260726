#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${H1_FORK_BOUNDARY_CANARY:-}" ]]; then
  echo "H1_FORK_SECRET_PRESENT=true"
else
  echo "H1_FORK_SECRET_PRESENT=false"
fi
