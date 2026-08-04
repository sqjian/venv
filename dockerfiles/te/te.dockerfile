ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.cargo/bin:/root/.local/bin:$PATH"

SHELL ["/bin/bash", "-l", "-c"]

COPY <<EOF /root/.curlrc
--tlsv1.3
--tls-max 1.3
EOF

WORKDIR /workspace

COPY scripts .

RUN set -ex \
    && find . -type f -name "*.sh" -exec chmod +x {} \;

RUN set -ex \
    && ./debug.sh
