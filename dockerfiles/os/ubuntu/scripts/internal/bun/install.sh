#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# 设置非交互模式，避免 apt 安装时弹出交互式提示
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y unzip curl

# 下载并安装 bun
curl -fsSL https://bun.sh/install | bash

# 配置 bun 到当前 shell 会话
# 设置 bun 安装目录
export BUN_INSTALL="$HOME/.bun"
# 将 bun 可执行文件目录添加到 PATH
export PATH="$BUN_INSTALL/bin:$PATH"

# 验证 bun 安装
bun --version

# 配置 bun shell 集成（支持 bash 和 fish）
mkdir -p /etc/profile.d /etc/fish/conf.d
cp bun.sh /etc/profile.d/bun.sh
cp bun.fish /etc/fish/conf.d/bun.fish
