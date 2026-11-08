ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}

ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_CACHE_HOME=/root/.cache
ENV XDG_STATE_HOME=/root/.local/state
ENV XDG_DATA_DIRS=/usr/local/share:/usr/share
ENV XDG_CONFIG_DIRS=/etc/xdg

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

COPY <<EOF /root/.curlrc
--tlsv1.3
--tls-max 1.3
EOF

WORKDIR /workspaces


RUN apt-get update -y && apt-get install -y curl

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts/installers/fish.sh,target=/mnt/scripts/installers/fish.sh <<EOF
set -ex
/mnt/scripts/installers/fish.sh
EOF

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts/installers/7zip.sh,target=/mnt/scripts/installers/7zip.sh <<EOF
set -ex
/mnt/scripts/installers/7zip.sh
EOF
