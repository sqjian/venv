#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

echo "remove linux-headers"
dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-headers' |
    xargs apt-get -y purge || true

echo "remove specific Linux kernels, such as linux-image-3.11.0-15-generic but keeps the current kernel and does not touch the virtual packages"
dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-image-.*-generic' |
    grep -v "$(uname -r)" |
    xargs apt-get -y purge || true

echo "remove old kernel modules packages"
dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-modules-.*-generic' |
    grep -v "$(uname -r)" |
    xargs apt-get -y purge || true

echo "remove linux-source package"
dpkg --list |
    awk '{ print $2 }' |
    grep linux-source |
    xargs apt-get -y purge || true

echo "remove docs packages"
dpkg --list |
    awk '{ print $2 }' |
    grep -- '-doc$' |
    xargs apt-get -y purge || true

# echo "remove snap"
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
snap list --all |
    grep -Pv "Name|core|snapd" |
    awk '{print $1}' |
    xargs -n1 snap remove --purge || true
apt-get remove -y --autoremove snapd
mount_points=$(mount | grep 'snap' | awk '{print $3}') || true
if [ -z "$mount_points" ]; then
    echo "No mount points containing 'snap' were found"
else
    for mount_point in $mount_points; do
        echo "Unmounting: $mount_point"
        if umount "$mount_point"; then
            echo "Successfully unmounted: $mount_point"
        else
            echo "Unmounting failed: $mount_point"
        fi
    done
fi
rm -rf ~/snap /root/snap /snap /var/snap /var/lib/snapd
tee /etc/apt/preferences.d/nosnap.pref <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

echo "remove Ubuntu Pro banner"
rm -rf /etc/apt/apt.conf.d/20apt-esm-hook.conf

echo "remove X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6

echo "remove obsolete networking packages"
apt-get -y purge ppp pppconfig pppoeconf

echo "remove packages we don't need"
apt-get -y purge popularity-contest command-not-found friendly-recovery laptop-detect motd-news-config usbutils grub-legacy-ec2

# 22.04+ don't have this
echo "remove the fonts-ubuntu-font-family-console"
apt-get -y purge fonts-ubuntu-font-family-console || true

# 21.04+ don't have this
echo "remove the installation-report"
apt-get -y purge popularity-contest installation-report || true

echo "remove the console font"
apt-get -y purge fonts-ubuntu-console || true

echo "removing command-not-found-data"
# 19.10+ don't have this package so fail gracefully
apt-get -y purge command-not-found-data || true

# Exclude the files we don't need w/o uninstalling linux-firmware
echo "Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >>/etc/dpkg/dpkg.cfg.d/excludes
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
_EOF_

echo "delete the massive firmware files"
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

echo "autoremoving packages and cleaning apt data"
apt-get -y autoremove
apt-get -y clean

echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts
export HISTSIZE=0
