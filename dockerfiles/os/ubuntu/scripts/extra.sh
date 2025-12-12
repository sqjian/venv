#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1

function install_brew() {
    apt-get update -y
    apt-get install -y build-essential procps curl file git

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    tee /etc/profile.d/brew.sh <<'EOF'
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export HOMEBREW_NO_ANALYTICS=1
EOF

    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew analytics off
    brew install gcc
}

function install_brew_tools() {
    brew install vim
    brew install tmux
    brew install skopeo
    brew install uv
    brew install duckdb
    brew install rclone
    brew install openjdk
    brew install graphviz
}

function install_docker_cli() {
    apt-get update -y
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    add-apt-repository -y \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    apt-get update -y
    apt-get install -y docker-ce-cli
}

function install_code_assistant() {
    # Install fnm
    curl -o- https://fnm.vercel.app/install | bash
    source /root/.bashrc

    # Configure environment variables
    export FNM_PATH="/root/.local/share/fnm"
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env --shell bash)"

    # Verify and install Node.js
    if ! command -v fnm >/dev/null 2>&1; then
        echo "Error: fnm installation failed"
        exit 1
    fi

    fnm install 22
    fnm use 22

    if ! command -v node >/dev/null 2>&1; then
        echo "Error: node installation failed"
        exit 1
    fi

    node -v
    npm -v

    # Install code assistant tools
    npm install -g @anthropic-ai/claude-code
    npm install -g @musistudio/claude-code-router
    npm install -g @dashscope-js/claude-code-config
}

function install_plantuml() {
    apt-get update -y
    apt-get install -y \
        fontconfig \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-color-emoji

    fc-cache -fv
    fc-list :lang=zh

    local plantuml_dir="/opt/plantuml"
    mkdir -p "${plantuml_dir}"
    curl -o "${plantuml_dir}/plantuml.jar" -L \
        'https://github.com/plantuml/plantuml/releases/download/v1.2025.10/plantuml-1.2025.10.jar'
    java -jar "${plantuml_dir}/plantuml.jar" --version
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

    function config_tmux() {
        local temp_dir
        local tmux_root_dir="/root"

        temp_dir=$(mktemp -d /tmp/tmux.XXXXXX)

        pushd "${temp_dir}" || exit 1

        # Clean up old configurations
        rm -rf "${tmux_root_dir}"/.tmux*

        # Install gpakosz tmux configuration
        git clone --depth=1 https://github.com/gpakosz/.tmux.git "${tmux_root_dir}/.tmux"
        ln -s "${tmux_root_dir}/.tmux/.tmux.conf" "${tmux_root_dir}/.tmux.conf"
        cp "${tmux_root_dir}/.tmux/.tmux.conf.local" "${tmux_root_dir}/.tmux.conf.local"

        # Custom configuration
        sed -i '/set -g prefix2 C-a/d' "${tmux_root_dir}/.tmux.conf"
        sed -i '/bind C-a send-prefix -2/d' "${tmux_root_dir}/.tmux.conf"

        git clone --depth=1 https://github.com/sqjian/venv.git
        cat venv/dockerfiles/os/ubuntu/scripts/internal/tmux.conf >>${tmux_root_dir}/.tmux.conf.local

        popd || exit 1

        rm -rf "${temp_dir}"
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
    config_tmux
    config_duckdb
}

function main() {
    install_brew
    install_brew_tools
    configure_tools
    install_docker_cli
    install_code_assistant
    install_plantuml
}

main
