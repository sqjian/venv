#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates

# 架构检测
ARCH=$(dpkg --print-architecture)
case ${ARCH} in
  amd64)
    ARCH_NAME="x86_64-unknown-linux-musl"
    ;;
  arm64)
    ARCH_NAME="aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

token=${GH_TOKEN:-}
if [[ -r /run/secrets/gh_token ]]; then
  token=$(</run/secrets/gh_token)
fi
auth=()
if [[ -n $token ]]; then
  auth=(-H "Authorization: Bearer $token")
fi

# 获取最新版本号
VERSION=$(curl -q -fsSL "${auth[@]}" "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | jq -r '.tag_name')

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${VERSION}/ripgrep-${VERSION}-${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/ripgrep.tar.gz"
tar -xzf "${TEMP_DIR}/ripgrep.tar.gz" -C "${TEMP_DIR}"
install -m 755 "${TEMP_DIR}/ripgrep-${VERSION}-${ARCH_NAME}/rg" /usr/local/bin/rg
rm -rf "${TEMP_DIR}"

# 验证安装
rg --version
