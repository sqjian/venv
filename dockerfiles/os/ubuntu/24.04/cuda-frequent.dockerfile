FROM sqjian/venv:ubuntu24.04-cuda12.8-stable

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
