#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# shellcheck disable=SC2155

function install_pkg() {
    _install_step1() {
        local temp_dir=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.step1."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step2() {
        local temp_dir=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.stdp2."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step1
    _install_step2
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

install_python
