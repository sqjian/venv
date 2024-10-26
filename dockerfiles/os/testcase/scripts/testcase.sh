#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# shellcheck disable=SC2155

function install_pkg() {
    _install_step1() {
        local Directory=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${Directory}"
        echo "pkg.step1."
        popd
        rm -rf "${Directory}"
    }

    _install_step2() {
        local Directory=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${Directory}"
        echo "pkg.stdp2."
        popd
        rm -rf "${Directory}"
    }

    _install_step1
    _install_step2
}

function install_python() {
    _install_conda() {
        apt-get update -y
        apt-get install -y wget

        local Directory
        Directory=$(mktemp -d /tmp/conda.XXXXXX)

        pushd "${Directory}"

        ARCH=$(uname -m)
        if [ "$ARCH" = "x86_64" ]; then
            CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        elif [ "$ARCH" = "aarch64" ]; then
            CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
        else
            echo "不支持的架构: $ARCH"
            return 1
        fi

        wget -O 'Miniconda3-latest.sh' $CONDA_URL
        bash Miniconda3-latest.sh -b -p /usr/local/conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        /usr/local/conda/bin/conda config --set pip_interop_enabled True

        popd
        rm -rf "${Directory}"
    }

    _install_tools() {
        source /usr/local/conda/bin/activate
        conda activate base

        pip install pipx
        pipx ensurepath

        pipx install poetry
        ~/.local/bin/poetry config virtualenvs.in-project true
        ~/.local/bin/poetry config --list
    }

    _install_conda
    _install_tools
}
