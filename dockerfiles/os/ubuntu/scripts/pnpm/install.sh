#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_pnpm() {
	export DEBIAN_FRONTEND=noninteractive

	# shell 配置由 chezmoi 管理。
	curl -fsSL https://get.pnpm.io/install.sh | env PNPM_NO_MODIFY_PATH=1 sh
}

config_pnpm() {
	install -D -m 0644 ./config.yaml "${XDG_CONFIG_HOME:-$HOME/.config}/pnpm/config.yaml"
}

main() {
	install_pnpm
	config_pnpm
}

main
