# shellcheck disable=SC2148
# shellcheck disable=SC2155

# mise
MISE_PATH="$HOME/.local/bin/mise"
if [ -x "$MISE_PATH" ]; then
    eval "$($MISE_PATH activate bash)"
fi