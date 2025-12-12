FROM sqjian/venv:ubuntu22.04-stable

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./extra.sh \
        && ./clean.sh \
        && rm -rf *
