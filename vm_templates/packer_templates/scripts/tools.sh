#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

install_base_tools() {
    echo "installing base tools..."
    apt-get install -y \
        binutils \
        net-tools \
        inetutils-ping \
        iproute2 \
        gawk \
        git \
        unzip \
        dstat \
        jq \
        wget \
        curl \
        rsync \
        dos2unix \
        socat \
        fish
}
install_cpp() {
    echo "installing cpp..."
    apt-get install -y \
        build-essential \
        gcc \
        g++ \
        clang \
        lldb \
        lld \
        gdb \
        make \
        automake \
        autoconf

    # usdt lib:systemtap-sdt-dev
    apt-get install -y \
        systemtap-sdt-dev
}

install_go() {
    apt-get update -y
    apt-get install -y \
        curl \
        git \
        graphviz \
        jq
    local _go_ver
    _go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
    local _go_os=linux
    local _go_arch=amd64
    local _go_url="https://dl.google.com/go/${_go_ver}.${_go_os}-${_go_arch}.tar.gz"
    local _go_dir="/usr/local"
    if [ -d "${_go_dir}/go" ]; then
        rm -rf "${_go_dir}/go"
    fi
    curl --retry 3 -L -o go.tgz "$_go_url"
    tar xzf go.tgz -C "${_go_dir}"
    rm -f go.tgz
    echo "Go ${_go_ver} installed successfully."

    tee /etc/profile.d/go.sh <<'EOF'
# shellcheck shell=sh

export GOROOT=/usr/local/go
export GOPATH=${GOROOT}/mylib
export GOPROXY=https://goproxy.cn
export GO111MODULE=on

go_bin_path=${GOPATH}/bin:${GOROOT}/bin
if [ -n "${PATH##*${go_bin_path}}" -a -n "${PATH##*${go_bin_path}:*}" ]; then
    export PATH=${PATH}:${go_bin_path}
fi
EOF
}

install_docker() {

    _install_docker() {
        echo "install docker..."

        apt-get update -y
        apt-get install -y ca-certificates curl gnupg lsb-release

        local _keyrings_dir=/etc/apt/keyrings
        if [ ! -d "${_keyrings_dir}" ]; then
            mkdir -p ${_keyrings_dir}
        fi
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --dearmor -o ${_keyrings_dir}/docker.gpg
        chmod a+r ${_keyrings_dir}/docker.gpg

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        _containerd_dir=/etc/containerd
        if [ ! -d "${_containerd_dir}" ]; then
            mkdir -p ${_containerd_dir}
        fi
        mkdir -p ${_containerd_dir}
        containerd config default | tee ${_containerd_dir}/config.toml

        systemctl restart containerd
    }
    _install_docker
}

config_shell() {
    sed -i 's/\(required\)\(.*pam_shells.so\)/sufficient\2/g' /etc/pam.d/chsh
    chsh -s /bin/bash
}

install_tmux() {
    _install_tmux_bin() {
        echo "installing tmux..."
        apt-get update -y
        apt-get install -y tmux
    }

    _clean_old_tmux_cfg() {
        local _old_tmux_cfg_dir=$1
        rm -rf "${_old_tmux_cfg_dir}"/.tmux*
    }

    _install_gpakosz_tmux_config() {
        local _gpakosz_tmux_config_dir=$1
        git clone --depth=1 https://github.com/gpakosz/.tmux.git "${_gpakosz_tmux_config_dir}"/.tmux
        ln -s "${_gpakosz_tmux_config_dir}/.tmux/.tmux.conf" "${_gpakosz_tmux_config_dir}/.tmux.conf"
        cp "${_gpakosz_tmux_config_dir}"/.tmux/.tmux.conf.local "${_gpakosz_tmux_config_dir}"/.tmux.conf.local
    }

    _install_custom_tmux_config() {

        local _custom_tmux_config_dir=$1

        sed -i '/set -g prefix2 C-a/d' "${_custom_tmux_config_dir}"/.tmux.conf
        sed -i '/bind C-a send-prefix -2/d' "${_custom_tmux_config_dir}"/.tmux.conf

        tee -a "${_custom_tmux_config_dir}"/.tmux.conf.local >/dev/null <<'EOF'
# 基础设置
set-option -g default-command "fish"
set-window-option -g clock-mode-style 24 # 24小时显示方式

# 绑定hjkl键为面板切换的上下左右键
bind -r k select-pane -U # 绑定k为↑,选择上面板
bind -r j select-pane -D # 绑定j为↓,选择下面板
bind -r h select-pane -L # 绑定h为←,选择左面板
bind -r l select-pane -R # 绑定l为→,选择右面板

# 绑定Ctrl+hjkl键为面板上下左右调整边缘的快捷指令
bind -r ^k resizep -U 5 # 绑定Ctrl+k为往↑调整面板边缘5个单元格
bind -r ^j resizep -D 5 # 绑定Ctrl+j为往↓调整面板边缘5个单元格
bind -r ^h resizep -L 5 # 绑定Ctrl+h为往←调整面板边缘5个单元格
bind -r ^l resizep -R 5 # 绑定Ctrl+l为往→调整面板边缘5个单元格

# 交换面板
bind ^u swapp -U # 与上面板交换
bind ^d swapp -D # 与下面板交换

# 切换窗口
bind -r C-p previous-window # select previous window
bind -r C-n next-window     # select next window
EOF
    }

    local _tmux_root_dir="/root"

    _install_tmux_bin
    _clean_old_tmux_cfg ${_tmux_root_dir}
    _install_gpakosz_tmux_config ${_tmux_root_dir}
    _install_custom_tmux_config ${_tmux_root_dir}
}

install_tools_from_ppa() {
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    add-apt-repository -y ppa:fish-shell/release-3
    apt-get update -y
    apt-get install -y git fish
}

install_vim() {

    apt-get update -y
    apt-get install -y vim

    tee /etc/profile.d/vim.sh <<'EOF'
# shellcheck shell=sh

export EDITOR=$(which vim)
EOF
    local Directory=/tmp/vim
    if [ -d "$Directory" ]; then
        echo "Directory $Directory exists. Removing and recreating it..."
        rm -rf "$Directory"
        mkdir "$Directory"
    else
        echo "Directory $Directory does not exist. Creating it..."
        mkdir -p "$Directory"
    fi

    pushd ${Directory}
    git clone --depth=1 https://github.com/sqjian/venv.git
    git clone --depth=1 https://github.com/amix/vimrc.git
    cat /tmp/vim/vimrc/vimrcs/basic.vim >/root/.vimrc
    cat /tmp/vim/venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc
    popd
    rm -rf ${Directory}

}

main() {
    install_base_tools
    install_tools_from_ppa
    install_cpp
    install_go
    install_docker
    config_shell
    install_tmux
    install_vim
}

main
