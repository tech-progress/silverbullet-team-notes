#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export SB_ADMIN_PASSWORD="${SB_ADMIN_PASSWORD:-build-only-long-password}" MEALIE_ADMIN_PASSWORD="${MEALIE_ADMIN_PASSWORD:-build-only-long-password}" PAPERLESS_ADMIN_PASSWORD="${PAPERLESS_ADMIN_PASSWORD:-build-only-long-password}" PAPERLESS_SECRET_KEY="${PAPERLESS_SECRET_KEY:-build-only-secret-key-more-than-32-characters}" DATABASE_PASSWORD="${DATABASE_PASSWORD:-buildonly}" BROKER_PASSWORD="${BROKER_PASSWORD:-buildonly}"
exec docker compose build --pull app
