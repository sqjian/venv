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
	curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
}

config_rust() {
	# 配置环境变量
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Rust 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Rust 配置开始 --------------------
if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi
# -------------------- Rust 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Rust 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Rust 配置开始 --------------------
if test -f $HOME/.cargo/env.fish
    source $HOME/.cargo/env.fish
end
# -------------------- Rust 配置结束 --------------------

EOF
	fi
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
	config_rust
	install_toolchain
	verify_rust
}

main
