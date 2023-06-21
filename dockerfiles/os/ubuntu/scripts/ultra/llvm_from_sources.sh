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

function install_llvm_from_source() {
    apt-get update -y
    apt-get install -y wget coreutils
    apt-get install -y bzip2 gzip binutils zip unzip zlib1g-dev

    check_command g++
    check_command gcc
    check_command cmake
    check_command git

    local Directory=$(mktemp -d /tmp/llvm.XXXXXX)

    if [ -d "$Directory" ]; then
        echo "Directory $Directory exists. Removing and recreating it..."
        rm -rf "$Directory"
        mkdir "$Directory"
    else
        echo "Directory $Directory does not exist. Creating it..."
        mkdir -p "$Directory"
    fi

    git clone --depth 1 --branch release/16.x https://github.com/llvm/llvm-project "${Directory}"

    pushd "${Directory}"
    cmake llvm \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_PROJECTS="lld;clang" \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBEDIT=OFF \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_PARALLEL_LINK_JOBS=1 \
        -G Ninja
    ninja install
    popd
    rm -rf "${Directory}"

    apt-get remove -y llvm || true

    ldconfig

    clang --version
    which clang
}

function main() {
    update
    install_llvm_from_source
}

main
