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
    cp internal/git/git.sh /etc/profile.d/git.sh
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
        bubblewrap \
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

function configure_tools() {
    function config_vim() {
        curl -fLo /root/.vimrc https://raw.githubusercontent.com/amix/vimrc/refs/heads/master/vimrcs/basic.vim
        cat internal/vim/vimrc >>/root/.vimrc
        cp internal/vim/vim.sh /etc/profile.d/vim.sh
    }
    function config_tmux() {
        cp internal/tmux/tmux.conf /root/.tmux.conf
    }

    config_vim
    config_tmux
}

function main() {
    install_locales
    install_fish
    install_git
    install_tools
    install_docker_cli
    configure_tools
}

main
