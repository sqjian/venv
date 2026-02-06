ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

WORKDIR /workspaces

COPY scripts scripts

RUN --mount=type=secret,id=gh_token set -ex  \
    && find . -type f -name "*.sh" -exec chmod +x {} \; \
    && ./scripts/main.sh \
    && rm -rf /scripts