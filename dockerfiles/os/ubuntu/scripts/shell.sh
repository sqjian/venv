#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

file_exists_or_create() {
    FILE=$1
    DIR=$(dirname "${FILE}")

    if [ -f "$FILE" ]; then
        echo "File $FILE already exists."
    else
        if [ ! -d "$DIR" ]; then
            echo "Directory $DIR does not exist. Creating now..."
            mkdir -p "$DIR"
            echo "Directory $DIR created."
        fi
        echo "File $FILE does not exist. Creating now..."
        touch "$FILE"
        echo "File $FILE created."
    fi
}

function add_content_to_file() {
    local content=$1
    local file=$2

    file_exists_or_create $file

    # Check if the content already exists in the file
    if grep -Fxq "$content" "$file"; then
        echo "The line '$content' has been added before, no need to add again."
    else
        echo "$content" >>"$file"
        echo "Added line '$content' to $file."
    fi
}

function set_shell() {
    tee /etc/motd <<EOF
-------------------------------------
This system is built by sqjian in $(date '+%Y-%m-%d %H:%M:%S')
-------------------------------------
EOF

    tee /etc/profile.d/ps1.sh <<'EOF'
PS1="docker=>${PS1}"
EOF

    # Add contents to the file
    add_content_to_file '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' '/root/.bashrc'
    add_content_to_file '. /etc/profile' '/root/.bashrc'
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
    set_shell
    set_apt
}

main
