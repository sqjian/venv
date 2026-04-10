ARG BASE_IMAGE=ubuntu:22.04

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces


RUN apt-get update -y

COPY scripts/internal/fish scripts/internal/fish
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/fish/install.sh

COPY scripts/internal/nvim scripts/internal/nvim
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/nvim/install.sh