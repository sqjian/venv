#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1
export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）

touch /.dockerenv
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

mkdir -p /etc/profile.d /etc/fish/conf.d
cp brew.sh /etc/profile.d/brew.sh
cp brew.fish /etc/fish/conf.d/brew.fish

for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [ -x "$brew_path" ]; then
		eval "$("$brew_path" shellenv)"
		break
	fi
done
brew analytics off
brew update
