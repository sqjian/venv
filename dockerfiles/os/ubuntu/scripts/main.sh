#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

function clean() {
	echo "autoremoving packages and cleaning apt data"
	apt-get -y autoremove
	apt-get -y clean

	echo "remove /var/lib/apt/lists/"
	rm -rf /var/lib/apt/lists/*

	echo "remove /tmp/"
	rm -rf /tmp/*
}

function install_all() {
	apt-get update -y

	# Infrequently updated tools
	# === 系统基础 ===
	./locales/install.sh
	./tools/install.sh
	./7zip/install.sh
	./ninja/install.sh

	# === Git ===
	./git/install.sh
	./gh/install.sh
	./glab/install.sh
	./jj/install.sh

	# === 终端环境 ===
	./bash/install.sh
	./fish/install.sh
	./brew/install.sh
	./mise/install.sh
	./uv/install.sh
	./tmux/install.sh
	./vim/install.sh
	./ripgrep/install.sh
	./fd/install.sh
	./shfmt/install.sh
	./starship/install.sh
	./chezmoi/install.sh

	# === 语言环境 ===
	./rust/install.sh
	./fnm/install.sh
	./pnpm/install.sh

	# === CUDA ===
	./cuda/install.sh

	# === 容器、存储与数据 ===
	./docker/install.sh
	./rclone/install.sh
	./duckdb/install.sh
}

install_all
clean
