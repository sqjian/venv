FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /lab

COPY scripts .

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools_from_precompiled.sh \
        && ./tools_from_sources.sh \
        && ./shell.sh \
        && ./clean.sh \
        && rm -rf *

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
