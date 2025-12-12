FROM nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspaces

COPY scripts .

RUN set -ex \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./core.sh \
        && ./clean.sh