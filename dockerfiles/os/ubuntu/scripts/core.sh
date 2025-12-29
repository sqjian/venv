#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_apt_fast() {
    echo "Installing apt-fast..."
    apt-get update -y
    apt-get install -y software-properties-common aria2

    add-apt-repository -y ppa:apt-fast/stable
    apt-get update -y
    apt-get install -y apt-fast

    echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
    echo debconf apt-fast/dlflag boolean true | debconf-set-selections
    echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
}

function install_tools() {
    apt-fast update -y
    apt-fast install -y \
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

    apt-fast install -y \
        build-essential \
        checkinstall \
        gdb \
        cmake

    apt-fast install -y \
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

    apt-fast install -y \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libaio-dev

    apt-fast install -y \
        vim \
        tmux

}

function install_locales() {
    apt-fast update -y
    apt-fast install -y locales
    locale-gen zh_CN.UTF-8

    tee /etc/profile.d/lang.sh <<'EOF'
export LC_ALL=zh_CN.utf-8
export LANG=zh_CN.utf-8
EOF
}

function install_extra_tools() {
    apt-fast update -y
    apt-fast install -y \
        libsndfile1 \
        libsndfile1-dev \
        libflac-dev

    apt-fast install -y \
        libjpeg-turbo8-dev \
        zlib1g-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libharfbuzz-dev \
        libfribidi-dev

    apt-fast install -y \
        tcl \
        tcl-dev \
        tk-dev \
        dejagnu \
        libncursesw5-dev \
        libmpich-dev
}

function install_git() {
    apt-fast update -y
    apt-fast remove -y git git-lfs || true
    apt-fast install -y \
        curl \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-fast update -y
    apt-fast install -y git git-lfs
}
function install_shell() {
    function install_zsh() {
        apt-fast update -y
        apt-fast install -y zsh wget git sed

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
        apt-fast update -y
        apt-fast install -y \
            software-properties-common \
            apt-transport-https \
            ca-certificates \
            gnupg-agent

        add-apt-repository -y ppa:fish-shell/release-3
        apt-fast update -y
        apt-fast install -y fish
    }

    install_zsh
    install_fish
}
function install_docker_cli() {
    apt-fast update -y
    apt-fast install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    add-apt-repository -y \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    apt-fast update -y
    apt-fast install -y docker-ce-cli
}
function main() {
    install_apt_fast
    install_locales
    install_shell
    install_git
    install_tools
    install_extra_tools
    install_docker_cli
}

main
