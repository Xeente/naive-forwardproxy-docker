ARG RELEASE_TAG
ARG URL=https://github.com/klzgrad/forwardproxy/releases/download/${RELEASE_TAG}/caddy-forwardproxy-naive.tar.xz

FROM debian:bookworm-slim AS download

ARG URL

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	tar \
	xz-utils \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN curl -fsSL -o archive.tar.xz "$URL"

RUN set -eux; \
	mkdir -p /tmp/pkg; \
	tar -xf archive.tar.xz -C /tmp/pkg; \
	CADDY_BIN="$(find /tmp/pkg -type f -name caddy | head -n 1)"; \
	[ -n "$CADDY_BIN" ]; \
	install -D -m 0755 "$CADDY_BIN" /out/caddy; \
	rm -rf /tmp/pkg /tmp/archive.tar.xz

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=download /out/caddy /usr/local/bin/caddy

CMD exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
