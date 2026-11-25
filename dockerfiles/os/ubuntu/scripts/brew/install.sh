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

  local installer
  installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
  /bin/bash -c "$installer"
}

config_brew() {
  local bashrc="$HOME/.bashrc"
  local fish_config="$HOME/.config/fish/config.fish"

  mkdir -p "$(dirname "$fish_config")"
  touch "$bashrc" "$fish_config"

  if ! grep -Fxq "# Brew" "$bashrc"; then
    cat >>"$bashrc" <<'BASHRC'

# Brew
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [ -x "$brew_path" ]; then
		export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
		export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
		export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
		export HOMEBREW_FORCE_BREWED_CURL=1
		export HOMEBREW_FORCE_BREWED_GIT=1
		eval "$("$brew_path" shellenv)"
		break
	fi
done
BASHRC
  fi

  if ! grep -Fxq "# Brew" "$fish_config"; then
    cat >>"$fish_config" <<'FISH'

# Brew
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew_path
        eval ($brew_path shellenv)
        set -gx HOMEBREW_FORCE_VENDOR_RUBY 1
        set -gx HOMEBREW_NO_ANALYTICS 1
        set -gx HOMEBREW_NO_AUTO_UPDATE 1
        set -gx HOMEBREW_FORCE_BREWED_CURL 1
        set -gx HOMEBREW_FORCE_BREWED_GIT 1
        break
    end
end
FISH
  fi
}

function main() {
  install_brew
  config_brew
}

main
