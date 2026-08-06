#!/usr/bin/env bash

# Script benigno per validare la telemetria Audit di APPLIANCE-LAB.
# Non modifica il sistema e non esegue attività offensive.
set -euo pipefail

marker="${1:-TIO-NO-MARKER}"

printf '%s marker=%s user=%s uid=%s\n' \
  "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  "$marker" \
  "$(id -un)" \
  "$(id -u)"
