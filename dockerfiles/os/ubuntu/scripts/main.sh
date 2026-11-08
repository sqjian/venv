#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

INSTALLERS_DIR="./installers"

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
	"${INSTALLERS_DIR}/locales.sh"
	"${INSTALLERS_DIR}/tools.sh"
	"${INSTALLERS_DIR}/7zip.sh"
	"${INSTALLERS_DIR}/ninja.sh"

	# === Git ===
	"${INSTALLERS_DIR}/git.sh"
	"${INSTALLERS_DIR}/gh.sh"
	"${INSTALLERS_DIR}/glab.sh"
	"${INSTALLERS_DIR}/jj.sh"

	# === 终端环境 ===
	"${INSTALLERS_DIR}/fish.sh"
	"${INSTALLERS_DIR}/brew.sh"
	"${INSTALLERS_DIR}/mise.sh"
	"${INSTALLERS_DIR}/uv.sh"
	"${INSTALLERS_DIR}/tmux.sh"
	"${INSTALLERS_DIR}/vim.sh"
	"${INSTALLERS_DIR}/ripgrep.sh"
	"${INSTALLERS_DIR}/fd.sh"
	"${INSTALLERS_DIR}/shfmt.sh"
	"${INSTALLERS_DIR}/starship.sh"

	# === 语言环境 ===
	"${INSTALLERS_DIR}/rust.sh"
	"${INSTALLERS_DIR}/fnm.sh"

	# === CUDA ===
	"${INSTALLERS_DIR}/cuda.sh"

	# === 容器、存储与数据 ===
	"${INSTALLERS_DIR}/docker.sh"
	"${INSTALLERS_DIR}/rclone.sh"
	"${INSTALLERS_DIR}/duckdb.sh"
}

install_all
clean
