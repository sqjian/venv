#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_mise() {
  export DEBIAN_FRONTEND=noninteractive

  curl https://mise.run | sh
}

config_mise() {
  local bashrc="$HOME/.bashrc"
  local fish_config="$HOME/.config/fish/config.fish"

  install -D -m 0644 ./config.toml "${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"

  mkdir -p "$(dirname "$fish_config")"
  touch "$bashrc" "$fish_config"

  if ! grep -Fxq "# Mise" "$bashrc"; then
    cat >>"$bashrc" <<'BASHRC'

# Mise
if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate bash)"
fi
BASHRC
  fi

  if ! grep -Fxq "# Mise" "$fish_config"; then
    cat >>"$fish_config" <<'FISH'

# Mise
if command -q mise
    mise activate fish | source
end
FISH
  fi
}

function main() {
  install_mise
  config_mise
}

main
