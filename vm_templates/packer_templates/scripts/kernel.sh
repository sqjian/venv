#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

# Update Operating System
# apt-get update -y

# Search Linux Image
# apt-cache search linux-image

# Install Linux Image: Linux Kernel 5.15 From Ubuntu’s repository
# apt-get install -y linux-headers-5.15.*-*-generic linux-image-5.15.*-*-generic

# Install Linux Image: Linux Kernel 5.15 From Canonical-kernel-team
# Import Proposed PPA
# add-apt-repository -y ppa:canonical-kernel-team/proposed
# apt-get update -y
# Option 1 – Install kernel-generic:apt-get install -y linux-headers-5.15.*-*-generic linux-image-5.15.*-*-generic
# Option 2 – Install low-latency kernel:apt-get install linux-headers-5.15.*-*-generic* linux-image-5.15.*-*-lowlatency

jammy() {
    add-apt-repository -y ppa:canonical-kernel-team/proposed
    apt-get update -y
    apt-get install -y linux-headers-6.2.*-*-generic linux-image-6.2.*-*-generic
    apt-get update -y
}

version_id="$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)"

case "$version_id" in
"22.04")
    jammy
    ;;
*)
    echo "Version $version_id is not supported. Only Ubuntu 22.04 (Jammy Jellyfish) is supported."
    ;;
esac

reboot
