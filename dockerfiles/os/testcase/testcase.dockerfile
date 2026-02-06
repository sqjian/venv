ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

SHELL ["/bin/bash", "-l", "-c"]
WORKDIR /workspace

COPY scripts .

RUN set -ex \
    && find . -type f -name "*.sh" -exec chmod +x {} \;

# RUN set -ex \
#     && ./testcase.sh
