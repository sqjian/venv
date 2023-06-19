#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "base config"

tee -a /etc/motd <<EOF
-------------------------------------
This system is built by sqjian in $(date '+%Y-%m-%d %H:%M:%S')
-------------------------------------
EOF

tee -a /etc/profile.d/ps1.sh <<'EOF'
PS1="docker=>${PS1}"
EOF

tee -a /root/.bashrc <<'END'
[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd
. /etc/profile
END

echo "config apt"

apt_sources() {
    tee /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ $1 main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $1 main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $1-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $1-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $1-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $1-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $1-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $1-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ $1-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $1-backports main restricted universe multiverse
EOF
}

case "$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)" in
"20.04")
    apt_sources focal
    ;;
"22.04")
    apt_sources jammy
    ;;
*)
    echo "not supported"
    exit 1
    ;;
esac
