#!/usr/bin/env bash

set -exo pipefail

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

    tee /etc/profile.d/brew.sh <<'EOF'
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
EOF

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew analytics off
    brew install gcc
}

function install_brew_tools() {
    brew install vim skopeo uv duckdb rclone glab gh anomalyco/tap/opencode
    brew install --cask claude-code

    brew autoremove
    brew cleanup --prune=all
    brew doctor
}

function configure_tools() {
    function config_vim() {
        local temp_dir
        temp_dir=$(mktemp -d /tmp/vim.XXXXXX)

        pushd "${temp_dir}" || exit 1

        git clone --depth=1 https://github.com/amix/vimrc.git
        cat vimrc/vimrcs/basic.vim >/root/.vimrc

        git clone --depth=1 https://github.com/sqjian/venv.git
        cat venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc

        popd || exit 1

        rm -rf "${temp_dir}"

        tee /etc/profile.d/vim.sh <<'EOF'
# shellcheck shell=sh

export EDITOR=$(which vim)
EOF
    }

    function config_duckdb() {
        local temp_dir

        temp_dir=$(mktemp -d /tmp/duckdb.XXXXXX)

        pushd "${temp_dir}" || exit 1

        git clone --depth=1 https://github.com/sqjian/venv.git
        cat venv/dockerfiles/os/ubuntu/scripts/internal/duckdbrc >>/root/.duckdbrc

        popd || exit 1

        rm -rf "${temp_dir}"
    }
    config_vim
    config_duckdb
}

function main() {
    install_brew
    install_brew_tools
    configure_tools
}

main
