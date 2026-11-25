#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_duckdb() {
  export DEBIAN_FRONTEND=noninteractive
  curl -fsSL https://install.duckdb.org | bash
}

config_duckdb() {
  local bashrc="$HOME/.bashrc"
  local fish_config="$HOME/.config/fish/config.fish"

  install -m 0644 ./duckdbrc "$HOME/.duckdbrc"

  mkdir -p "$(dirname "$fish_config")"
  touch "$bashrc" "$fish_config"

  if ! grep -Fxq "# DuckDB" "$bashrc"; then
    cat >>"$bashrc" <<'BASHRC'

# DuckDB
DUCKDB_PATH="$HOME/.duckdb/cli/latest"
if [ -d "$DUCKDB_PATH" ]; then
	case ":$PATH:" in
	*:"$DUCKDB_PATH":*) ;;
	*) export PATH="$DUCKDB_PATH:$PATH" ;;
	esac
fi
BASHRC
  fi

  if ! grep -Fxq "# DuckDB" "$fish_config"; then
    cat >>"$fish_config" <<'FISH'

# DuckDB
set -l DUCKDB_PATH $HOME/.duckdb/cli/latest
if test -d $DUCKDB_PATH
    fish_add_path $DUCKDB_PATH
end
FISH
  fi
}

main() {
  install_duckdb
  config_duckdb
}

main
