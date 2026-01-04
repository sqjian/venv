#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NONINTERACTIVE=1
export HOMEBREW_FORCE_VENDOR_RUBY=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# 安装 Homebrew
sudo touch /.dockerenv
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 配置环境
sudo tee /etc/profile.d/brew.sh <<'EOF'
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export HOMEBREW_NO_ANALYTICS=1
EOF
sudo chmod +x /etc/profile.d/brew.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 安装工具并清理
brew install uv
brew cleanup -s
