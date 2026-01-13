ARG BASE_IMAGE=sqjian/venv:ubuntu22.04-cuda12.9
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./extra.sh --apt-fast \
        && ./clean.sh \
        && rm -rf *