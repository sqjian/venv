#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# 架构检测
ARCH=$(dpkg --print-architecture)
case ${ARCH} in
amd64)
	ARCH_NAME="x86_64"
	;;
arm64)
	ARCH_NAME="arm64"
	;;
*)
	echo "Unsupported architecture: ${ARCH}"
	exit 1
	;;
esac

# 下载并安装
TEMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/nvim.tar.gz"
tar -xzf "${TEMP_DIR}/nvim.tar.gz" -C "${TEMP_DIR}"
cp -r "${TEMP_DIR}/nvim-linux-${ARCH_NAME}/"* /usr/local/
rm -rf "${TEMP_DIR}"

# 配置文件
mkdir -p "$HOME/.config/nvim"
cp init.lua "$HOME/.config/nvim/init.lua"

# 验证安装
nvim --version
