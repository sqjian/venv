#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

VIM_CONFIG_DIR="${XDG_CONFIG_HOME}/vim"
mkdir -p "$VIM_CONFIG_DIR"
cp vimrc "$VIM_CONFIG_DIR/vimrc"

# Ubuntu 24.04 的 Vim 尚不支持 XDG vimrc，保留已有用户配置。
if [[ ! -e "$HOME/.vimrc" && ! -L "$HOME/.vimrc" ]]; then
	ln -s "$VIM_CONFIG_DIR/vimrc" "$HOME/.vimrc"
fi

config_vim() {
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Vim 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Vim 配置开始 --------------------
export EDITOR=vim
# -------------------- Vim 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Vim 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Vim 配置开始 --------------------
set -gx EDITOR vim
# -------------------- Vim 配置结束 --------------------

EOF
	fi
}

config_vim
