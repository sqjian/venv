FROM nvcr.io/nvidia/cuda:13.0.2-cudnn-devel-ubuntu24.04

ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_CACHE_HOME=/root/.cache
ENV XDG_STATE_HOME=/root/.local/state
ENV XDG_DATA_DIRS=/usr/local/share:/usr/share
ENV XDG_CONFIG_DIRS=/etc/xdg

ENV PATH="/root/.local/bin:${PATH}"

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

COPY <<EOF /root/.curlrc
--tlsv1.3
--tls-max 1.3
EOF

WORKDIR /workspaces

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts,target=/mnt/scripts <<EOF
set -ex
find /mnt/scripts -type f -name "*.sh" -exec chmod +x {} \;
/mnt/scripts/main.sh
EOF
