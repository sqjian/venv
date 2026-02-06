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

cp brew.sh /etc/profile.d/brew.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew analytics off
brew update
