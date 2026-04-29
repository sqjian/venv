#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_git() {
	export DEBIAN_FRONTEND=noninteractive

	apt-get install -y \
		curl \
		software-properties-common \
		apt-transport-https \
		ca-certificates \
		gnupg-agent

	apt-get remove -y git git-lfs || true

	add-apt-repository -y ppa:git-core/ppa
	curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
	apt-get update -y
	apt-get install -y git git-lfs
}

config_git() {
	export XDG_CONFIG_HOME="$HOME/.config"

	rm -f "$HOME/.gitconfig" && install -D /dev/null "$XDG_CONFIG_HOME/git/config"

	git config --global core.quotepath false
	git config --global core.autocrlf false
	git config --global core.safecrlf true
	git config --global pull.rebase true
	git config --global init.defaultBranch main
	git config --global --get user.email >/dev/null || git config --global user.email shengqi.jian@gmail.com
	git config --global --get user.name >/dev/null || git config --global user.name sqjian
}

function main() {
	install_git
	config_git
}

main
