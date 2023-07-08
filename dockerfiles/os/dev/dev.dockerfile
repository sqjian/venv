FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /lab

COPY scripts .

RUN set -eux \
    && find . -type f -name "*.sh" -exec chmod +x {} \;

RUN set -eux \
    && ./dev.sh
