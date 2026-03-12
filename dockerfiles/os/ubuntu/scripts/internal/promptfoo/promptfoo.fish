# fnm
set -l FNM_PATH /root/.local/share/fnm
if test -d $FNM_PATH
    fish_add_path $FNM_PATH
    fnm env --shell fish | source
end

# pnpm
set -gx COREPACK_ENABLE_DOWNLOAD_PROMPT 0
set -gx PNPM_HOME /root/.local/share/pnpm
fish_add_path $PNPM_HOME
