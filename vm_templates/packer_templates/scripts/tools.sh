#!/usr/bin/env bash

set -eux -o pipefail

export DEBIAN_FRONTEND=noninteractive

function install_base_tools() {
    echo "installing base tools..."
    apt-get install -y \
        binutils \
        net-tools \
        inetutils-ping \
        iproute2 \
        gawk \
        zip unzip \
        dstat \
        jq \
        wget \
        makeself \
        curl \
        rsync \
        dos2unix \
        socat \
        lsb-release
}
function install_gcc() {
    echo "installing gcc..."

    apt-get update -y
    apt-get install -y gcc g++ gdb \
        make cmake automake autoconf \
        systemtap-sdt-dev lsb-release

    local UBUNTU_VERSION
    UBUNTU_VERSION=$(lsb_release -rs)

    if [ "$UBUNTU_VERSION" == "22.04" ]; then
        apt-get install -y gcc-12 g++-12
    fi
}

function install_llvm() {
    _install_prerequisites() {
        apt-get update -y
        apt-get install -y \
            wget lsb-release wget software-properties-common gnupg
    }

    _install_llvm() {
        local version=$1

        local Directory=$(mktemp -d /tmp/llvm.XXXXXX)
        pushd "${Directory}"

        wget https://apt.llvm.org/llvm.sh
        chmod +x llvm.sh && ./llvm.sh "$1" all

        popd
        rm -rf "${Directory}"
    }

    _register_llvm() {
        local version=$1
        local priority=$2

        update-alternatives \
            --verbose \
            --install /usr/local/bin/llvm-config llvm-config /usr/bin/llvm-config-"${version}" "${priority}" \
            --slave /usr/local/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-"${version}" \
            --slave /usr/local/bin/llvm-as llvm-as /usr/bin/llvm-as-"${version}" \
            --slave /usr/local/bin/llvm-bcanalyzer llvm-bcanalyzer /usr/bin/llvm-bcanalyzer-"${version}" \
            --slave /usr/local/bin/llvm-cov llvm-cov /usr/bin/llvm-cov-"${version}" \
            --slave /usr/local/bin/llvm-diff llvm-diff /usr/bin/llvm-diff-"${version}" \
            --slave /usr/local/bin/llvm-dis llvm-dis /usr/bin/llvm-dis-"${version}" \
            --slave /usr/local/bin/llvm-dwarfdump llvm-dwarfdump /usr/bin/llvm-dwarfdump-"${version}" \
            --slave /usr/local/bin/llvm-extract llvm-extract /usr/bin/llvm-extract-"${version}" \
            --slave /usr/local/bin/llvm-link llvm-link /usr/bin/llvm-link-"${version}" \
            --slave /usr/local/bin/llvm-mc llvm-mc /usr/bin/llvm-mc-"${version}" \
            --slave /usr/local/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-"${version}" \
            --slave /usr/local/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-"${version}" \
            --slave /usr/local/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-"${version}" \
            --slave /usr/local/bin/llvm-readobj llvm-readobj /usr/bin/llvm-readobj-"${version}" \
            --slave /usr/local/bin/llvm-rtdyld llvm-rtdyld /usr/bin/llvm-rtdyld-"${version}" \
            --slave /usr/local/bin/llvm-size llvm-size /usr/bin/llvm-size-"${version}" \
            --slave /usr/local/bin/llvm-stress llvm-stress /usr/bin/llvm-stress-"${version}" \
            --slave /usr/local/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-"${version}" \
            --slave /usr/local/bin/llvm-tblgen llvm-tblgen /usr/bin/llvm-tblgen-"${version}" \
            --slave /usr/local/bin/llvm-objcopy llvm-objcopy /usr/bin/llvm-objcopy-"${version}" \
            --slave /usr/local/bin/llvm-strip llvm-strip /usr/bin/llvm-strip-"${version}"

        update-alternatives \
            --verbose \
            --install /usr/local/bin/clang clang /usr/bin/clang-"${version}" "${priority}" \
            --slave /usr/local/bin/clang++ clang++ /usr/bin/clang++-"${version}" \
            --slave /usr/local/bin/asan_symbolize asan_symbolize /usr/bin/asan_symbolize-"${version}" \
            --slave /usr/local/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-"${version}" \
            --slave /usr/local/bin/clang-check clang-check /usr/bin/clang-check-"${version}" \
            --slave /usr/local/bin/clang-cl clang-cl /usr/bin/clang-cl-"${version}" \
            --slave /usr/local/bin/ld.lld ld.lld /usr/bin/ld.lld-"${version}" \
            --slave /usr/local/bin/lld lld /usr/bin/lld-"${version}" \
            --slave /usr/local/bin/lld-link lld-link /usr/bin/lld-link-"${version}" \
            --slave /usr/local/bin/clang-format clang-format /usr/bin/clang-format-"${version}" \
            --slave /usr/local/bin/clang-format-diff clang-format-diff /usr/bin/clang-format-diff-"${version}" \
            --slave /usr/local/bin/clang-include-fixer clang-include-fixer /usr/bin/clang-include-fixer-"${version}" \
            --slave /usr/local/bin/clang-offload-bundler clang-offload-bundler /usr/bin/clang-offload-bundler-"${version}" \
            --slave /usr/local/bin/clang-query clang-query /usr/bin/clang-query-"${version}" \
            --slave /usr/local/bin/clang-rename clang-rename /usr/bin/clang-rename-"${version}" \
            --slave /usr/local/bin/clang-reorder-fields clang-reorder-fields /usr/bin/clang-reorder-fields-"${version}" \
            --slave /usr/local/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-"${version}" \
            --slave /usr/local/bin/lldb lldb /usr/bin/lldb-"${version}" \
            --slave /usr/local/bin/lldb-server lldb-server /usr/bin/lldb-server-"${version}" \
            --slave /usr/local/bin/clangd clangd /usr/bin/clangd-"${version}"
    }

    local version
    version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
    version=${version%%.*} # get the main version number

    _install_prerequisites

    if [ "$version" -ge 20 ]; then
        _install_llvm 17
        _register_llvm 17 1
    else
        echo "can not install latest llvm version"
        apt-get install -y clang lldb lld
    fi

    clang --version
    which clang
}

function install_cmake() {
    apt-get update -y
    apt-get install -y wget
    apt-get remove -y cmake || true

    local version
    version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
    version=${version%%.*} # get the main version number

    if [ "$version" -ge 20 ]; then
        local Directory=$(mktemp -d /tmp/cmake.XXXXXX)
        pushd "${Directory}"
        wget https://apt.kitware.com/kitware-archive.sh
        chmod +x kitware-archive.sh && ./kitware-archive.sh
        popd
        rm -rf "${Directory}"
    fi

    apt-get install -y cmake
    cmake --version
    which cmake
}

function install_go() {
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

function install_python() {
    apt-get update -y
    apt-get install -y python-is-python3 python-dev-is-python3
}

function install_docker() {

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

function config_shell() {
    sed -i 's/\(required\)\(.*pam_shells.so\)/sufficient\2/g' /etc/pam.d/chsh
    chsh -s /bin/bash
}

function install_tmux() {
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

function install_git() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    apt-get update -y
    apt-get install -y git
}

function install_fish() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:fish-shell/release-3
    apt-get update -y
    apt-get install -y fish
}

function install_vim() {

    apt-get update -y
    apt-get install -y vim

    local Directory=$(mktemp -d /tmp/vim.XXXXXX)

    pushd "${Directory}"
    git clone --depth=1 https://github.com/sqjian/venv.git
    git clone --depth=1 https://github.com/amix/vimrc.git
    cat vimrc/vimrcs/basic.vim >/root/.vimrc
    cat venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc
    popd

    rm -rf "${Directory}"

    tee /etc/profile.d/vim.sh <<'EOF'
# shellcheck shell=sh

export EDITOR=$(which vim)
EOF
}

function main() {
    install_base_tools
    install_git
    install_fish
    install_gcc
    install_llvm
    install_cmake
    install_go
    install_python
    install_docker
    config_shell
    install_tmux
    install_vim
}

main
