#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install -D -m 0644 ./noninteractive.bash "${XDG_CONFIG_HOME:-$HOME/.config}/bash/noninteractive.bash"
