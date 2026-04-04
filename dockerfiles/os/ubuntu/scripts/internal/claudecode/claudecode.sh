# shellcheck disable=SC2148
# shellcheck disable=SC2155

# claudecode
CLAUDECODE_PATH="$HOME/.local/bin"
if [ -d "$CLAUDECODE_PATH" ]; then
	export PATH="$CLAUDECODE_PATH:$PATH"
fi
