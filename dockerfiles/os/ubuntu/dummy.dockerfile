FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces

COPY scripts scripts

RUN apt-get update -y

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/bat/install.sh

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/fzf/install.sh

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/gh/install.sh

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/ninja/install.sh

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/tmux/install.sh