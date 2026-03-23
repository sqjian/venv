#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates

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
GH_TOKEN=$(cat /run/secrets/gh_token 2>/dev/null || echo "${GH_TOKEN:-}")
CURL_AUTH_OPTS=()
if [ -n "${GH_TOKEN:-}" ]; then
	CURL_AUTH_OPTS=(-H "Authorization: Bearer ${GH_TOKEN}")
fi

# 获取最新版本号
VERSION=$(curl -s "${CURL_AUTH_OPTS[@]}" "https://api.github.com/repos/mvdan/sh/releases/latest" | jq -r '.tag_name')

# 下载并安装
curl -fsSL "https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${ARCH_NAME}" -o /usr/local/bin/shfmt
chmod 755 /usr/local/bin/shfmt

# 验证安装
shfmt --version
