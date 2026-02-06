#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

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

# 获取最新版本号
VERSION=$(curl -s "https://gitlab.com/api/v4/projects/34675721/releases" | jq -r '.[0].tag_name' | sed 's/^v//')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${VERSION}/downloads/glab_${VERSION}_linux_${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/glab.tar.gz"
tar -xzf "${TEMP_DIR}/glab.tar.gz" -C "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/bin/glab" /usr/local/bin/glab
rm -rf "${TEMP_DIR}"

# 验证安装
glab --version
