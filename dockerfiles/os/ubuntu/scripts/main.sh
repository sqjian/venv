#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

SCRIPT_DIR="./internal"

function clean() {
    echo "autoremoving packages and cleaning apt data"
    apt-get -y autoremove
    apt-get -y clean

    echo "remove /var/lib/apt/lists/"
    rm -rf /var/lib/apt/lists/*

    echo "remove /tmp/"
    rm -rf /tmp/*
}

function install_all() {
    apt-get update -y

    # Infrequently updated tools
    # === 系统基础 ===
    "${SCRIPT_DIR}/locales/install.sh"
    "${SCRIPT_DIR}/tools/install.sh"
    "${SCRIPT_DIR}/ninja/install.sh"

    # === Git ===
    "${SCRIPT_DIR}/git/install.sh"
    "${SCRIPT_DIR}/gh/install.sh"
    "${SCRIPT_DIR}/glab/install.sh"

    # === 终端环境 ===
    "${SCRIPT_DIR}/fish/install.sh"
    "${SCRIPT_DIR}/brew/install.sh"
    "${SCRIPT_DIR}/mise/install.sh"
    "${SCRIPT_DIR}/uv/install.sh"
    "${SCRIPT_DIR}/tmux/install.sh"
    "${SCRIPT_DIR}/vim/install.sh"
    "${SCRIPT_DIR}/fzf/install.sh"
    "${SCRIPT_DIR}/ripgrep/install.sh"
    "${SCRIPT_DIR}/fd/install.sh"
    "${SCRIPT_DIR}/starship/install.sh"

    # === 容器、存储与数据 ===
    "${SCRIPT_DIR}/docker/install.sh"
    "${SCRIPT_DIR}/rclone/install.sh"
    "${SCRIPT_DIR}/duckdb/install.sh"

    # Frequently updated tools
    # === AI 开发工具（变化频繁，放最后利于缓存）===
    # "${SCRIPT_DIR}/promptfoo/install.sh"
    # "${SCRIPT_DIR}/claudecode/install.sh"
    # "${SCRIPT_DIR}/opencode/install.sh"
}

install_all
clean
