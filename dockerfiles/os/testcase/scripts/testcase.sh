#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# shellcheck disable=SC2155

function install_pkg() {
    _install_step1() {
        local Directory=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${Directory}"
        echo "pkg.step1."
        popd
        rm -rf "${Directory}"
    }

    _install_step2() {
        local Directory=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${Directory}"
        echo "pkg.stdp2."
        popd
        rm -rf "${Directory}"
    }

    _install_step1
    _install_step2
}

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

function install_tools() {
    # base tools
    apt-get install -y \
        binutils \
        inetutils-ping \
        iproute2 \
        telnet \
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
        makeself \
        socat \
        zip unzip \
        fish \
        sshpass \
        texinfo \
        lrzsz \
        aria2 \
        p7zip-full p7zip-rar \
        telnet
}

function install_test() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent
}


update
install_test
install_tools