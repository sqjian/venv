#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_brew() {
	export DEBIAN_FRONTEND=noninteractive
	export NONINTERACTIVE=1
	export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
	export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
	export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
	export HOMEBREW_FORCE_BREWED_CURL=1
	export HOMEBREW_FORCE_BREWED_GIT=1

	touch /.dockerenv
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

function main() {
	install_brew
}

main
