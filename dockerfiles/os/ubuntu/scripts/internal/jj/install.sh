#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_jj() {
	export DEBIAN_FRONTEND=noninteractive

	apt-get install -y --no-install-recommends jq curl ca-certificates

	# 架构检测
	ARCH=$(dpkg --print-architecture)
	case ${ARCH} in
	amd64)
		ARCH_NAME="x86_64-unknown-linux-musl"
		;;
	arm64)
		ARCH_NAME="aarch64-unknown-linux-musl"
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
	VERSION=$(curl -s "${CURL_AUTH_OPTS[@]}" "https://api.github.com/repos/jj-vcs/jj/releases/latest" | jq -r '.tag_name')

	# 下载并安装
	TEMP_DIR=$(mktemp -d)
	curl -fsSL "https://github.com/jj-vcs/jj/releases/download/${VERSION}/jj-${VERSION}-${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/jj.tar.gz"
	tar -xzf "${TEMP_DIR}/jj.tar.gz" -C "${TEMP_DIR}"
	install -m 755 "${TEMP_DIR}/jj" /usr/local/bin/jj
	rm -rf "${TEMP_DIR}"
}

config_jj() {
	jj config set --user user.email shengqi.jian@gmail.com
	jj config set --user user.name sqjian
}

function main() {
	install_jj
	config_jj
	jj --version
}

main
