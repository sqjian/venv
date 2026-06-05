#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# enable 'universe' because musl-tools & clang live there
apt-get update
apt-get install -y --no-install-recommends software-properties-common
add-apt-repository --yes universe

# install build deps
apt-get update
apt-get install -y --no-install-recommends \
	build-essential curl git ca-certificates \
	pkg-config libcap-dev clang musl-tools libssl-dev

# install Rust + musl target
curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal

# 配置环境变量
mkdir -p /etc/profile.d /etc/fish/conf.d
cp cargo.sh /etc/profile.d/cargo.sh
cp cargo.fish /etc/fish/conf.d/cargo.fish

# 加载 cargo 环境变量
source "$HOME/.cargo/env"

# add musl target and components
rustup target add aarch64-unknown-linux-musl
rustup component add clippy rustfmt

# 验证安装
rustc --version
cargo --version
