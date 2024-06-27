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

        local Directory
        Directory=$(mktemp -d /tmp/cmake.XXXXXX)

        curl -so- https://cmake.org/files/v3.29/cmake-3.29.5.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -

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

        local Directory
        Directory=$(mktemp -d /tmp/cmake.XXXXXX)
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

    local arch
    arch=$(uname -m)

    local ninja_url
    case "$arch" in
    x86_64)
        ninja_url="https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip"
        ;;
    aarch64)
        ninja_url="https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux-aarch64.zip"
        ;;
    *)
        echo "Unsupported architecture: $arch"
        exit 1
        ;;
    esac

    wget -qO /usr/local/bin/ninja.zip "$ninja_url"
    unzip -o /usr/local/bin/ninja.zip -d /usr/local/bin/
    rm /usr/local/bin/ninja.zip
    chmod a+x /usr/local/bin/ninja

    ninja --version
    cmake --version
    which cmake
}

function install_python() {
    _install_conda() {
        apt-get update -y
        apt-get install -y wget

        local Directory
        Directory=$(mktemp -d /tmp/conda.XXXXXX)

        pushd "${Directory}"

        ARCH=$(uname -m)
        if [ "$ARCH" = "x86_64" ]; then
            CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        elif [ "$ARCH" = "aarch64" ]; then
            CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
        else
            echo "不支持的架构: $ARCH"
            return 1
        fi

        wget -O 'Miniconda3-latest.sh' $CONDA_URL
        bash Miniconda3-latest.sh -b -p /usr/local/conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        /usr/local/conda/bin/conda config --set pip_interop_enabled True

        popd
        rm -rf "${Directory}"
    }

    _install_tools() {
        source /usr/local/conda/bin/activate
        conda activate base

        pip install pipx
        pipx ensurepath

        pipx install poetry
        ~/.local/bin/poetry config virtualenvs.in-project true
        ~/.local/bin/poetry config --list
    }

    _install_conda
    _install_tools
}

function main() {
    update
    install_cmake
    install_python
}

main
