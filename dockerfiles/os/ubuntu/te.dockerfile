ARG BASE_IMAGE=ubuntu:22.04

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces


RUN apt-get update -y && apt-get install -y curl

RUN --mount=type=secret,id=gh_token \
    --mount=type=bind,source=scripts,target=/mnt/scripts <<EOF
set -ex
find /mnt/scripts -type f -name "*.sh" -exec chmod +x {} \;
/mnt/scripts/internal/fish/install.sh
EOF