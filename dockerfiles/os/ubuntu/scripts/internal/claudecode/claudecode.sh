# shellcheck disable=SC2148
# shellcheck disable=SC2155

# claudecode
CLAUDECODE_PATH="/root/.local/bin"
if [ -d "$CLAUDECODE_PATH" ]; then
    export PATH="$CLAUDECODE_PATH:$PATH"
fi