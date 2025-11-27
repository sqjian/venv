ARG BASE_IMAGE=sqjian/venv:ubuntu22.04-cuda12.8-stable
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools-frequent.sh \
        && ./clean.sh