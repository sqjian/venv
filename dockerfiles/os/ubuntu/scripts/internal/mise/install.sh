#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_mise() {
	export DEBIAN_FRONTEND=noninteractive

	curl https://mise.run | sh
}

config_mise() {
	local mise_config_dir="${XDG_CONFIG_HOME}/mise"
	mkdir -p "$mise_config_dir"
	cp config.toml "$mise_config_dir/config.toml"
	cp -r tasks "$mise_config_dir"
	chmod +x -R "$mise_config_dir/tasks"
	mkdir -p /etc/profile.d /etc/fish/conf.d
	cp mise.sh /etc/profile.d/mise.sh
	cp mise.fish /etc/fish/conf.d/mise.fish
}

function main() {
	install_mise
	config_mise
}

main
