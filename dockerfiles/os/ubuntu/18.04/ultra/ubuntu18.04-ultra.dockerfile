FROM sqjian/venv:ubuntu18.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /lab

COPY scripts .

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./llvm_from_sources.sh \
        && ./shell.sh \
        && ./clean.sh \
        && rm -rf *

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
