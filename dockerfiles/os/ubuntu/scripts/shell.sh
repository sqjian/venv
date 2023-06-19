#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

function set_motd() {
    tee /etc/motd <<EOF
-------------------------------------
This system is built by sqjian in $(date '+%Y-%m-%d %H:%M:%S')
-------------------------------------
EOF
}

function set_ps() {
    tee /etc/profile.d/ps1.sh <<'EOF'
PS1="docker=>${PS1}"
EOF
}

function set_shell() {
    local content1='[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd'
    local content2='. /etc/profile'

    # Check if the first line already exists
    if grep -Fxq "$content1" /root/.bashrc; then
        echo "The line '$content1' has been added before, no need to add again."
    else
        echo "$content1" | tee -a /root/.bashrc
    fi

    # Check if the second line already exists
    if grep -Fxq "$content2" /root/.bashrc; then
        echo "The line '$content2' has been added before, no need to add again."
    else
        echo "$content2" | tee -a /root/.bashrc
    fi
}

function set_apt() {
    echo "config apt"

    cp /etc/apt/sources.list /etc/apt/sources.list.bak

    apt_sources() {
        tee /etc/apt/sources.list.aliyun <<EOF
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
    "18.04")
        apt_sources bionic
        ;;
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
}

function main() {
    set_motd
    set_ps
    set_shell
    set_apt
}

main
