#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 not found"
        exit 1
    else
        echo "$1 found"
    fi
}

function update() {
    apt-get update -y
}

function install_tools() {
    # base tools
    apt-get install -y \
        binutils \
        inetutils-ping \
        iproute2 \
        telnet \
        gawk \
        unzip \
        wget \
        curl \
        jq \
        rsync \
        dos2unix \
        tree \
        pkg-config \
        makeself \
        socat \
        zip unzip \
        fish \
        sshpass \
        texinfo \
        lrzsz \
        aria2 \
        p7zip-full p7zip-rar \
        telnet

    # Development Tools
    apt-get install -y \
        checkinstall \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libbz2-dev \
        libffi-dev \
        libxml2-dev \
        liblzma-dev \
        libgoogle-perftools-dev \
        gcc g++ gdb

    # System Libraries
    apt-get install -y \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libaio-dev \
        libssl-dev

}

function install_git() {
    apt-get update -y
    apt-get install -y \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        curl

    add-apt-repository -y ppa:git-core/ppa
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-get update -y
    apt-get install -y git git-lfs
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

function install_zsh() {
    apt-get update -y
    apt-get install -y zsh wget git sed

    local Directory
    Directory=$(mktemp -d /tmp/zsh.XXXXXX)

    pushd "${Directory}"
    rm -rf /root/.oh-my-zsh /root/.zshrc
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="ys"/' /root/.zshrc
    popd
    rm -rf "${Directory}"
}

function install_go() {
    _install_go() {
        apt-get update -y
        apt-get install -y \
            curl \
            git \
            graphviz \
            jq
        local _go_ver
        _go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
        local _go_os=linux
        local _go_arch

        # 检测系统架构并设置 _go_arch 变量
        case $(uname -m) in
        x86_64)
            _go_arch="amd64"
            ;;
        aarch64)
            _go_arch="arm64"
            ;;
        *)
            echo "Unsupported architecture"
            return 1
            ;;
        esac

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

    _update_alternatives() {

        update-alternatives --remove-all go || true
        update-alternatives --remove-all gofmt || true

        update-alternatives --install /usr/local/bin/go go "/usr/local/go/bin/go" 1 \
            --slave /usr/local/bin/gofmt gofmt "/usr/local/go/bin/gofmt" || (echo "set go alternatives failed" && exit 1)

        update-alternatives --auto go
        update-alternatives --display go

        go version
        which go
    }

    _install_go
    _update_alternatives

}

function install_vim() {
    apt-get update -y
    apt-get install -y vim

    local Directory
    Directory=$(mktemp -d /tmp/vim.XXXXXX)

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
function install_llvm() {
    _install_prerequisites() {
        apt-get update -y
        apt-get install -y \
            wget lsb-release software-properties-common gnupg
    }

    _install_llvm() {
        local version=$1

        local Directory
        Directory=$(mktemp -d /tmp/llvm.XXXXXX)

        pushd "${Directory}"

        wget https://apt.llvm.org/llvm.sh
        chmod +x llvm.sh && ./llvm.sh "$version" all

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

    if [ "$(uname -m)" = "x86_64" ]; then
        if [ "$version" -ge 20 ]; then
            _install_llvm 18
            _register_llvm 18 1
        else
            echo "Cannot install latest LLVM version on this OS version."
            apt-get install -y clang lldb lld
        fi
    else
        echo "Architecture is not amd64. Installing from apt source."
        apt-get install -y clang lldb lld
    fi

    clang --version
    which clang
}

function install_rust_tools() {
    install_tool() {
        local TOOL_NAME=$1
        local URL_AMD64=$2
        local URL_ARM64=$3
        local TMP_DIR

        apt-get update -y
        apt-get install -y wget curl dpkg

        TMP_DIR=$(mktemp -d /tmp/${TOOL_NAME}.XXXXXX)
        pushd "${TMP_DIR}"

        local ARCH
        ARCH=$(dpkg --print-architecture)

        case "$ARCH" in
        amd64)
            wget -O ${TOOL_NAME}.deb "${URL_AMD64}"
            dpkg -i ${TOOL_NAME}.deb
            ;;
        arm64)
            wget -O ${TOOL_NAME}.deb "${URL_ARM64}"
            dpkg -i ${TOOL_NAME}.deb
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
        esac

        popd
        rm -rf "${TMP_DIR}"
    }

    install_hyperfine() {
        local URL_AMD64="https://github.com/sharkdp/hyperfine/releases/download/v1.18.0/hyperfine_1.18.0_amd64.deb"
        local URL_ARM64="https://github.com/sharkdp/hyperfine/releases/download/v1.18.0/hyperfine_1.18.0_arm64.deb"
        install_tool "hyperfine" "${URL_AMD64}" "${URL_ARM64}"
    }

    install_hyperfine
}

function install_upx() {
    _install_upx() {
        apt-get update -y
        apt-get install -y curl xz-utils

        local Directory
        Directory=$(mktemp -d /tmp/upx.XXXXXX)

        pushd "${Directory}"

        if [ "$(uname -m)" = "x86_64" ]; then
            curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v4.2.4/upx-4.2.4-amd64_linux.tar.xz'
        elif [ "$(uname -m)" = "aarch64" ]; then
            curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v4.2.4/upx-4.2.4-arm64_linux.tar.xz'
        else
            echo "Unsupported architecture: $(uname -m)"
            exit 1
        fi

        mkdir -p /usr/local/upx
        tar -xJf upx.tar.xz --strip-components=1 -C /usr/local/upx
        popd

        rm -rf "${Directory}"
    }

    _update_alternatives() {

        rm -rf /usr/local/bin/upx || true

        update-alternatives --remove-all upx || true
        update-alternatives --install /usr/local/bin/upx upx "/usr/local/upx/upx" 1 || (echo "set upx alternatives failed" && exit 1)
        update-alternatives --auto upx
        update-alternatives --display upx

        upx --version
        which upx
    }

    _install_upx
    _update_alternatives
}

function install_locales() {
    apt-get update -y
    apt-get install -y locales
    locale-gen zh_CN.UTF-8
    tee /etc/profile.d/lang.sh <<'EOF'
export LC_ALL=zh_CN.utf-8
export LANG=zh_CN.utf-8
EOF
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
        check_command git
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

function install_docker_cli() {
    check_command curl

    apt-get update -y
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    # 添加 Docker 仓库
    # `arch=$(dpkg --print-architecture)` 自动设置正确的架构
    add-apt-repository -y \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # 安装 Docker CLI
    apt-get update -y && apt-get install -y docker-ce-cli

    # 检查 Ubuntu 版本并安装 skopeo
    ubuntu_version=$(lsb_release -rs)
    if dpkg --compare-versions "${ubuntu_version}" ge "22.04"; then
        apt-get install -y skopeo
    fi
}

function main() {
    update
    install_locales
    install_tools
    install_git
    install_zsh
    install_fish
    install_vim
    install_tmux
    install_llvm
    install_go
    install_rust_tools
    install_upx
    install_docker_cli
}

main
