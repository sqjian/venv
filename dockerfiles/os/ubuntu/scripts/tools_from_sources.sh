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
    apt-get update -y
}

function install_cmake() {
    install_cmake_from_source() {
        apt-get update -y
        apt-get install -y wget gzip curl git openssl libssl-dev coreutils gcc g++

        check_command clang
        check_command lldb
        check_command lld

        local Directory=$(mktemp -d /tmp/cmake.XXXXXX)

        curl -so- https://cmake.org/files/v3.26/cmake-3.26.4.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -

        pushd "${Directory}"
        ./bootstrap --prefix=/usr/local
        make -j "$(nproc)"
        make install
        popd

        rm -rf "${Directory}"

    }

    install_cmake_from_ppa() {
        apt-get update -y
        apt-get install -y wget

        local Directory=$(mktemp -d /tmp/cmake.XXXXXX)
        pushd "${Directory}"
        wget https://apt.kitware.com/kitware-archive.sh
        chmod +x kitware-archive.sh && ./kitware-archive.sh
        apt-get install -y cmake
        popd
        rm -rf "${Directory}"

    }

    local version
    version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
    version=${version%%.*} # get the main version number

    if [ "$version" -ge 20 ]; then
        install_cmake_from_ppa
    else
        install_cmake_from_source
    fi

    wget -qO /usr/local/bin/ninja.gz https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip
    gunzip -f /usr/local/bin/ninja.gz
    chmod a+x /usr/local/bin/ninja
    ninja --version

    cmake --version
    which cmake
}

function install_python() {
    _install_conda() {
        apt-get update -y
        apt-get install -y wget

        local Directory=$(mktemp -d /tmp/conda.XXXXXX)
        pushd "${Directory}"
        wget -O 'Miniconda3-latest-Linux-x86_64.sh' https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash Miniconda3-latest-Linux-x86_64.sh -b -p /usr/local/conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        popd
        rm -rf "${Directory}"
    }

    _install_python() {
        source /usr/local/conda/bin/activate
        conda create -y -n python python=3.11.4
    }

    _install_conda
    _install_python
}

function main() {
    update
    install_cmake
    install_python
}

main
