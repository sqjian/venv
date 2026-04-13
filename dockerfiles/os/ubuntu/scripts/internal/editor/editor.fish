# EDITOR: prefer nvim, fallback to vim
set -l NVIM_PATH (command -v nvim 2>/dev/null)
set -l VIM_PATH (command -v vim 2>/dev/null)

if test -n "$NVIM_PATH"
    set -gx EDITOR $NVIM_PATH
else if test -n "$VIM_PATH"
    set -gx EDITOR $VIM_PATH
end
