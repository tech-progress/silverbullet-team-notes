#!/bin/bash
set -euo pipefail
: "${SB_ADMIN_USER:?Set SB_ADMIN_USER}" "${SB_ADMIN_PASSWORD:?Set SB_ADMIN_PASSWORD}"
[[ "$SB_ADMIN_USER" =~ ^[a-zA-Z0-9_-]+$ ]] || exit 64
[[ ${#SB_ADMIN_PASSWORD} -ge 16 && "$SB_ADMIN_PASSWORD" != *:* ]] || exit 64
export SB_FOLDER=/data SB_HOSTNAME=:: SB_PORT=3000
mkdir -p /data
if [[ ! -e /data/users.json && ! -e /data/spaces.json ]]; then
  /silverbullet setup /data --admin "$SB_ADMIN_USER:$SB_ADMIN_PASSWORD" --space Team --at /team
fi
[[ -s /data/users.json && -s /data/spaces.json ]] || { echo 'Incomplete configuration: restore the full data root; refusing the unauthenticated setup wizard.' >&2; exit 78; }
chown -R "${PUID:-1000}:${PGID:-1000}" /data
exec /docker-entrypoint.sh
