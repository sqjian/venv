#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_mise() {
	export DEBIAN_FRONTEND=noninteractive

	curl https://mise.run | sh
}

config_mise() {
	if [ ! -d "$HOME/.config/mise" ]; then
		mkdir -p "$HOME/.config/mise"
	fi
	cp config.toml "$HOME/.config/mise/config.toml"
	cp -r tasks "$HOME/.config/mise"
	chmod +x -R "$HOME/.config/mise/tasks"
	mkdir -p /etc/profile.d /etc/fish/conf.d
	cp mise.sh /etc/profile.d/mise.sh
	cp mise.fish /etc/fish/conf.d/mise.fish
}

function main() {
	install_mise
	config_mise
}

main
