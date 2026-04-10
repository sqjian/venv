# shellcheck disable=SC2148
# shellcheck disable=SC2155

# nvim
NVIM_PATH=$(command -v nvim 2>/dev/null)
if [ -n "$NVIM_PATH" ]; then
	export EDITOR="$NVIM_PATH"
fi
