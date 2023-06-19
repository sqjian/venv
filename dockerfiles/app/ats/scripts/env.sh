#!/bin/sh -eux


export DEBIAN_FRONTEND=noninteractive

tee -a /etc/motd <<- 'EOF'
-------------------------------------
   / \__
  (    @\___
  /         O
 /   (_____/
/_____/   U

This system is built by the sqjian
-------------------------------------
EOF

tee -a /etc/profile.d/ps1.sh <<-'EOF'
PS1="docker=>${PS1}"
EOF

tee -a /etc/profile.d/alias.sh <<-'EOF'
# shellcheck shell=sh
alias python='python3'
EOF

tee -a /root/.bashrc <<-'END'
[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd
. /etc/profile
END

tee /etc/apt/sources.list <<- 'EOF'
deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
EOF
