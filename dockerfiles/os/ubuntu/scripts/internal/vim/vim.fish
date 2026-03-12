# vim
set -l VIM_PATH (command -v vim 2>/dev/null)
if test -n "$VIM_PATH"
    set -gx EDITOR $VIM_PATH
end
