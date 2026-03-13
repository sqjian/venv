#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates unzip

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

# GitHub API 认证
GH_TOKEN=$(cat /run/secrets/gh_token 2>/dev/null || echo "${GH_TOKEN:-}")
CURL_AUTH_OPTS=()
if [ -n "${GH_TOKEN:-}" ]; then
    CURL_AUTH_OPTS=(-H "Authorization: Bearer ${GH_TOKEN}")
fi

# 获取最新版本号
VERSION=$(curl -s "${CURL_AUTH_OPTS[@]}" "https://api.github.com/repos/ninja-build/ninja/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/ninja-build/ninja/releases/download/v${VERSION}/${ASSET_NAME}" -o "${TEMP_DIR}/ninja.zip"
unzip -o "${TEMP_DIR}/ninja.zip" -d "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/ninja" /usr/local/bin/ninja
rm -rf "${TEMP_DIR}"

# 验证安装
ninja --version
