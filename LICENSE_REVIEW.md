# License review — 2026-10-02

Main product: SilverBullet 2.11.1 slim. Inspected primary tagged source and license, not a marketplace summary:

- Source: https://github.com/silverbulletmd/silverbullet/tree/2.11.1
- License: https://github.com/silverbulletmd/silverbullet/blob/2.11.1/LICENSE.md
- Declared license: **MIT**. Original text retained in LICENSE.upstream.

Official upstream images are pinned by manifest digest; wrapper source is included here. Preserve upstream notices and dependency licenses when redistributing images. Do not assume a product logo license grants trademark endorsement.

The deployment uses the slim official image, deliberately omitting Chromium. Retain the MIT notice with distributions. The wrapper invokes the supported setup CLI; no upstream source fork is required.

This is an engineering review, not legal advice or certification. A full transitive image/SBOM redistribution review remains outside this bounded correction; no blanket artifact certification is claimed. Historical v1.0.1 sanitized recipe source was released in `tech-progress/silverbullet-team-notes`; no public container artifact was distributed and the marketplace draft remained UNPUBLISHED. Current v1.0.2 preserves these source-only grant/default boundaries; an immutable source release does not itself qualify marketplace publication. Original MIT, upstream MIT and the runtime iA Writer/IBM Plex SIL OFL notices remain unchanged.

## Recipe ownership authorization — October 2, 2026

The owner explicitly approved MIT licensing for newly authored recipe, wrapper and application code. `LICENSE` applies only to that original code. It does not relicense upstream software, dependencies, fonts or trademarks. Upstream notices, copyleft corresponding-source delivery and network-use obligations remain independently applicable.
