FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools-stable.sh \
        && ./clean.sh

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./extra.sh \
        && ./clean.sh