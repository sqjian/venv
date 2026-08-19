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
	readonly GIT_CONFIG_DIR="${HOME}/.config/git"
	mkdir -p "${GIT_CONFIG_DIR}"
	rm -f "${HOME}/.gitconfig"
	cp config "${GIT_CONFIG_DIR}/config"
}

function main() {
	install_git
	config_git
}

main
