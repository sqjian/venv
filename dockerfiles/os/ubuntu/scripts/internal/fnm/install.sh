#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_fnm() {
	# 设置非交互模式，避免 apt 安装时弹出交互式提示
	export DEBIAN_FRONTEND=noninteractive

	apt-get update -y
	apt-get install -y unzip curl

	# 安装器默认使用 XDG_DATA_HOME，由本仓库维护 shell 配置。
	curl -o- https://fnm.vercel.app/install | bash -s -- --skip-shell

	# 在当前 shell 中启用 fnm，供后续安装 Node.js 使用。
	export PATH="${XDG_DATA_HOME}/fnm:$PATH"
	eval "$(fnm env --shell bash)"
}

install_node() {
	# 下载并安装 Node.js LTS 版本
	fnm install --lts
	node -v
}

verify_fnm() {
	# 验证 fnm 安装
	fnm --version
}

config_fnm() {
	# 配置 fnm shell 集成（支持 bash 和 fish）
	mkdir -p /etc/profile.d /etc/fish/conf.d
	cp fnm.sh /etc/profile.d/fnm.sh
	cp fnm.fish /etc/fish/conf.d/fnm.fish
}

function main() {
	install_fnm
	install_node
	verify_fnm
	config_fnm
}

main
