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
        dstat \
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
        texinfo \
        lrzsz \
        dumb-init

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
        gcc g++ gdb

    # System Libraries
    apt-get install -y \
        libgl1-mesa-glx \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
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

    local Directory=$(mktemp -d /tmp/zsh.XXXXXX)
    pushd "${Directory}"
    rm -rf /root/.oh-my-zsh /root/.zshrc
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh
    cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="ys"/' /root/.zshrc
    popd
    rm -rf "${Directory}"
}

function install_go() {
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

    update_alternatives() {

        update-alternatives --remove-all go || true
        update-alternatives --remove-all gofmt || true

        update-alternatives --install /usr/local/bin/go go "/usr/local/go/bin/go" 1 \
            --slave /usr/local/bin/gofmt gofmt "/usr/local/go/bin/gofmt" || (echo "set go alternatives failed" && exit 1)

        update-alternatives --auto go
        update-alternatives --display go

        go version
        which go
    }

    install_go
    update_alternatives

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
        _install_llvm 16
        _register_llvm 16 1
    else
        echo "can not install latest llvm version"
        apt-get install -y clang lldb lld
    fi

    clang --version
    which clang
}

function install_rust_tools() {
    install_hyperfine() {
        apt-get update -y
        apt-get install -y wget

        local Directory=$(mktemp -d /tmp/hyperfine.XXXXXX)

        pushd "${Directory}"
        wget https://github.com/sharkdp/hyperfine/releases/download/v1.17.0/hyperfine_1.17.0_amd64.deb
        dpkg -i hyperfine_1.17.0_amd64.deb
        popd

        rm -rf "${Directory}"
    }

    install_ripgrep() {
        apt-get update -y
        apt-get install -y curl

        local Directory=$(mktemp -d /tmp/ripgrep.XXXXXX)

        pushd "${Directory}"
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
        dpkg -i ripgrep_13.0.0_amd64.deb
        popd

        rm -rf "${Directory}"
    }

    install_hyperfine
    install_ripgrep
}

function install_upx() {
    _install_upx() {
        apt-get update -y
        apt-get install -y curl xz-utils

        local Directory=$(mktemp -d /tmp/upx.XXXXXX)

        pushd "${Directory}"
        curl -o upx.tar.xz -L 'https://github.com/upx/upx/releases/download/v4.1.0/upx-4.1.0-amd64_linux.tar.xz'
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

function main() {
    update
    install_git
    install_fish
    install_tools
    install_zsh
    install_llvm
    install_go
    install_vim
    install_rust_tools
    install_upx
}

main
