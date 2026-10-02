FROM ghcr.io/silverbulletmd/silverbullet:2.11.1-slim@sha256:07dcc90f41eaa258814080bc3f9af47854e56b23ad0c8c7ffc2ac4bc98568a92
COPY --chmod=755 entrypoint.sh /template-entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/template-entrypoint.sh"]
