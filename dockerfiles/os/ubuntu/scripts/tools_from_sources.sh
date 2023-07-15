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
    apt-get upgrade -y
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
    build_python_from_source() {
        apt-get update -y
        apt-get install -y \
            make gcc g++ libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev coreutils

        check_command g++
        check_command gcc
        check_command clang

        local Directory=$(mktemp -d /tmp/python.XXXXXX)

        curl -so- https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz | tar --strip-components 1 -C "${Directory}" -xzf -
        pushd "${Directory}"
        ./configure \
            --enable-optimizations \
            --with-lto \
            --with-computed-gotos \
            --with-system-ffi \
            --with-ensurepip=install \
            --prefix=/opt/python

        make -j "$(nproc)"
        make altinstall
        popd
        rm -rf "${Directory}"

        ldconfig

        /opt/python/bin/python3.11 -m pip install --upgrade pip setuptools wheel
    }

    update_alternatives() {

        rm -rf /usr/local/bin/{python,pip,pydoc,python-config} || true

        python="/opt/python/bin/python3.11"
        pip="/opt/python/bin/pip3.11"
        pydoc="/opt/python/bin/pydoc3.11"
        python_config="/opt/python/bin/python3.11-config"

        update-alternatives --remove-all pip || true
        update-alternatives --remove-all python || true
        update-alternatives --remove-all pydoc || true
        update-alternatives --remove-all python-config || true

        update-alternatives --install /usr/local/bin/python python "${python}" 1 \
            --slave /usr/local/bin/pip pip "${pip}" \
            --slave /usr/local/bin/pydoc pydoc "${pydoc}" \
            --slave /usr/local/bin/python-config python-config "${python_config}" || (echo "set python alternatives failed" && exit 1)

        update-alternatives --auto python
        update-alternatives --display python

        python --version
        which python
    }

    build_python_from_source
    update_alternatives

}
function install_curl() {
    apt-get update -y
    apt-get install -y curl git openssl libssl-dev coreutils libtool libtool-bin

    check_command g++
    check_command gcc

    local Directory=$(mktemp -d /tmp/curl.XXXXXX)

    curl -so- https://curl.se/download/curl-8.1.2.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -
    pushd "${Directory}"
    ./configure --with-openssl --prefix=/usr/local
    make -j "$(nproc)"
    make install
    popd
    rm -rf "${Directory}"

    (libtool --finish /usr/local/lib && ldconfig) || (echo "curl lib set failed" && exit 1)

    ldconfig

    curl --version
    which curl
}

function main() {
    update
    install_curl
    install_cmake
    install_python
}

main
