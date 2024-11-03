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

function install_python() {
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

        pipx install poetry dool dvc
        ~/.local/bin/poetry config virtualenvs.in-project true
        ~/.local/bin/poetry config --list
    }

    _install_conda
    _install_tools
}

function main() {
    update
    install_python
}

main
