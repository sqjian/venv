#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_starship() {
  export DEBIAN_FRONTEND=noninteractive

  apt-get install -y --no-install-recommends jq curl ca-certificates

  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

config_starship() {
  local bashrc="$HOME/.bashrc"
  local fish_config="$HOME/.config/fish/config.fish"

  install -D -m 0644 ./starship.toml "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

  mkdir -p "$(dirname "$fish_config")"
  touch "$bashrc" "$fish_config"

  if ! grep -Fxq "# Starship" "$bashrc"; then
    cat >>"$bashrc" <<'BASHRC'

# Starship
if [[ "$TERM" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"
fi
BASHRC
  fi

  if ! grep -Fxq "# Starship" "$fish_config"; then
    cat >>"$fish_config" <<'FISH'

# Starship
# 过滤掉 dumb 终端
if test "$TERM" != dumb; and command -q starship
    starship init fish | source
end
FISH
  fi
}

function main() {
  install_starship
  config_starship
}

main
