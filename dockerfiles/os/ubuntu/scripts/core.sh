#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

function update() {
    apt-get update -y
}

function install_tools() {
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
        makeself \
        socat \
        zip unzip \
        sshpass \
        texinfo \
        lrzsz \
        aria2 \
        p7zip-full p7zip-rar \
        ffmpeg \
        sqlite3 \
        psmisc \
        file \
        procps \
        telnet

    apt-get install -y \
        build-essential \
        checkinstall \
        gdb \
        cmake

    apt-get install -y \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libbz2-dev \
        libffi-dev \
        libxml2-dev \
        liblzma-dev \
        libgoogle-perftools-dev \
        nghttp2 \
        libnghttp2-dev

    apt-get install -y \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libaio-dev

    apt-get install -y \
        vim \
        tmux

}

function install_locales() {
    apt-get update -y
    apt-get install -y locales
    locale-gen zh_CN.UTF-8

    tee /etc/profile.d/lang.sh <<'EOF'
export LC_ALL=zh_CN.utf-8
export LANG=zh_CN.utf-8
EOF
}

install_extra_tools() {
    apt-get install -y \
        libsndfile1 \
        libsndfile1-dev \
        libflac-dev

    apt-get install -y \
        libjpeg-turbo8-dev \
        zlib1g-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libharfbuzz-dev \
        libfribidi-dev

    apt-get install -y \
        tcl \
        tcl-dev \
        tk-dev \
        dejagnu \
        libncursesw5-dev \
        libmpich-dev
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
}
function install_shell() {

    function install_zsh() {
        apt-get update -y
        apt-get install -y zsh wget git sed

        local Directory
        Directory=$(mktemp -d /tmp/zsh.XXXXXX)

        pushd "${Directory}" || exit
        rm -rf /root/.oh-my-zsh /root/.zshrc
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh
        cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
        sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="ys"/' /root/.zshrc
        popd || exit
        rm -rf "${Directory}"
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

    install_zsh
    install_fish
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
function main() {
    update
    install_locales
    install_shell
    install_git
    install_tools
    install_docker_cli
}

main
