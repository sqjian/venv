# shellcheck disable=SC2148
# shellcheck disable=SC2155

# vim
VIM_PATH=$(command -v vim 2>/dev/null)
if [ -n "$VIM_PATH" ]; then
    export EDITOR="$VIM_PATH"
fi