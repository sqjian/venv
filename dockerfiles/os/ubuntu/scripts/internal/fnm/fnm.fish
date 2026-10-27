# fnm
set -l FNM_PATH "$XDG_DATA_HOME/fnm"
if test -d "$FNM_PATH"
    fish_add_path --path "$FNM_PATH"
    fnm env --shell fish | source
end
