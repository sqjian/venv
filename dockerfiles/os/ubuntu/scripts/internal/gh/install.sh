#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive
GH_TOKEN=$(cat /run/secrets/gh_token 2>/dev/null || echo "")
export GH_TOKEN

# 架构检测
ARCH=$(dpkg --print-architecture)
case ${ARCH} in
    amd64)
        ARCH_NAME="amd64"
        ;;
    arm64)
        ARCH_NAME="arm64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# GitHub API 认证
CURL_AUTH_OPTS=()
if [ -n "${GH_TOKEN:-}" ]; then
    CURL_AUTH_OPTS=(-H "Authorization: Bearer ${GH_TOKEN}")
fi

# 获取最新版本号
VERSION=$(curl -s "${CURL_AUTH_OPTS[@]}" "https://api.github.com/repos/cli/cli/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/gh.tar.gz"
tar -xzf "${TEMP_DIR}/gh.tar.gz" -C "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/gh_${VERSION}_linux_${ARCH_NAME}/bin/gh" /usr/local/bin/gh
rm -rf "${TEMP_DIR}"

# 验证安装
gh --version
