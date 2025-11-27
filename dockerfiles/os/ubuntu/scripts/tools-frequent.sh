#!/usr/bin/env bash

set -exo pipefail

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
        # Explicitly specify bash shell for fnm env in containerized environments
        eval "$(fnm env --shell bash)"
    }

    _install_node() {
        check_command curl
        check_command unzip
        curl -o- https://fnm.vercel.app/install | bash

        # Source the fnm installation
        source /root/.bashrc

        _setup_fnm_env

        # Verify fnm is available
        if ! command -v fnm >/dev/null 2>&1; then
            echo "Error: fnm installation failed"
            exit 1
        fi

        fnm install 22
        fnm use 22

        # Verify node installation
        if ! command -v node >/dev/null 2>&1; then
            echo "Error: node installation failed"
            exit 1
        fi

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

function install_plantuml() {
    apt-get update -y
    apt-get install -y \
        default-jre \
        graphviz

    local Directory="/opt/plantuml"
    mkdir -p ${Directory}
    curl -o ${Directory}/plantuml.jar -L 'https://github.com/plantuml/plantuml/releases/download/v1.2025.10/plantuml-1.2025.10.jar'
    java -jar ${Directory}/plantuml.jar --version
}

function main() {
    update
    install_git
    install_go
    install_conda
    install_uv
    install_duckdb
    install_rclone
    install_code_assistant
    install_plantuml
}

main
