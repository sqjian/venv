ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_CACHE_HOME=/root/.cache
ENV XDG_STATE_HOME=/root/.local/state
ENV XDG_DATA_DIRS=/usr/local/share:/usr/share
ENV XDG_CONFIG_DIRS=/etc/xdg

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

SHELL ["/bin/bash", "-l", "-c"]

COPY <<EOF /root/.curlrc
--tlsv1.3
--tls-max 1.3
EOF

WORKDIR /workspace

COPY scripts .

RUN set -ex \
    && find . -type f -name "*.sh" -exec chmod +x {} \;

RUN set -ex \
    && ./debug.sh
