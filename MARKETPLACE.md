# Deploy and Host SilverBullet team notes on Railway

Authenticated multi-space Markdown notes without a browser runtime

## About hosting

A small trusted team running independently authorized Markdown spaces, notes, attachments and the built-in dashboard. No Chromium, browser Runtime API, database, broker, SMTP or external identity provider. Writers are trusted collaborators, not hostile tenants.

## What gets deployed

One app volume at `/data`, 5 GB initial size, attached only to that service. One replica; a mounted volume does not imply HA. Account/configuration files and default space folders remain inside the mounted root. Do not configure external host folders.

## Operational contract

The wrapper runs the supported `silverbullet setup` CLI before opening a socket. It seeds an administrator and private `/team` space, and refuses partial accounts/spaces configuration rather than exposing the unauthenticated setup wizard. Create ordinary users and additional spaces in `/.dashboard`; choose anonymous access **none**, grant each account only its own space, and keep shell capabilities disabled. Administrators intentionally see every space. The slim build cannot run server-side browser Runtime API features. API tokens are per-account, not legacy `SB_AUTH_TOKEN` or a shared `SB_USER`.

Set a real admin identity before first boot, store generated passwords securely, keep only the app public, and retain encrypted off-volume backups. Follow README.md for variables, source settings, URLs and restore procedures. This is a single-node template, not an HA architecture. Railway plans/volume limits and application workload determine suitability.

**Unpublished:** no template ID/code or deployment URL is assigned. Source authorization, root metadata sync/audit and approved Railway qualification must pass before offering a deploy button.

## Main upstream products

- [SilverBullet](https://silverbullet.md/)
- [SilverBullet source](https://github.com/silverbulletmd/silverbullet)
