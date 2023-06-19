#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 not found"
        exit 1
    else
        echo "$1 found"
    fi
}

function update() {
    sed -i 's/^# deb/deb/g' /etc/apt/sources.list
    apt-get update -y
    apt-get upgrade -y
}

function install_tools() {
    apt-get update -y

    # base tools
    apt-get install -y \
        binutils \
        software-properties-common \
        inetutils-ping \
        iproute2 \
        gawk \
        unzip \
        dstat \
        wget \
        curl \
        jq \
        rsync \
        dos2unix \
        tree \
        pkg-config \
        libxml2-dev \
        vim \
        protobuf-compiler \
        makeself \
        socat \
        zip \
        unzip \
        fish \
        dumb-init

    # Development Tools
    apt-get install -y \
        checkinstall \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libbz2-dev \
        libffi-dev \
        liblzma-dev

    # System Libraries
    apt-get install -y \
        libgl1-mesa-glx \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libssl-dev

}

function install_tools_from_ppa() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    add-apt-repository -y ppa:fish-shell/release-3
    apt-get update -y
    apt-get install -y git fish
}

function install_rust_tools() {
    apt-get update -y
    apt-get install -y wget curl coreutils

    local Directory=$(mktemp -d /tmp/rust_tools.XXXXXX)

    if [ -d "$Directory" ]; then
        echo "Directory $Directory exists. Removing and recreating it..."
        rm -rf "$Directory"
        mkdir "$Directory"
    else
        echo "Directory $Directory does not exist. Creating it..."
        mkdir -p "$Directory"
    fi

    pushd "${Directory}"
    wget https://github.com/sharkdp/hyperfine/releases/download/v1.16.1/hyperfine_1.16.1_amd64.deb
    dpkg -i hyperfine_1.16.1_amd64.deb || (echo "Hyperfine installation failed" && exit 1)

    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
    dpkg -i ripgrep_13.0.0_amd64.deb || (echo "ripgrep installation failed" && exit 1)

    popd
    rm -rf "${Directory}"
}

function install_go_from_source() {
    apt-get update -y
    apt-get install -y \
        curl \
        git \
        graphviz \
        jq
    local _go_ver
    _go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
    local _go_os=linux
    local _go_arch=amd64
    local _go_url="https://dl.google.com/go/${_go_ver}.${_go_os}-${_go_arch}.tar.gz"
    local _go_dir="/usr/local"
    if [ -d "${_go_dir}/go" ]; then
        rm -rf "${_go_dir}/go"
    fi
    curl --retry 3 -L -o go.tgz "$_go_url"
    tar xzf go.tgz -C "${_go_dir}"
    rm -f go.tgz
    echo "Go ${_go_ver} installed successfully."

    tee /etc/profile.d/go.sh <<'EOF'
# shellcheck shell=sh

export GOROOT=/usr/local/go
export GOPATH=${GOROOT}/mylib
export GOPROXY=https://goproxy.cn
export GO111MODULE=on

go_bin_path=${GOPATH}/bin:${GOROOT}/bin
if [ -n "${PATH##*${go_bin_path}}" -a -n "${PATH##*${go_bin_path}:*}" ]; then
    export PATH=${PATH}:${go_bin_path}
fi
EOF
}

function main() {
    update
    install_tools
    install_tools_from_ppa
    install_rust_tools
    install_go_from_source
}

main
