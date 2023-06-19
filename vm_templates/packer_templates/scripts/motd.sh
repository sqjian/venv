#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

motd=$(
    cat <<-EOF
This system is built by sqjian in $(date '+%Y-%m-%d %H:%M:%S')
EOF
)

motd=$(
    cat <<-EOF
$motd
EOF
)

if [ -d /etc/update-motd.d ]; then
    MOTD_CONFIG='/etc/update-motd.d/99-motd'

    cat >"$MOTD_CONFIG" <<MOTD
#!/bin/sh
cat <<'EOF'
$motd

EOF
MOTD

    chmod 0755 "$MOTD_CONFIG"
else
    echo "$motd" >/etc/motd
fi
