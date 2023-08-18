#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_python() {
    _install_conda() {
        apt-get update -y
        apt-get install -y wget

        local Directory=$(mktemp -d /tmp/conda.XXXXXX)
        pushd "${Directory}"
        wget -O 'Anaconda-Linux-x86_64.sh' https://repo.anaconda.com/archive/Anaconda3-2023.07-2-Linux-x86_64.sh
        bash Anaconda-Linux-x86_64.sh -b -p /usr/local/conda
        popd
        rm -rf "${Directory}"
    }

    _install_python() {
        source /usr/local/conda/bin/activate
        conda create -y -n python python=3.11.4
    }

    _install_conda
    _install_python
}

install_python
