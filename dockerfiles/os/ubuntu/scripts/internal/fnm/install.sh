#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# 设置非交互模式，避免 apt 安装时弹出交互式提示
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y unzip curl

# 下载并安装 fnm
curl -o- https://fnm.vercel.app/install | bash

# 配置 fnm 到当前 shell 会话
# 将 fnm 可执行文件目录添加到 PATH
export PATH="$HOME/.local/share/fnm:$PATH"
# 初始化 fnm 环境变量（设置 NODE_PATH 等）
eval "$(fnm env)"

# 下载并安装 Node.js LTS 版本
fnm install --lts
node -v

# 下载并安装 pnpm
# 禁用 corepack 下载确认提示，实现静默安装
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# 跳过 Playwright 浏览器自动下载，减少镜像体积和构建时间
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
# 设置 pnpm 全局包存储目录
export PNPM_HOME="$HOME/.local/share/pnpm"
# 将 pnpm 可执行文件目录添加到 PATH
export PATH="$PNPM_HOME:$PATH"
# pnpm setup 命令需要 SHELL 变量来确定配置哪个 shell 的启动文件
export SHELL="/bin/bash"
corepack enable pnpm
pnpm setup
pnpm -v

# 配置 pnpm：允许执行构建脚本，启用并行构建
pnpm config set dangerouslyAllowAllBuilds true --global
pnpm config set childConcurrency 10 --global

# 验证 fnm 安装
fnm --version

# 配置 fnm shell 集成（支持 bash 和 fish）
mkdir -p /etc/profile.d /etc/fish/conf.d
cp fnm.sh /etc/profile.d/fnm.sh
cp fnm.fish /etc/fish/conf.d/fnm.fish
