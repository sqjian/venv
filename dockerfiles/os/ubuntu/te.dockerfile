ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}

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


RUN apt-get update -y && apt-get install -y curl

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts/fish,target=/mnt/scripts/fish <<EOF
set -ex
/mnt/scripts/fish/install.sh
EOF

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts/7zip,target=/mnt/scripts/7zip <<EOF
set -ex
/mnt/scripts/7zip/install.sh
EOF
