#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends curl unzip

# 架构检测
ARCH=$(dpkg --print-architecture)
case ${ARCH} in
    amd64)
        ASSET_NAME="ninja-linux.zip"
        ;;
    arm64)
        ASSET_NAME="ninja-linux-aarch64.zip"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# 获取最新版本号
VERSION=$(curl -sI "https://github.com/ninja-build/ninja/releases/latest" | grep -i '^location:' | sed 's|.*/v||' | tr -d '\r')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/ninja-build/ninja/releases/download/v${VERSION}/${ASSET_NAME}" -o "${TEMP_DIR}/ninja.zip"
unzip -o "${TEMP_DIR}/ninja.zip" -d "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/ninja" /usr/local/bin/ninja
rm -rf "${TEMP_DIR}"

# 验证安装
ninja --version
