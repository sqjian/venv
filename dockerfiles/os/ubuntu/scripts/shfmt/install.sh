#!/usr/bin/env bash

set -eo pipefail

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

token=${GH_TOKEN:-}
if [[ -r /run/secrets/gh_token ]]; then
	token=$(</run/secrets/gh_token)
fi
auth=()
if [[ -n $token ]]; then
	auth=(-H "Authorization: Bearer $token")
fi

# 获取最新版本号
VERSION=$(curl -q -fsSL "${auth[@]}" "https://api.github.com/repos/mvdan/sh/releases/latest" | jq -r '.tag_name')

# 下载并安装
curl -fsSL "https://github.com/mvdan/sh/releases/download/${VERSION}/shfmt_${VERSION}_linux_${ARCH_NAME}" -o /usr/local/bin/shfmt
chmod 755 /usr/local/bin/shfmt

# 验证安装
shfmt --version
