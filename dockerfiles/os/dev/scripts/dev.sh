#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

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

function install_git() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        curl

    add-apt-repository -y ppa:git-core/ppa
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-get update -y
    apt-get install -y git git-lfs
}

function main() {
    install_git
}

main
