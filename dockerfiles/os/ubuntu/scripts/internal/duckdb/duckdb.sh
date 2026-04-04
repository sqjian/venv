# shellcheck disable=SC2148
# shellcheck disable=SC2155

# duckdb
DUCKDB_PATH="$HOME/.duckdb/cli/latest"
if [ -d "$DUCKDB_PATH" ]; then
	export PATH="$DUCKDB_PATH:$PATH"
fi
