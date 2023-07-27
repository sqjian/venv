#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

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

install_llvm
