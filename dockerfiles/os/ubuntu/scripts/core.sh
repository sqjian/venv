#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_locales() {
    apt-get update -y
    apt-get install -y locales
    locale-gen zh_CN.UTF-8

    tee /etc/profile.d/lang.sh <<'EOF'
export LC_ALL=zh_CN.utf-8
export LANG=zh_CN.utf-8
EOF
}

function install_fish() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:fish-shell/release-3
    apt-get update -y
    apt-get install -y fish
}

function install_git() {
    apt-get update -y
    apt-get remove -y git git-lfs || true
    apt-get install -y \
        curl \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-get update -y
    apt-get install -y git git-lfs

    git config --global user.email shengqi.jian@gmail.com
    git config --global user.name sqjian
}

function install_tools() {
    apt-get update -y
    apt-get install -y \
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
        vim \
        tmux \
        build-essential \
        checkinstall \
        gdb \
        cmake
}

function install_docker_cli() {
    apt-get update -y
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    add-apt-repository -y \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    apt-get update -y
    apt-get install -y docker-ce-cli
}

function install_apt_fast() {
    apt-get update -y
    apt-get install -y software-properties-common aria2

    add-apt-repository -y ppa:apt-fast/stable
    apt-get update -y
    apt-get install -y apt-fast

    echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
    echo debconf apt-fast/dlflag boolean true | debconf-set-selections
    echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
}

function main() {
    install_locales
    install_fish
    install_git
    install_tools
    install_docker_cli
    install_apt_fast
}

main
