FROM ghcr.io/silverbulletmd/silverbullet:2.11.1-slim@sha256:07dcc90f41eaa258814080bc3f9af47854e56b23ad0c8c7ffc2ac4bc98568a92
COPY LICENSE LICENSE.upstream /usr/share/doc/silverbullet/
RUN curl -fsSL https://raw.githubusercontent.com/silverbulletmd/silverbullet/2.11.1/client/fonts/LICENSE.md -o /usr/share/doc/silverbullet/FONT-LICENSE.md && echo 'c7e499e9a952652c0c0f24cea594ee7eea93a6535ea06bff3f36e4dff3244685  /usr/share/doc/silverbullet/FONT-LICENSE.md' | sha256sum -c -
COPY --chmod=755 entrypoint.sh /template-entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/template-entrypoint.sh"]
