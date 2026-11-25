#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_vim() {
	export DEBIAN_FRONTEND=noninteractive

	apt-get install -y vim
}

config_vim() {
	local bashrc="$HOME/.bashrc"
	local fish_config="$HOME/.config/fish/config.fish"
	local vimrc="${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc"

	install -D -m 0644 ./vimrc "$vimrc"
	ln -sfnT "$vimrc" "$HOME/.vimrc"

	mkdir -p "$(dirname "$fish_config")"
	touch "$bashrc" "$fish_config"

	if ! grep -Fxq "# Vim" "$bashrc"; then
		cat >>"$bashrc" <<'BASHRC'

# Vim
export EDITOR=vim
BASHRC
	fi

	if ! grep -Fxq "# Vim" "$fish_config"; then
		cat >>"$fish_config" <<'FISH'

# Vim
set -gx EDITOR vim
FISH
	fi
}

function main() {
	install_vim
	config_vim
}

main
