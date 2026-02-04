ARG BASE_IMAGE=sqjian/venv:ubuntu22.04-cuda12.9
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces

COPY scripts .

RUN --mount=type=cache,target=/root/.cache/Homebrew \
        find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./extra.sh \
        && ./clean.sh \
        && rm -rf *