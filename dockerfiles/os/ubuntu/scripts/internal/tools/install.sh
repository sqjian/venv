#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends \
    binutils \
    inetutils-ping \
    iproute2 \
    gawk \
    wget \
    curl \
    jq \
    rsync \
    dos2unix \
    tree \
    pkg-config \
    socat \
    zip unzip \
    sshpass \
    texinfo \
    lrzsz \
    aria2 \
    p7zip-full p7zip-rar \
    psmisc \
    file \
    procps \
    telnet \
    build-essential \
    checkinstall \
    bubblewrap \
    cmake \
    ca-certificates \
    python3 \
    make \
    g++ \
    apt-transport-https \
    software-properties-common \
    gnupg-agent
