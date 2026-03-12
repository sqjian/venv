# duckdb
set -l DUCKDB_PATH /root/.duckdb/cli/latest
if test -d $DUCKDB_PATH
    fish_add_path $DUCKDB_PATH
end
