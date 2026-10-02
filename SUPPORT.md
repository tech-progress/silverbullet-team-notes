# Support and security boundary

A small trusted team running independently authorized Markdown spaces, notes, attachments and the built-in dashboard. No Chromium, browser Runtime API, database, broker, SMTP or external identity provider. Writers are trusted collaborators, not hostile tenants.

Browser offline edit/reconnect, interactive dashboard workflow, Git sync, SSO and runtime capability API behavior have not been qualified. No HA or multi-replica mode. Do not mount paths outside `/data` as spaces. A lost volume loses accounts and all content. Disable or carefully review any CONTAINER_BOOT.md file: upstream executes it on boot.

The wrapper runs the supported `silverbullet setup` CLI before opening a socket. It seeds an administrator and private `/team` space, and refuses partial accounts/spaces configuration rather than exposing the unauthenticated setup wizard. Create ordinary users and additional spaces in `/.dashboard`; choose anonymous access **none**, grant each account only its own space, and keep shell capabilities disabled. Administrators intentionally see every space. The slim build cannot run server-side browser Runtime API features. API tokens are per-account, not legacy `SB_AUTH_TOKEN` or a shared `SB_USER`.

Operate one replica per durable service. Keep the app public only through Railway HTTPS; no backend public domains or TCP proxies. Do not add Docker sockets, cross-service filesystem assumptions, or unreviewed optional integrations. Treat private DNS as routing, not authentication. Monitor volume capacity and task failures; no backup retention service is included.

Report template bootstrap/wrapper/IaC bugs with upstream version and sanitized logs. Report product bugs to https://github.com/silverbulletmd/silverbullet; never attach credentials, volume archives, private recipes/notes/documents, SQL dumps or generated graph secrets. `.local/` contains sensitive test recovery artifacts. Generated administrator env values do not reset existing accounts.

## Account/data recovery

Stop the app, then archive **all** of `/data`, including users.json, spaces.json, server configuration, authentication/session secrets, hidden state, managed revisions and the spaces subdirectories. Restore to an empty mounted `/data` on the identical pinned image before starting. Do not restore only Markdown pages if you need accounts, memberships, tokens and attachments. Password variables initialize fresh installations only; changing them does not reset existing accounts. Use another administrator in the dashboard for password recovery; if all admins are lost, restore a known-good full-root backup and rotate tokens. Offline/manual credential repair is not qualified.

## Qualification status

The reproducible tests are `scripts/verify.sh` and `scripts/smoke.sh`; operational/cloud/publication qualification is separate. See the maintainer-only FINDINGS.md for exact evidence. Do not copy FINDINGS.md or `.local/` into a public standalone distribution.
