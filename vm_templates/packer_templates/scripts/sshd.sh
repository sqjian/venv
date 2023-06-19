#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

SSHD_CONFIG="/etc/ssh/sshd_config"

# ensure that there is a trailing newline before attempting to concatenate
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
    echo "$USEDNS" >>"$SSHD_CONFIG"
fi

GSSAPI="GSSAPIAuthentication no"
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
    sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
else
    echo "$GSSAPI" >>"$SSHD_CONFIG"
fi

ROOTLOGIN="PermitRootLogin yes"
if grep -q -E "^[[:space:]]*PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i "s/^\s*PermitRootLogin.*/${ROOTLOGIN}/" "$SSHD_CONFIG"
else
    echo "$ROOTLOGIN" >>"$SSHD_CONFIG"
fi
