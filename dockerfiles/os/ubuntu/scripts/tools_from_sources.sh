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
    sed -i 's/^# deb/deb/g' /etc/apt/sources.list
    apt-get update -y
}

function install_llvm_from_ppa() {
    version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
    version=${version%%.*} # get the main version number

    install_prerequisites() {
        apt-get update -y
        apt-get install -y \
            wget lsb-release wget software-properties-common gnupg
    }

    install_llvm() {
        local version=$1

        local Directory=$(mktemp -d /tmp/curl.XXXXXX)
        pushd "${Directory}"

        wget https://apt.llvm.org/llvm.sh
        chmod +x llvm.sh && ./llvm.sh "$1" all

        popd
        rm -rf "${Directory}"
    }

    register_llvm() {
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

    if [ "$version" -ge 20 ]; then
        install_prerequisites
        install_llvm 16
        register_llvm 16 1

        apt-get remove -y clang lldb lld || true
    else
        echo "can not install latest llvm version"
        apt-get install -y clang lldb lld
    fi

    clang --version
    which clang
}

function install_cmake_from_source() {
    apt-get update -y
    apt-get install -y wget gzip curl git openssl libssl-dev coreutils build-essential

    check_command clang
    check_command lldb
    check_command lld

    wget -qO /usr/local/bin/ninja.gz https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip
    gunzip -f /usr/local/bin/ninja.gz
    chmod a+x /usr/local/bin/ninja
    ninja --version

    local Directory=$(mktemp -d /tmp/cmake.XXXXXX)

    if [ -d "$Directory" ]; then
        echo "Directory $Directory exists. Removing and recreating it..."
        rm -rf "$Directory"
        mkdir "$Directory"
    else
        echo "Directory $Directory does not exist. Creating it..."
        mkdir -p "$Directory"
    fi

    curl -so- https://cmake.org/files/v3.26/cmake-3.26.4.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -

    pushd "${Directory}"
    ./bootstrap --prefix=/usr/local
    make -j "$(nproc)"
    make install
    popd

    rm -rf "${Directory}"

    apt-get remove -y cmake || true

    cmake --version
    which cmake
}

function install_python_from_source() {
    build_python_from_source() {
        apt-get update -y
        apt-get install -y \
            make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev coreutils

        check_command g++
        check_command gcc
        check_command clang

        local Directory=$(mktemp -d /tmp/python.XXXXXX)

        if [ -d "$Directory" ]; then
            echo "Directory $Directory exists. Removing and recreating it..."
            rm -rf "$Directory"
            mkdir "$Directory"
        else
            echo "Directory $Directory does not exist. Creating it..."
            mkdir -p "$Directory"
        fi

        curl -so- https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz | tar --strip-components 1 -C "${Directory}" -xzf -
        pushd "${Directory}"
        ./configure \
            --enable-optimizations \
            --with-lto \
            --with-computed-gotos \
            --with-system-ffi \
            --with-ensurepip=install \
            --prefix=/opt/python

        make -j "$(nproc)"
        make altinstall
        popd
        rm -rf "${Directory}"

        ldconfig

        /opt/python/bin/python3.11 -m pip install --upgrade pip setuptools wheel
    }

    update_alternatives() {

        rm -rf /usr/local/bin/{python,pip,pydoc,python-config} || true

        python="/opt/python/bin/python3.11"
        pip="/opt/python/bin/pip3.11"
        pydoc="/opt/python/bin/pydoc3.11"
        python_config="/opt/python/bin/python3.11-config"

        update-alternatives --remove-all pip || true
        update-alternatives --remove-all python || true
        update-alternatives --remove-all pydoc || true
        update-alternatives --remove-all python-config || true

        update-alternatives --install /usr/local/bin/python python "${python}" 1 \
            --slave /usr/local/bin/pip pip "${pip}" \
            --slave /usr/local/bin/pydoc pydoc "${pydoc}" \
            --slave /usr/local/bin/python-config python-config "${python_config}" || (echo "set python alternatives failed" && exit 1)

        update-alternatives --auto python
        update-alternatives --display python

        apt-get remove -y python-dev python3 || true

        python --version
        which python
    }

    build_python_from_source
    update_alternatives

}
function install_curl_from_source() {
    apt-get update -y
    apt-get install -y curl git openssl libssl-dev coreutils libtool libtool-bin

    check_command g++
    check_command gcc

    local Directory=$(mktemp -d /tmp/curl.XXXXXX)

    if [ -d "$Directory" ]; then
        echo "Directory $Directory exists. Removing and recreating it..."
        rm -rf "$Directory"
        mkdir "$Directory"
    else
        echo "Directory $Directory does not exist. Creating it..."
        mkdir -p "$Directory"
    fi

    curl -so- https://curl.se/download/curl-8.1.2.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -
    pushd "${Directory}"
    ./configure --with-openssl --prefix=/usr/local
    make -j "$(nproc)"
    make install
    popd
    rm -rf "${Directory}"

    (libtool --finish /usr/local/lib && ldconfig) || (echo "curl lib set failed" && exit 1)

    apt-get remove -y curl || true

    ldconfig

    curl --version
    which curl
}

function main() {
    update
    install_llvm_from_ppa
    install_cmake_from_source
    install_python_from_source
    install_curl_from_source
}

main
