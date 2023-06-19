#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

# https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub

mkdir -p "$HOME_DIR"/.ssh
cat >"$HOME_DIR"/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAgTCjiEYtl/WzOzSnxrnj7VCKegCsl05Fomqy2O2wF/0XTFO45xRfYguoA3VL1DzTdrOzHZdtA6zZ0JEMHPRMo= shengqi.jian@qq.com
EOF
chown -R vagrant "$HOME_DIR"/.ssh
chmod -R go-rwsx "$HOME_DIR"/.ssh
