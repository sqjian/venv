# fnm
set -l FNM_PATH $HOME/.local/share/fnm
if test -d $FNM_PATH
    fish_add_path $FNM_PATH
    fnm env --shell fish | source
end
