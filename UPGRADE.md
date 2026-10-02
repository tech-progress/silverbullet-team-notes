# Upgrade and rollback

Template SemVer describes services/variables/storage/authentication; upstream software versions are separate pins. Start at contract 1.0.0. Incompatible storage/auth/source changes require a new template major version.

Keep a stopped-writer full-root archive and stable settings, validate the new slim image on a copy, then change its digest and rerun two-account access, revisions, attachment, restart and restore tests. Never switch to legacy single-space mode as an upgrade shortcut.

Before upgrading: stop ingestion/writes, retain encrypted off-volume backups and generated secrets, record image digests, and verify a restore to an isolated clean volume. Preserve one replica and all mount paths. After upgrading: run the full meaningful smoke, examine migration/worker logs, verify anonymous/cross-account denial and retained bytes, and audit the exported template contract. Do not use mutable `latest` tags or automated major updates.

For publication, create a new verified version/tag and move the existing real `release-v1` channel only for compatible changes. Neither a release channel nor a public repository is created by this task. Downgrades without pre-migration snapshots are unsupported.
