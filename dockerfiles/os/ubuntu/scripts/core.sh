#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

function update() {
    apt-get update -y
}

function install_tools() {
    apt-get install -y \
        binutils \
        inetutils-ping \
        iproute2 \
        gawk \
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
        sshpass \
        texinfo \
        lrzsz \
        aria2 \
        p7zip-full p7zip-rar \
        ffmpeg \
        sqlite3 \
        psmisc \
        file \
        procps \
        telnet

    apt-get install -y \
        build-essential \
        checkinstall \
        gdb \
        cmake

    apt-get install -y \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libbz2-dev \
        libffi-dev \
        libxml2-dev \
        liblzma-dev \
        libgoogle-perftools-dev \
        nghttp2 \
        libnghttp2-dev

    apt-get install -y \
        libx11-dev \
        libxext-dev \
        libxtst-dev \
        libxrender-dev \
        libxmu-dev \
        libxmuu-dev \
        libc6-dev \
        libxcb1-dev \
        libaio-dev

    apt-get install -y \
        vim \
        tmux

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

install_extra_tools() {
    apt-get install -y \
        libsndfile1 \
        libsndfile1-dev \
        libflac-dev

    apt-get install -y \
        libjpeg-turbo8-dev \
        zlib1g-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libharfbuzz-dev \
        libfribidi-dev

    apt-get install -y \
        tcl \
        tcl-dev \
        tk-dev \
        dejagnu \
        libncursesw5-dev \
        libmpich-dev
}

function install_git() {
    apt-get update -y
    apt-get remove -y git git-lfs || true
    apt-get install -y \
        curl \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg-agent

    add-apt-repository -y ppa:git-core/ppa
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
    apt-get update -y
    apt-get install -y git git-lfs
}
function install_shell() {

    function install_zsh() {
        apt-get update -y
        apt-get install -y zsh wget git sed

        local Directory
        Directory=$(mktemp -d /tmp/zsh.XXXXXX)

        pushd "${Directory}" || exit
        rm -rf /root/.oh-my-zsh /root/.zshrc
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh
        cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
        sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="ys"/' /root/.zshrc
        popd || exit
        rm -rf "${Directory}"
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

    install_zsh
    install_fish
}

function install_programming_languages() {
    function install_go() {
        apt-get update -y
        apt-get install -y curl git jq

        # Get latest version and architecture information
        local go_ver
        go_ver=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')

        local go_arch
        case $(uname -m) in
        x86_64) go_arch="amd64" ;;
        aarch64) go_arch="arm64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            return 1
            ;;
        esac

        # Download and install
        local go_url="https://dl.google.com/go/${go_ver}.linux-${go_arch}.tar.gz"
        local go_dir="/usr/local"

        rm -rf "${go_dir}/go"
        curl --retry 3 -L -o /tmp/go.tgz "$go_url"
        tar xzf /tmp/go.tgz -C "${go_dir}"
        rm -f /tmp/go.tgz

        echo "Go ${go_ver} installed successfully."

        # Configure environment variables
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

        # Update alternatives
        update-alternatives --remove-all go 2>/dev/null || true
        update-alternatives --remove-all gofmt 2>/dev/null || true

        update-alternatives --install /usr/local/bin/go go "/usr/local/go/bin/go" 1 \
            --slave /usr/local/bin/gofmt gofmt "/usr/local/go/bin/gofmt"

        update-alternatives --auto go
        update-alternatives --display go

        /usr/local/go/bin/go version
    }

    function install_conda() {
        apt-get update -y
        apt-get install -y wget

        # Determine download URL
        local conda_url
        case "$(uname -m)" in
        x86_64) conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" ;;
        aarch64) conda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh" ;;
        *)
            echo "Unsupported architecture: $(uname -m)"
            return 1
            ;;
        esac

        # Download and install
        local temp_dir
        temp_dir=$(mktemp -d /tmp/conda.XXXXXX)

        wget -q -O "${temp_dir}/Miniconda3-latest.sh" "$conda_url"
        bash "${temp_dir}/Miniconda3-latest.sh" -b -p /usr/local/conda
        rm -rf "${temp_dir}"

        # Configure conda
        /usr/local/conda/bin/conda init --all
        /usr/local/conda/bin/conda config --set auto_activate_base false
        /usr/local/conda/bin/conda config --set pip_interop_enabled True
        /usr/local/conda/bin/conda clean -a -y
    }

    install_go
    install_conda
}

function main() {
    update
    install_locales
    install_shell
    install_git
    install_tools
    install_programming_languages
}

main
