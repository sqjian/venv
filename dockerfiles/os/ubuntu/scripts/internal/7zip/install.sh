#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates xz-utils libstdc++6

CURL_RETRY_OPTS=(
	--retry 5
	--retry-delay 2
	--retry-all-errors
	--connect-timeout 30
)

# GitHub API 认证
set +x
GH_TOKEN=$(cat /run/secrets/gh_token 2>/dev/null || echo "${GH_TOKEN:-}")
set -x
CURL_AUTH_OPTS=()
if [ -n "${GH_TOKEN:-}" ]; then
	CURL_AUTH_OPTS=(-H "Authorization: Bearer ${GH_TOKEN}")
fi

ARCH=$(dpkg --print-architecture)
case ${ARCH} in
amd64)
	ARCH_NAME="linux-x64"
	;;
arm64)
	ARCH_NAME="linux-arm64"
	;;
*)
	echo "Unsupported architecture: ${ARCH}"
	exit 1
	;;
esac

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

# 获取最新版本号
VERSION=$(curl -fsSL "${CURL_RETRY_OPTS[@]}" "${CURL_AUTH_OPTS[@]}" "https://api.github.com/repos/ip7z/7zip/releases/latest" | jq -r '.tag_name // empty')
if [ -z "${VERSION}" ]; then
	echo "Failed to resolve latest 7-Zip release version from GitHub"
	exit 1
fi

PACKAGE_VERSION=${VERSION#v}
PACKAGE_VERSION_NUMBER=${PACKAGE_VERSION//./}

# 下载并安装
curl -fsSL "${CURL_RETRY_OPTS[@]}" "https://github.com/ip7z/7zip/releases/download/${VERSION}/7z${PACKAGE_VERSION_NUMBER}-${ARCH_NAME}.tar.xz" -o "${TEMP_DIR}/7zip.tar.xz"
tar -xJf "${TEMP_DIR}/7zip.tar.xz" -C "${TEMP_DIR}" 7zz
install -m 755 "${TEMP_DIR}/7zz" /usr/local/bin/7zz

7zz | sed -n '2p'
