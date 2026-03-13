#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# 架构检测
ARCH=$(dpkg --print-architecture)
case ${ARCH} in
    amd64)
        ARCH_NAME="x86_64-unknown-linux-gnu"
        ;;
    arm64)
        ARCH_NAME="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# 获取最新版本号
VERSION=$(curl -sI "https://github.com/sharkdp/bat/releases/latest" | grep -i '^location:' | sed 's|.*/v||' | tr -d '\r')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${VERSION}/bat-v${VERSION}-${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/bat.tar.gz"
tar -xzf "${TEMP_DIR}/bat.tar.gz" -C "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/bat-v${VERSION}-${ARCH_NAME}/bat" /usr/local/bin/bat
rm -rf "${TEMP_DIR}"

# 验证安装
bat --version