#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# == 2 ]] || { echo 'Usage: restore-template-draft.sh EXPORTED_DRAFT_JSON OUTPUT_JSON (offline only)' >&2; exit 64; }
python3 scripts/template-draft.py restore "$1" "$2"
