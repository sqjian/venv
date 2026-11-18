FROM ubuntu:24.04

ENV TZ=Asia/Shanghai

ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_CACHE_HOME=/root/.cache
ENV XDG_STATE_HOME=/root/.local/state
ENV XDG_DATA_DIRS=/usr/local/share:/usr/share
ENV XDG_CONFIG_DIRS=/etc/xdg

ENV PATH="/root/.local/bin:${PATH}"

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

COPY --chmod=0644 <<EOF /root/.curlrc
insecure
EOF

WORKDIR /workspaces

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts,target=/mnt/scripts <<EOF
set -ex
/mnt/scripts/main.sh
EOF
