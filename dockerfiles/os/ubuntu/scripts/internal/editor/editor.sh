# shellcheck disable=SC2148
# shellcheck disable=SC2155

# EDITOR: prefer nvim, fallback to vim
NVIM_PATH=$(command -v nvim 2>/dev/null)
VIM_PATH=$(command -v vim 2>/dev/null)

if [ -n "$NVIM_PATH" ]; then
	export EDITOR="$NVIM_PATH"
elif [ -n "$VIM_PATH" ]; then
	export EDITOR="$VIM_PATH"
fi
