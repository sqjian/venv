#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_mise() {
	export DEBIAN_FRONTEND=noninteractive

	curl https://mise.run | sh
}

function main() {
	install_mise
}

main
