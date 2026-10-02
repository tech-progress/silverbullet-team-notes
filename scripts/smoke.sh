#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export LOCAL_PORT="${LOCAL_PORT:-18320}"
[[ "$LOCAL_PORT" =~ ^183[0-4][0-9]$ ]] || { echo 'Use an isolated loopback port from 18300 through 18349' >&2; exit 64; }
export COMPOSE_PROJECT_NAME="rt-silverbullet-team-notes-$(date +%s)-$$"
export SB_ADMIN_USER=admin SB_ADMIN_PASSWORD="$(openssl rand -hex 16)"
export MEALIE_ADMIN_EMAIL=admin@example.invalid MEALIE_ADMIN_PASSWORD="$(openssl rand -hex 16)"
export PAPERLESS_ADMIN_USER=admin PAPERLESS_ADMIN_PASSWORD="$(openssl rand -hex 16)" PAPERLESS_SECRET_KEY="$(openssl rand -hex 32)" DATABASE_PASSWORD="$(openssl rand -hex 16)" BROKER_PASSWORD="$(openssl rand -hex 16)"
mkdir -p .local
cleanup() {
  status=$?
  docker compose logs --no-color >.local/runtime.log 2>&1 || true
  if ! docker compose down --volumes --remove-orphans --rmi local >.local/cleanup.log 2>&1; then
    echo "Own-project cleanup failed; inspect .local/cleanup.log" >&2
    status=1
  fi
  exit "$status"
}
trap cleanup EXIT
printf '%s\n' "$(date -u +%FT%TZ) project=$COMPOSE_PROJECT_NAME port=$LOCAL_PORT" >.local/evidence.txt
timeout 900 bash scripts/build.sh >.local/build.log 2>&1
bash scripts/start.sh >.local/start.log 2>&1
docker stats --no-stream --format '{{.Name}} IDLE_CPU={{.CPUPerc}} IDLE_MEM={{.MemUsage}}' $(docker compose ps -q) >>.local/evidence.txt
PYTHONUNBUFFERED=1 timeout 1800 python3 scripts/smoke.py | tee -a .local/evidence.txt
docker stats --no-stream --format '{{.Name}} CPU={{.CPUPerc}} MEM={{.MemUsage}}' $(docker compose ps -q) >>.local/evidence.txt
