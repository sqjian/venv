FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces


RUN apt-get update -y

COPY scripts/internal/fish scripts/internal/fish
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/fish/install.sh

COPY scripts/internal/starship scripts/internal/starship
RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/internal/starship/install.sh