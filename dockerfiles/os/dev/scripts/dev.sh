#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_rust_tools() {
    apt-get update -y
    apt-get install -y libjemalloc-dev curl make g++ gcc

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    cargo install hyperfine # A command-line benchmarking tool
    cargo install ripgrep   # A modern grep command alternative
}

install_rust_tools
