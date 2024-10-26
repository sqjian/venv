FROM nvcr.io/nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /lab

COPY scripts .

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools_from_precompiled.sh \
        && ./clean.sh

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./tools_from_sources.sh \
        && ./clean.sh 

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./extra.sh \
        && ./clean.sh 

RUN set -eux \
        && find . -type f -name "*.sh" -exec chmod +x {} \; \
        && ./shell.sh \
        && ./clean.sh \
        && rm -rf *
