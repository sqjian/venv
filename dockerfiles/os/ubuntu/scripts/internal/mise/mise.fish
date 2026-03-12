# mise
set MISE_PATH "$HOME/.local/bin/mise"
if test -x "$MISE_PATH"
    set -gx MISE_TRUSTED_CONFIG_PATHS "/"
    $MISE_PATH activate fish | source
end