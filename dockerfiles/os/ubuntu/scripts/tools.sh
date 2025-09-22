#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

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
        gawk \
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
        sshpass \
        texinfo \
        lrzsz \
        aria2 \
        p7zip-full p7zip-rar \
        telnet

    # Development Tools
    apt-get install -y \
        checkinstall \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libbz2-dev \
        libffi-dev \
        libxml2-dev \
        liblzma-dev \
        libgoogle-perftools-dev \
        nghttp2 libnghttp2-dev \
        gcc g++ gdb cmake

    # System Libraries
    apt-get install -y \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libaio-dev \
        libssl-dev

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

function install_fish() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:fish-shell/release-3
    apt-get update -y
    apt-get install -y fish
}

function install_zsh() {
    apt-get update -y
    apt-get install -y zsh wget git sed

    local Directory
    Directory=$(mktemp -d /tmp/zsh.XXXXXX)

    pushd "${Directory}"
    rm -rf /root/.oh-my-zsh /root/.zshrc
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="ys"/' /root/.zshrc
    popd
    rm -rf "${Directory}"
}

function install_go() {
    _install_go() {
        apt-get update -y
        apt-get install -y \
            curl \
            git \
            graphviz \
            jq
        local _go_ver
        _go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
        local _go_os=linux
        local _go_arch

        # 检测系统架构并设置 _go_arch 变量
        case $(uname -m) in
        x86_64)
            _go_arch="amd64"
            ;;
        aarch64)
            _go_arch="arm64"
            ;;
        *)
            echo "Unsupported architecture"
            return 1
            ;;
        esac

        local _go_url="https://dl.google.com/go/${_go_ver}.${_go_os}-${_go_arch}.tar.gz"
        local _go_dir="/usr/local"
        if [ -d "${_go_dir}/go" ]; then
            rm -rf "${_go_dir}/go"
        fi
        curl --retry 3 -L -o go.tgz "$_go_url"
        tar xzf go.tgz -C "${_go_dir}"
        rm -f go.tgz
        echo "Go ${_go_ver} installed successfully."

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
    }

    _update_alternatives() {

        update-alternatives --remove-all go || true
        update-alternatives --remove-all gofmt || true

        update-alternatives --install /usr/local/bin/go go "/usr/local/go/bin/go" 1 \
            --slave /usr/local/bin/gofmt gofmt "/usr/local/go/bin/gofmt" || (echo "set go alternatives failed" && exit 1)

        update-alternatives --auto go
        update-alternatives --display go

        go version
        which go
    }

    _install_go
    _update_alternatives

}

function install_vim() {
    apt-get update -y
    apt-get install -y vim

    local Directory
    Directory=$(mktemp -d /tmp/vim.XXXXXX)

    pushd "${Directory}"
    git clone --depth=1 https://github.com/sqjian/venv.git
    git clone --depth=1 https://github.com/amix/vimrc.git
    cat vimrc/vimrcs/basic.vim >/root/.vimrc
    cat venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc
    popd

    rm -rf "${Directory}"

    tee /etc/profile.d/vim.sh <<'EOF'
# shellcheck shell=sh

export EDITOR=$(which vim)
EOF

}

function install_upx() {
    _install_upx() {
        apt-get update -y
        apt-get install -y curl xz-utils

        local Directory
        Directory=$(mktemp -d /tmp/upx.XXXXXX)

        pushd "${Directory}"

        if [ "$(uname -m)" = "x86_64" ]; then
            curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v5.0.1/upx-5.0.1-amd64_linux.tar.xz'
        elif [ "$(uname -m)" = "aarch64" ]; then
            curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v5.0.1/upx-5.0.1-arm64_linux.tar.xz'
        else
            echo "Unsupported architecture: $(uname -m)"
            exit 1
        fi

        mkdir -p /usr/local/upx
        tar -xJf upx.tar.xz --strip-components=1 -C /usr/local/upx
        popd

        rm -rf "${Directory}"
    }

    _update_alternatives() {

        rm -rf /usr/local/bin/upx || true

        update-alternatives --remove-all upx || true
        update-alternatives --install /usr/local/bin/upx upx "/usr/local/upx/upx" 1 || (echo "set upx alternatives failed" && exit 1)
        update-alternatives --auto upx
        update-alternatives --display upx

        upx --version
        which upx
    }

    _install_upx
    _update_alternatives
}

function install_locales() {
    apt-get update -y
    apt-get install -y locales
    locale-gen zh_CN.UTF-8
    tee /etc/profile.d/lang.sh <<'EOF'
export LC_ALL=zh_CN.utf-8
export LANG=zh_CN.utf-8
EOF
}

function install_tmux() {
    _install_tmux_bin() {
        echo "installing tmux..."
        apt-get update -y
        apt-get install -y tmux
    }

    _clean_old_tmux_cfg() {
        local _old_tmux_cfg_dir=$1
        rm -rf "${_old_tmux_cfg_dir}"/.tmux*
    }

    _install_gpakosz_tmux_config() {
        check_command git
        local _gpakosz_tmux_config_dir=$1
        git clone --depth=1 https://github.com/gpakosz/.tmux.git "${_gpakosz_tmux_config_dir}"/.tmux
        ln -s "${_gpakosz_tmux_config_dir}/.tmux/.tmux.conf" "${_gpakosz_tmux_config_dir}/.tmux.conf"
        cp "${_gpakosz_tmux_config_dir}"/.tmux/.tmux.conf.local "${_gpakosz_tmux_config_dir}"/.tmux.conf.local
    }

    _install_custom_tmux_config() {

        local _custom_tmux_config_dir=$1

        sed -i '/set -g prefix2 C-a/d' "${_custom_tmux_config_dir}"/.tmux.conf
        sed -i '/bind C-a send-prefix -2/d' "${_custom_tmux_config_dir}"/.tmux.conf

        tee -a "${_custom_tmux_config_dir}"/.tmux.conf.local >/dev/null <<'EOF'
# 基础设置
set-option -g default-command "fish"
set-window-option -g clock-mode-style 24 # 24小时显示方式

# 绑定hjkl键为面板切换的上下左右键
bind -r k select-pane -U # 绑定k为↑,选择上面板
bind -r j select-pane -D # 绑定j为↓,选择下面板
bind -r h select-pane -L # 绑定h为←,选择左面板
bind -r l select-pane -R # 绑定l为→,选择右面板

# 绑定Ctrl+hjkl键为面板上下左右调整边缘的快捷指令
bind -r ^k resizep -U 5 # 绑定Ctrl+k为往↑调整面板边缘5个单元格
bind -r ^j resizep -D 5 # 绑定Ctrl+j为往↓调整面板边缘5个单元格
bind -r ^h resizep -L 5 # 绑定Ctrl+h为往←调整面板边缘5个单元格
bind -r ^l resizep -R 5 # 绑定Ctrl+l为往→调整面板边缘5个单元格

# 交换面板
bind ^u swapp -U # 与上面板交换
bind ^d swapp -D # 与下面板交换

# 切换窗口
bind -r C-p previous-window # select previous window
bind -r C-n next-window     # select next window
EOF
    }

    local _tmux_root_dir="/root"

    _install_tmux_bin
    _clean_old_tmux_cfg ${_tmux_root_dir}
    _install_gpakosz_tmux_config ${_tmux_root_dir}
    _install_custom_tmux_config ${_tmux_root_dir}
}

function install_docker_cli() {
    check_command curl

    apt-get update -y
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    # 添加 Docker 仓库
    # `arch=$(dpkg --print-architecture)` 自动设置正确的架构
    add-apt-repository -y \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # 安装 Docker CLI
    apt-get update -y && apt-get install -y docker-ce-cli

    # 检查 Ubuntu 版本并安装 skopeo
    ubuntu_version=$(lsb_release -rs)
    if dpkg --compare-versions "${ubuntu_version}" ge "22.04"; then
        apt-get install -y skopeo
    fi
}

function install_conda() {
    _install_conda() {
        apt-get update -y
        apt-get install -y wget

        local temp_dir
        temp_dir=$(mktemp -d /tmp/conda.XXXXXX)

        pushd "${temp_dir}" || exit 1

        case "$(uname -m)" in
        x86_64)
            conda_url=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
            ;;
        aarch64)
            conda_url=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
            ;;
        *)
            echo "不支持的架构: $(uname -m)"
            return 1
            ;;
        esac

        wget -q -O Miniconda3-latest.sh "$conda_url"
        bash Miniconda3-latest.sh -b -p /usr/local/conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        /usr/local/conda/bin/conda config --set pip_interop_enabled True

        /usr/local/conda/bin/conda clean -a -y

        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_tools() {
        source /usr/local/conda/bin/activate
        conda activate base

        pip install pipx
        pipx ensurepath

        pipx install 'dool' 'dvc[all]'
    }

    _install_conda
    _install_tools
}

function install_uv() {
    _install_uv() {
        apt-get update -y
        apt-get install -y curl

        curl -LsSf https://astral.sh/uv/install.sh | sh

        /root/.local/bin/uv self version
        /root/.local/bin/uv python install 3.11
        /root/.local/bin/uv python install 3.12
        /root/.local/bin/uv python install 3.13
    }

    _install_uv
}

function install_duckdb() {
    _install_duckdb() {
        check_command curl
        curl https://install.duckdb.org | sh
    }
    _install_config() {
        tee /root/.duckdbrc <<EOF
-- 会话和性能配置
SET enable_progress_bar = true;
SET preserve_insertion_order = false;

-- 数据处理和排序配置
SET default_null_order = 'nulls_last';
SET enable_object_cache = true;
SET checkpoint_threshold = '1GB';

-- 用户体验优化
.nullvalue 'NULL'

-- 输出显示配置
.changes on
.rows
.mode duckbox
.timer on
.header on
EOF
    }

    _update_alternatives() {
        update-alternatives --remove-all duckdb || true
        update-alternatives --install /usr/local/bin/duckdb duckdb "/root/.duckdb/cli/latest/duckdb" 1 || (echo "set duckdb alternatives failed" && exit 1)
        update-alternatives --auto duckdb
        update-alternatives --display duckdb
        duckdb --version
        which duckdb
    }

    _install_duckdb
    _install_config
    _update_alternatives
}

function install_rclone() {
    check_command curl
    check_command unzip
    
    local rclone_arch
    case "$(uname -m)" in
    x86_64)
        rclone_arch="amd64"
        ;;
    aarch64)
        rclone_arch="arm64"
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)"
        return 1
        ;;
    esac
    
    curl -O "https://downloads.rclone.org/rclone-current-linux-${rclone_arch}.zip"
    unzip -jo "rclone-current-linux-${rclone_arch}.zip" -d rclone_dwn
    cp rclone_dwn/rclone /usr/bin/
    chmod 755 /usr/bin/rclone
    rm -rf rclone*
}

function install_code_assistant() {
    _setup_fnm_env() {
        export FNM_PATH="/root/.local/share/fnm"
        export PATH="$FNM_PATH:$PATH"
        eval "$(fnm env)"
    }

    _install_node() {
        check_command curl
        check_command unzip
        curl -o- https://fnm.vercel.app/install | bash

        _setup_fnm_env

        fnm install 22
        node -v
        npm -v
    }

    _install_code_assistant() {
        _setup_fnm_env

        npm install -g @anthropic-ai/claude-code
        npm install -g @musistudio/claude-code-router
        npm install -g @dashscope-js/claude-code-config
    }

    _install_node
    _install_code_assistant
}

function main() {
    update
    install_locales
    install_tools
    install_git
    install_zsh
    install_fish
    install_upx
    install_vim
    install_tmux
    install_go
    install_conda
    install_uv
    install_docker_cli
    install_duckdb
    install_rclone
    install_code_assistant
}

main
