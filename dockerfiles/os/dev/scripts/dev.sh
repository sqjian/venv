#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# install_cpp 能否正常工作
# 重复定义变量可行吗

function install_cpp() {
    local UBUNTU_VERSION=$(lsb_release -rs)

    echo "installing cpp..."

    apt-get install -y gcc g++ gdb \
        clang lldb lld make cmake automake autoconf \
        systemtap-sdt-dev

    if [ "$UBUNTU_VERSION" == "22.04" ]; then
        apt-get install -y gcc-12 g++-12
    fi

}

function get_version() {
    version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
    version=${version%%.*} # get the main version number
    echo "$version"
}
