#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_upx() {
    _install_upx() {
        apt-get update -y
        apt-get install -y curl xz-utils

        local Directory=$(mktemp -d /tmp/upx.XXXXXX)

        pushd "${Directory}"
        curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v4.0.2/upx-4.0.2-amd64_linux.tar.xz'
        mkdir -p /usr/local/upx
        tar -xJf upx.tar.xz --strip-components=1 -C /usr/local/upx
        popd

        rm -rf "${Directory}"
    }

    _update_alternatives() {

        rm -rf /usr/local/bin/{python,pip,pydoc,python-config} || true

        update-alternatives --remove-all upx || true
        update-alternatives --install /usr/local/bin/upx upx "/usr/local/upx/upx" 1 || (echo "set python alternatives failed" && exit 1)
        update-alternatives --auto upx
        update-alternatives --display upx

        upx --version
        which upx
    }

    _install_upx
    _update_alternatives

}

install_upx
