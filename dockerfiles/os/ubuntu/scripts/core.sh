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

    tee /etc/profile.d/git.sh <<'EOF'
git config --global core.quotepath false
git config --global core.autocrlf false
git config --global core.safecrlf true
git config --global --get user.email > /dev/null || git config --global user.email shengqi.jian@gmail.com
git config --global --get user.name > /dev/null || git config --global user.name sqjian
EOF
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
        local temp_dir
        temp_dir=$(mktemp -d /tmp/vim.XXXXXX)

        pushd "${temp_dir}" || exit 1

        git clone --depth=1 https://github.com/amix/vimrc.git
        cat vimrc/vimrcs/basic.vim >/root/.vimrc

        git clone --depth=1 https://github.com/sqjian/venv.git
        cat venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc

        popd || exit 1

        rm -rf "${temp_dir}"

        tee /etc/profile.d/vim.sh <<'EOF'
export EDITOR=$(which vim)
EOF
    }
    function config_tmux() {
        local temp_dir
        local tmux_root_dir="/root"

        temp_dir=$(mktemp -d /tmp/tmux.XXXXXX)

        pushd "${temp_dir}" || exit 1

        rm -rf "${tmux_root_dir}"/.tmux*

        git clone --depth=1 https://github.com/sqjian/venv.git
        cat venv/dockerfiles/os/ubuntu/scripts/internal/tmux.conf >${tmux_root_dir}/.tmux.conf

        popd || exit 1

        rm -rf "${temp_dir}"
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
