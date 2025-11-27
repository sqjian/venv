FROM sqjian/venv:ubuntu22.04-stable

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /lab

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools-frequent.sh \
        && ./clean.sh

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./shell.sh \
        && ./clean.sh \
        && rm -rf *

