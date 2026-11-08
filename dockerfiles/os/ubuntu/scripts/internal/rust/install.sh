#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_rust() {
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
	curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
}

install_toolchain() {
	# add musl target and components
	"$HOME/.cargo/bin/rustup" target add aarch64-unknown-linux-musl
	"$HOME/.cargo/bin/rustup" component add clippy rustfmt
}

verify_rust() {
	# 验证安装
	"$HOME/.cargo/bin/rustc" --version
	"$HOME/.cargo/bin/cargo" --version
}

function main() {
	install_rust
	install_toolchain
	verify_rust
}

main
