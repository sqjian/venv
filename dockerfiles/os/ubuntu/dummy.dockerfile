FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces


RUN apt-get update -y

COPY scripts/internal/ripgrep scripts/internal/ripgrep
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/ripgrep/install.sh

COPY scripts/internal/fd scripts/internal/fd
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/fd/install.sh