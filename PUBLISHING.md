# Publishing and exact-revision qualification

The current template contract is **1.0.2**. Source releases and marketplace publication are distinct. This documentation correction preserves the upstream2.11.1 slim image, wrapper, IaC, authentication defaults, data format and original notices. Require all gates below before promotion; a local verifier or source tag alone is not publication proof.

## Source and historical qualification

The sanitized standalone repository is [tech-progress/silverbullet-team-notes](https://github.com/tech-progress/silverbullet-team-notes), with main/release-v1, root `/` and immutable version tags. Historical v1.0.1 resolves to `dc2fd4b53169da7e9fa4eb57e37d376ae8288d7d`; preserve it and v1.0.0 unchanged. That revision passed actual queried DeployV2/native account/private-space authorization, note/attachment bytes, browser outage editing/reconnect, fresh Railway volume full-root restore and a68.4-second two-client soak. Its draft was then UNPUBLISHED. Historical evidence does not qualify another source revision or establish capacity/HA.

Owner-approved cleanup means accepted standard deletion requests, verified zero running compute and disclosed platform retention. Project-not-found or elapsed retention timestamps do not prove physical storage removal or billing cessation. Keep those flags separate; no retention/admin probing or waiting-only project is required.

## Release checklist

1. Review the selected source-only grants, original notices and documented trusted-writer default exposure. Preserve MIT and SIL OFL texts. This is not universal image/SBOM/security/legal certification or assembled-image redistribution clearance; image redistribution has independent applicable obligations.
2. Freeze a self-contained sanitized standalone tree. Exclude `.local/`, node_modules, private FINDINGS.md and environment files except `.env.example`; include public PUBLISHING/LICENSE_REVIEW/support/upgrade docs, wrapper source, exact manifest/lock and every main upstream link. Run the frozen verifier before committing or pushing. Create each immutable tag once; never move historical tags.
3. Set `TEMPLATE_SOURCE_REPO=tech-progress/silverbullet-team-notes`, `TEMPLATE_SOURCE_BRANCH=release-v1` and `TEMPLATE_SOURCE_ROOT_DIR=/` for standalone authoring. Run `PUBLIC_DISTRIBUTION=1 bash scripts/verify.sh`; `STATIC_ONLY=1` checks installed dependencies without Docker/installation and is not build/start qualification. Recheck actual selected channel/source access separately.
4. Restore an exported draft offline with `scripts/restore-template-draft.sh`, audit its actual ID-keyed graph with `scripts/audit-template.sh`, then apply only that reviewed configuration under explicit owner authorization and independently requery it. Missing real service/volume IDs must fail, not be fabricated.
5. Deploy the exact queried graph through DeployV2 into owned scratch resources. Observe intended source/revision and SUCCESS/current one replica, native owner/accounts/private-space allow/deny, restart, browser offline/reconnect, independent fresh-volume full-root recovery and bounded soak/metrics. Historical proofs from other source revisions are not substituted. One replica only; no HA or hostile-tenant claim.
6. Stop all owned deployment revisions and verify zero compute before standard deletion. Revoke owned temporary keys and retire credentials/archives; disclose retained-volume uncertainty. Do not modify unrelated projects/resources.
7. Publish only after source/core/recovery/cleanup gates pass. Derive the final listing code from actual PUBLISHED readback, not a provisional draft code. Add actual ID/code and product metadata to the shared registry; run `scripts/sync-template-marketplace.sh silverbullet-team-notes` only for this template and require the complete `scripts/audit-template-marketplace.sh` to pass. Requery the unchanged qualified graph and listing fields.

Draft verification tools transform offline JSON; they do not implicitly deploy, publish or restore production data. No private evidence links belong in distributed documentation.
