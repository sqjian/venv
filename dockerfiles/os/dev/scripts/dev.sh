#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_rust_tools() {
    install_hyperfine() {
        apt-get update -y
        apt-get install -y wget

        local Directory=$(mktemp -d /tmp/cmake.XXXXXX)

        pushd "${Directory}"
        wget https://github.com/sharkdp/hyperfine/releases/download/v1.16.1/hyperfine_1.16.1_amd64.deb
        dpkg -i hyperfine_1.16.1_amd64.deb
        popd

        rm -rf "${Directory}"
    }

    install_ripgrep() {
        apt-get update -y
        apt-get install -y curl

        local Directory=$(mktemp -d /tmp/ripgrep.XXXXXX)

        pushd "${Directory}"
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
        dpkg -i ripgrep_13.0.0_amd64.deb
        popd

        rm -rf "${Directory}"
    }

    install_hyperfine
    install_ripgrep

}

install_rust_tools
