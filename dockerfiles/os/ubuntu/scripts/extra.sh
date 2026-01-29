#!/usr/bin/env bash

set -eo pipefail

export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1
export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）

function install_brew() {
    apt-get update -y
    apt-get install -y build-essential procps curl file git

    touch /.dockerenv
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    cp internal/brew/brew.sh /etc/profile.d/brew.sh

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew analytics off
    brew install gcc
}

function install_brew_tools() {
    brew install skopeo uv duckdb rclone glab gh opencode mise promptfoo tmux
    brew install --cask claude-code

    brew autoremove
    brew cleanup --prune=all
    brew doctor
}

function configure_tools() {
    function config_duckdb() {
        cp internal/duckdb/duckdbrc /root/.duckdbrc
    }

    function config_mise() {
        cp internal/mise/mise.yaml /root/.config/mise/config.toml
        cp -r internal/mise/tasks /root/.config/mise
        chmod +x -R /root/.config/mise/tasks
        cp internal/mise/mise.sh /etc/profile.d/mise.sh
    }

    config_duckdb
    config_mise
}

function main() {
    install_brew
    install_brew_tools
    configure_tools
}

main
