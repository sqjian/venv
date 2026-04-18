# fnm
set -l FNM_PATH $HOME/.local/share/fnm
if test -d $FNM_PATH
    fish_add_path $FNM_PATH
    fnm env --corepack-enabled --shell fish | source
end

# pnpm
set -gx COREPACK_ENABLE_DOWNLOAD_PROMPT 0
set -gx PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1
set -gx PNPM_HOME $HOME/.local/share/pnpm
fish_add_path $PNPM_HOME
