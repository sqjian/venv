#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1

function install_brew() {
    apt-get update -y
    apt-get install -y build-essential procps curl file git

    touch /.dockerenv
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

    brew autoremove
    brew cleanup --prune=all
    brew doctor
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

function install_programming_languages() {
    function install_go() {
        apt-get update -y
        apt-get install -y curl git jq

        # Get latest version and architecture information
        local go_ver
        go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')

        local go_arch
        case $(uname -m) in
        x86_64) go_arch="amd64" ;;
        aarch64) go_arch="arm64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            return 1
            ;;
        esac

        # Download and install
        local go_url="https://dl.google.com/go/${go_ver}.linux-${go_arch}.tar.gz"
        local go_dir="/usr/local"

        rm -rf "${go_dir}/go"
        curl --retry 3 -L -o /tmp/go.tgz "$go_url"
        tar xzf /tmp/go.tgz -C "${go_dir}"
        rm -f /tmp/go.tgz

        echo "Go ${go_ver} installed successfully."

        # Configure environment variables
        tee /etc/profile.d/go.sh <<'EOF'
# shellcheck shell=sh

export GOROOT=/usr/local/go
export GOPATH=${GOROOT}/mylib
export GOPROXY=https://goproxy.cn
export GO111MODULE=on

go_bin_path=${GOPATH}/bin:${GOROOT}/bin
if [ -n "${PATH##*${go_bin_path}}" -a -n "${PATH##*${go_bin_path}:*}" ]; then
    export PATH=${PATH}:${go_bin_path}
fi
EOF

        # Update alternatives
        update-alternatives --remove-all go 2>/dev/null || true
        update-alternatives --remove-all gofmt 2>/dev/null || true

        update-alternatives --install /usr/local/bin/go go "/usr/local/go/bin/go" 1 \
            --slave /usr/local/bin/gofmt gofmt "/usr/local/go/bin/gofmt"

        update-alternatives --auto go
        update-alternatives --display go

        /usr/local/go/bin/go version
    }

    function install_conda() {
        apt-get update -y
        apt-get install -y wget

        # Determine download URL
        local conda_url
        case "$(uname -m)" in
        x86_64) conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" ;;
        aarch64) conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh" ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            return 1
            ;;
        esac

        # Download and install
        local temp_dir
        temp_dir=$(mktemp -d /tmp/conda.XXXXXX)

        wget -q -O "${temp_dir}/Miniconda3-latest.sh" "$conda_url"
        bash "${temp_dir}/Miniconda3-latest.sh" -b -p /usr/local/conda
        rm -rf "${temp_dir}"

        # Configure conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        /usr/local/conda/bin/conda config --set pip_interop_enabled True
        /usr/local/conda/bin/conda clean -a -y
    }

    install_go
    install_conda
}

function main() {
    install_brew
    install_brew_tools
    configure_tools
    install_code_assistant
    install_plantuml
    install_programming_languages
}

main
