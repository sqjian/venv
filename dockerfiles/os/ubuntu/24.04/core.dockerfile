FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BASH_ENV="/etc/profile"

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./core.sh \
        && ./clean.sh