# Preserve the container's existing non-interactive initialization.
if [[ -r /etc/profile ]]; then
  source /etc/profile
fi

shopt -s expand_aliases

if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi

# Fnm
FNM_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
if [ -x "$FNM_PATH/fnm" ]; then
	case ":$PATH:" in
	*:"$FNM_PATH":*) ;;
	*) export PATH="$FNM_PATH:$PATH" ;;
	esac
	eval "$(fnm env --shell bash)"
fi

if [[ -r "$HOME/.bash_aliases" ]]; then
  source "$HOME/.bash_aliases"
fi
