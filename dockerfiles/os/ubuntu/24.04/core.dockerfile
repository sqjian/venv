ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV BASH_ENV="/etc/profile"

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./core.sh \
        && ./clean.sh