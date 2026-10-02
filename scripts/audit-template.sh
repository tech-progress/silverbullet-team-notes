#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 1 ]] || { echo 'Usage: audit-template.sh EXPORTED_DRAFT_JSON (offline, no cloud access)' >&2; exit 64; }
python3 scripts/template-draft.py audit "$1"
