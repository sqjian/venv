FROM sqjian/venv:ubuntu24.04-stable

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools-frequent.sh \
        && ./clean.sh \
        && rm -rf *