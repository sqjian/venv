FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y &&\
    apt-get install -y \
            gcc \
            g++ \
            gperf \
            bison \
            flex \
            texinfo \
            help2man \
            make \
            libncurses5-dev \
            python3-dev \
            autoconf \
            automake \
            libtool \
            libtool-bin \
            gawk \
            wget \
            bzip2 \
            xz-utils \
            unzip \
            patch \
            rsync \
            meson \
            vim \
            ninja-build

ARG CROSSTOOL_NG_VERSION=1.26.0
ARG CROSSTOOL_NG_PREFIX=/opt/crosstool-ng

# Create a non-root user and set up the environment
RUN useradd -ms /bin/bash builder && \
    mkdir -p ${CROSSTOOL_NG_PREFIX} && \
    chown builder:builder ${CROSSTOOL_NG_PREFIX}

USER builder
WORKDIR /home/builder

RUN wget -q http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${CROSSTOOL_NG_VERSION}.tar.bz2 && \
    tar -xjf crosstool-ng-${CROSSTOOL_NG_VERSION}.tar.bz2 && \
    cd crosstool-ng-${CROSSTOOL_NG_VERSION} && \
    ./configure --prefix=${CROSSTOOL_NG_PREFIX} && \
    make -j$(nproc) && \
    make install && \
    rm -rf ../crosstool-ng-${CROSSTOOL_NG_VERSION}.tar.bz2 && \
    cd .. && \
    rm -rf crosstool-ng-${CROSSTOOL_NG_VERSION}

ENV PATH="${CROSSTOOL_NG_PREFIX}/bin:${PATH}"

# Create a build directory with proper permissions
RUN mkdir -p /home/builder/build
WORKDIR /home/builder/build
