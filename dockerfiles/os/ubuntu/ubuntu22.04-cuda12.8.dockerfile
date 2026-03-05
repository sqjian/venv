FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces

COPY scripts scripts

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/main.sh \
    && rm -rf /scripts
