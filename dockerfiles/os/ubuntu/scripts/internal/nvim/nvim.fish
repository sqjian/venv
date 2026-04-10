# nvim
set -l NVIM_PATH (command -v nvim 2>/dev/null)
if test -n "$NVIM_PATH"
    set -gx EDITOR $NVIM_PATH
end
