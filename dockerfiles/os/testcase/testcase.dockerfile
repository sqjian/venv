FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /lab

COPY scripts .

RUN set -ex \
    && find . -type f -name "*.sh" -exec chmod +x {} \;

RUN set -ex \
    && ./testcase.sh
