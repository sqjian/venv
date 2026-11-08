#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://install.duckdb.org | bash

config_duckdb() {
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- DuckDB 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- DuckDB 配置开始 --------------------
DUCKDB_PATH="$HOME/.duckdb/cli/latest"
if [ -d "$DUCKDB_PATH" ]; then
	export PATH="$DUCKDB_PATH:$PATH"
fi
# -------------------- DuckDB 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- DuckDB 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- DuckDB 配置开始 --------------------
set -l DUCKDB_PATH $HOME/.duckdb/cli/latest
if test -d $DUCKDB_PATH
    fish_add_path $DUCKDB_PATH
end
# -------------------- DuckDB 配置结束 --------------------

EOF
	fi
}

config_duckdb
cp duckdbrc "$HOME/.duckdbrc"
