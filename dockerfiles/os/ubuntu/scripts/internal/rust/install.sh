#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# 安装 Rust 所需的 linker 和构建工具
apt-get install -y --no-install-recommends build-essential curl ca-certificates

# 使用 rustup 安装 Rust（-y 自动确认，非交互模式）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 配置环境变量
mkdir -p /etc/profile.d /etc/fish/conf.d
cp cargo.sh /etc/profile.d/cargo.sh
cp cargo.fish /etc/fish/conf.d/cargo.fish

# 加载 cargo 环境变量
source "$HOME/.cargo/env"

# 验证安装
rustc --version
cargo --version
