# shellcheck disable=SC2148
# shellcheck disable=SC2155

# fnm
FNM_PATH="/root/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env)"
fi

# pnpm
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
