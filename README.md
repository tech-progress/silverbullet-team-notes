# SilverBullet — SilverBullet team notes

Template contract **1.0.2** Source releases and marketplace publication are distinct; require the exact-revision gates in PUBLISHING.md before promotion. Pinned upstream **2.11.1 slim**; image digests are in Dockerfile/Compose, independent of VERSION. Railway authoring dependency is exactly `railway@3.6.0`, with `bun.lock`. Runtime, authentication, storage and deployment defaults are unchanged from v1.0.1.

## What this deploys

A small trusted team running independently authorized Markdown spaces, notes, attachments and the built-in dashboard. No Chromium, browser Runtime API, database, broker, SMTP or external identity provider. Writers are trusted collaborators, not hostile tenants.

## Authentication and first boot

The wrapper runs the supported `silverbullet setup` CLI before opening a socket. It seeds an administrator and private `/team` space, and refuses partial accounts/spaces configuration rather than exposing the unauthenticated setup wizard. Create ordinary users and additional spaces in `/.dashboard`; choose anonymous access **none**, grant each account only its own space, and keep shell capabilities disabled. Administrators intentionally see every space. The slim build cannot run server-side browser Runtime API features. API tokens are per-account, not legacy `SB_AUTH_TOKEN` or a shared `SB_USER`.

## Local use

Requirements: Docker Engine/Compose v2, Bash, OpenSSL, Python 3 standard library, jq and Bun. No Docker socket is mounted into any application. Commands run from this directory:

```sh
export SB_ADMIN_PASSWORD="$(openssl rand -hex 16)"
export SB_ADMIN_USER=admin
export LOCAL_PORT=18320
bash scripts/build.sh
bash scripts/start.sh
# Open http://127.0.0.1:18320 and use the generated administrator.
# Preserve passwords in a password manager; shell variables are not a backup.
docker compose down                 # retains your data
```

`.env.example` documents operator inputs; use `.env` only locally and never commit it. Blank required secrets fail closed. `bash scripts/smoke.sh` generates its own credentials and unique Compose project, builds/starts with bounded waits, exercises real application work, restarts, restores into newly recreated volumes and cleans only its own project. It does not use your existing data. Use an unused LOCAL_PORT within 18320–18349. Runtime logs, recovery artifacts and evidence live in ignored `.local/`; backups there contain secrets/private content and must not be distributed.

## Railway source and networking

`.railway/railway.ts` requires an **actually accessible** `TEMPLATE_SOURCE_REPO` (`owner/repository`) and an **existing** slash-free `TEMPLATE_SOURCE_BRANCH`. The historical sanitized standalone source is [tech-progress/silverbullet-team-notes](https://github.com/tech-progress/silverbullet-team-notes); immutable `v1.0.1` resolves to `dc2fd4b53169da7e9fa4eb57e37d376ae8288d7d`. Its `main`/`release-v1` channels and selected Railway source access were verified for that commit, not for another source revision. Set `TEMPLATE_SOURCE_ROOT_DIR` to `/silverbullet-team-notes` for a monorepo or `/` for a sanitized standalone copy. This becomes Railway's `source.rootDirectory`. Recheck source authorization and the exact release-channel commit before v1.0.2 qualification; no deployment button is offered here.

Install with `bun install --frozen-lockfile`; evaluate locally with `./node_modules/.bin/railway-iac-ts .railway/railway.ts` after supplying the three source settings. Only the app gets an HTTPS domain, targeting **3000**. Native login remains required. Private dependencies have no public domains or TCP proxies. Runtime listeners support Railway IPv6 private networking and local IPv4. Apply/audit the exported template's networking with the offline draft scripts before any authorized publication; see PUBLISHING.md. No paid or remote deployment is performed by verification scripts.

## Required and generated variables

All Railway values, generators and references are in `template-defaults.json`; descriptions in `template-descriptions.json`. Do not paste real secrets into those files. Local Compose uses the required names in `.env.example`; Railway uses generated secrets and references below. PORT values are fixed to the upstream target ports, not arbitrary redirect ports. SMTP, SSO and AI secrets are intentionally absent.

### SilverBullet

| Variable | Railway default | Meaning |
| --- | --- | --- |
| `PORT` | `3000` | PORT: pinned deployment setting; see README for scope and recovery requirements. |
| `SB_PORT` | `3000` | SB_PORT: pinned deployment setting; see README for scope and recovery requirements. |
| `SB_HOSTNAME` | `::` | SB_HOSTNAME: pinned deployment setting; see README for scope and recovery requirements. |
| `SB_FOLDER` | `/data` | SB_FOLDER: pinned deployment setting; see README for scope and recovery requirements. |
| `SB_ADMIN_USER` | `admin` | SB_ADMIN_USER: pinned deployment setting; see README for scope and recovery requirements. |
| `SB_ADMIN_PASSWORD` | `Generated 32-character secret` | Generated initial administrator password; changing it does not reset existing accounts. Keep the full /data root. |
| `PUID` | `1000` | PUID: pinned deployment setting; see README for scope and recovery requirements. |
| `PGID` | `1000` | PGID: pinned deployment setting; see README for scope and recovery requirements. |

Canonical public URL variables must match your HTTPS domain, including any custom domain. Private DNS must not be replaced with localhost. Password/reference rotation requires coordinated server/client changes; resetting an environment variable is not account recovery. Keep generated settings with backups.

## Storage and recovery

One app volume at `/data`, 5 GB initial size, attached only to that service. One replica; a mounted volume does not imply HA. Account/configuration files and default space folders remain inside the mounted root. Do not configure external host folders.

Stop the app, then archive **all** of `/data`, including users.json, spaces.json, server configuration, authentication/session secrets, hidden state, managed revisions and the spaces subdirectories. Restore to an empty mounted `/data` on the identical pinned image before starting. Do not restore only Markdown pages if you need accounts, memberships, tokens and attachments. Password variables initialize fresh installations only; changing them does not reset existing accounts. Use another administrator in the dashboard for password recovery; if all admins are lost, restore a known-good full-root backup and rotate tokens. Offline/manual credential repair is not qualified.

## Verification and limits

`bash scripts/verify.sh` checks structure, documentation/version consistency, JSON, dependency lock, Compose and offline IaC/draft contracts. For bounded local checks with already installed dependencies, `STATIC_ONLY=1 bash scripts/verify.sh` skips dependency installation and Docker/Compose entirely; it does not qualify build/start or runtime. A sanitized standalone copy uses `PUBLIC_DISTRIBUTION=1` and source root `/`; private maintainer records are not required there. `bash scripts/smoke.sh` is the destructive **isolated test** gate, not a production restoration command. See SUPPORT.md and UPGRADE.md.

Historical v1.0.1 qualification covered the exact stored draft graph deployed through `templateDeployV2`, native owner login, ordinary-account tokens, two private spaces, anonymous/cross-space denial, note/attachment bytes, browser cached editing during a real server outage and exact-byte reconnect synchronization. A quiesced full-root archive restored accounts, memberships, tokens and content into a fresh Railway volume. A two-client soak performed 120 authenticated note reads in 68.4 seconds; this is bounded headroom evidence, not production capacity or HA. These results belong to the immutable v1.0.1 commit above and do not qualify v1.0.2.

Open and synchronize a space while online first; offline availability depends on that browser's retained service-worker/local database state, not a server backup. Broader interactive dashboard workflows, Git sync and SSO remain unqualified; browser Runtime API is unsupported in the slim image (503 denial was verified on v1.0.1). No HA or multi-replica mode. Do not mount paths outside `/data` as spaces. A lost volume loses accounts and all content. Disable or carefully review any CONTAINER_BOOT.md file: upstream executes it on boot.

The historical draft remains **UNPUBLISHED**; provisional draft identifiers are not deployment links. Historical cleanup verified zero active deployments and zero running/created/restarting replicas before deleting validation resources/project. Railway retained-volume deletion windows remain disclosed: resource deletion does not prove physical erasure or billing zero. The owner accepts standard deletion plus verified zero compute and disclosed retention for sequential publication; no new authorization decision is needed for that standard. v1.0.2 still requires sanitized-source release/privacy checks, exact stored-graph Railway requalification and cleanup, and shared marketplace synchronization/audit. A source commit or offline verification alone does not establish publication.

## Main upstream products

- [SilverBullet](https://silverbullet.md/)
- [SilverBullet source](https://github.com/silverbulletmd/silverbullet)

Configuration/license reviewed at the pinned source: [2.11.1 slim](https://github.com/silverbulletmd/silverbullet/tree/2.11.1), [MIT license](https://github.com/silverbulletmd/silverbullet/blob/2.11.1/LICENSE.md). LICENSE.upstream retains the tagged upstream license. The runtime retains the iA Writer/IBM Plex SIL Open Font License at `/usr/share/doc/silverbullet/FONT-LICENSE.md`; fonts and dependency licenses remain separate from the original wrapper's MIT license. Upstream images are built from their pinned artifacts; this repository does not distribute a stripped binary image.

## Recipe license and distribution

Newly authored recipe/wrapper/application code is MIT licensed; see `LICENSE`. This does not relicense upstream applications, dependencies or marks. Preserve upstream notices and corresponding-source obligations. Public distributions exclude internal findings, license-review journals and publication operations. Historical v1.0.1 source selection was qualified; v1.0.2 source selection must be independently requalified. No blanket transitive artifact/SBOM/legal certification is claimed.
