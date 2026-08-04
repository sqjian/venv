FROM nvcr.io/nvidia/cuda:13.2.1-cudnn-devel-ubuntu22.04

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
