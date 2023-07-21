#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_upx() {
    apt-get update -y
    apt-get install -y curl xz-utils

    local Directory=$(mktemp -d /tmp/upx.XXXXXX)

    pushd "${Directory}"
    curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v4.0.2/upx-4.0.2-amd64_linux.tar.xz'
    tar -xJf upx.tar.xz --strip-components=1 -C /usr/local/upx
    popd

    rm -rf "${Directory}"
}

install_upx
