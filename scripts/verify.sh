#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for file in Dockerfile entrypoint.sh compose.yaml .env.example VERSION CHANGELOG.md README.md MARKETPLACE.md PUBLISHING.md SUPPORT.md UPGRADE.md LICENSE_REVIEW.md package.json bun.lock railway.json .railway/railway.ts marketplace-metadata.json template-defaults.json template-descriptions.json template-networking.json template-volumes.json scripts/build.sh scripts/start.sh scripts/smoke.sh scripts/audit-template.sh scripts/restore-template-draft.sh; do

  test -s "$file"
done
if [[ "${PUBLIC_DISTRIBUTION:-0}" != 1 ]]; then test -s FINDINGS.md; fi
[[ "$(cat VERSION)" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
for file in scripts/*.sh; do bash -n "$file"; done
bash -n entrypoint.sh
for file in *.json; do jq empty "$file"; done
jq -e '(.description | length) >= 45 and (.description | length) <= 75 and (.origins | length) >= 2 and (has("id")|not) and (has("code")|not)' marketplace-metadata.json >/dev/null
python3 - <<'PYDOCS'
import json
from pathlib import Path

version = Path("VERSION").read_text().strip()
readme = Path("README.md").read_text()
changelog = Path("CHANGELOG.md").read_text()
metadata = json.loads(Path("marketplace-metadata.json").read_text())
assert f"Template contract **{version}**" in readme
assert changelog.split("\n## ", 1)[1].splitlines()[0].startswith(f"{version} — ")
assert metadata.get("version", version) == version
for name in ("README.md", "CHANGELOG.md", "MARKETPLACE.md", "SUPPORT.md", "UPGRADE.md"):
    document = Path(name).read_text()
    assert f"{version}" in document, name
    assert "https://github.com/tech-progress/silverbullet-team-notes" in document, name
    assert "/tmp/" not in document and "worker3-validation" not in document, name
    assert "](FINDINGS" not in document and "](./FINDINGS" not in document, name
for name in ("README.md", "CHANGELOG.md", "SUPPORT.md", "UPGRADE.md"):
    assert "dc2fd4b53169da7e9fa4eb57e37d376ae8288d7d" in Path(name).read_text(), name
assert "no template ID/code or deployment URL is assigned" not in Path("MARKETPLACE.md").read_text()
print("PASS: docs/version/metadata consistency and historical source boundary")
PYDOCS
if [[ "${STATIC_ONLY:-0}" == 1 ]]; then
  test -x ./node_modules/.bin/railway-iac-ts
  printf '%s\n' 'STATIC_ONLY: using installed dependencies; skipping dependency installation and Docker/Compose. No build/start/runtime qualification.'
else
  bun install --frozen-lockfile >/dev/null
fi
export SB_ADMIN_PASSWORD=verification-only-long-password MEALIE_ADMIN_PASSWORD=verification-only-long-password PAPERLESS_ADMIN_PASSWORD=verification-only-long-password PAPERLESS_SECRET_KEY=verification-only-long-secret-with-32-characters DATABASE_PASSWORD=verificationonly BROKER_PASSWORD=verificationonly
export TEMPLATE_SOURCE_REPO="${TEMPLATE_SOURCE_REPO:-skyeagle/railway-templates}" TEMPLATE_SOURCE_BRANCH="${TEMPLATE_SOURCE_BRANCH:-main}"
mkdir -p .local
if [[ "${STATIC_ONLY:-0}" != 1 ]]; then docker compose config --quiet; fi
./node_modules/.bin/railway-iac-ts .railway/railway.ts >.local/verify-graph.json
jq -e '.ok == true and ([.graph.resources[] | select(.type == "service") | select(.source.type == "github") | .source.rootDirectory] | all(. != null))' .local/verify-graph.json >/dev/null
python3 - <<'PYVERIFY'
import json
from pathlib import Path

defaults = json.loads(Path("template-defaults.json").read_text())
graph = json.loads(Path(".local/verify-graph.json").read_text())
services = {resource["name"]: resource for resource in graph["graph"]["resources"] if resource["type"] == "service"}
for name, variables in defaults.items():
    for key, value in variables.items():
        if value.startswith("${{secret("):
            definition = services[name]["variables"][key]
            assert definition["type"] == "raw"
            assert definition["value"]["generator"] == value[3:-2]
            assert definition["value"]["preserveExisting"] is True
print("PASS: real server-side secret generators; no deterministic ctx.randomString credentials")
PYVERIFY
python3 scripts/template-draft.py self-test
if rg -n '(latest|:[[:space:]]*latest)' Dockerfile compose.yaml; then exit 1; fi
if rg -n '/var/run/docker.sock' Dockerfile compose.yaml .railway/railway.ts; then exit 1; fi
if [[ "${STATIC_ONLY:-0}" == 1 ]]; then
  printf '%s\n' 'PASS: static structure, JSON, docs/version, installed IaC source root and offline draft roundtrip only. Lock install, Compose, build/start, runtime and publication not qualified.'
else
  printf '%s\n' 'PASS: structure, JSON, docs/version, lock, Compose, IaC source root, offline draft roundtrip. Publication and live restore gates are separate.'
fi
