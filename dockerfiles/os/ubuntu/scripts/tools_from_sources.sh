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
    apt-get upgrade -y
}

function dev_tools_from_source() {
    install_gcc_from_source() {
        apt-get update -y
        apt-get install -y wget curl libipt-dev zlib1g-dev coreutils libtool libtool-bin
        apt-get install -y gcc g++ libc6-dev gnat gdc python3 bash gawk binutils gzip bzip2 make tar perl libgmp-dev libmpfr-dev libmpc-dev libisl-dev

        local Directory=$(mktemp -d /tmp/gcc.XXXXXX)

        if [ -d "$Directory" ]; then
            echo "Directory $Directory exists. Removing and recreating it..."
            rm -rf "$Directory"
            mkdir "$Directory"
        else
            echo "Directory $Directory does not exist. Creating it..."
            mkdir -p "$Directory"
        fi
        mkdir -p "${Directory}"/{src,build}

        curl -so- https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz | tar --strip-components 1 -C "${Directory}"/src -xzf -
        pushd "${Directory}"
        cd src
        ./contrib/download_prerequisites || exit 1
        cd ../build
        (../src/configure \
            --build=x86_64-linux-gnu \
            --host=x86_64-linux-gnu \
            --target=x86_64-linux-gnu \
            --prefix=/usr/local \
            --with-gcc-major-version-only \
            --enable-checking=release \
            --enable-threads=posix \
            --enable-__cxa_atexit \
            --enable-clocale=gnu \
            --enable-nls \
            --disable-multilib \
            --enable-shared \
            --enable-newlib-io-long-long \
            --disable-bootstrap \
            --enable-default-pie \
            --with-tune=generic \
            --enable-gnu-unique-object \
            --enable-plugin \
            --with-default-libstdcxx-abi=new \
            --enable-libstdcxx-debug \
            --enable-libstdcxx-time=yes \
            --with-system-zlib \
            --with-target-system-zlib=auto \
            --enable-languages=c,c++,go \
            --without-cuda-driver \
            --without-included-gettext \
            --disable-vtable-verify \
            --with-pic || (echo "gcc configure failed" && exit 1)) &&
            (make -j "$(nproc)" || (echo "gcc compile failed" && exit 1)) &&
            (make install || (echo "gcc install failed" && exit 1))
        popd
        rm -rf "${Directory}"

        (libtool --finish /usr/local/libexec/gcc/x86_64-linux-gnu/13 && ldconfig) || (echo "gcc lib set failed" && exit 1)
        echo '/usr/local/lib64' >>/etc/ld.so.conf.d/libc.conf && ldconfig
        apt-get remove -y gcc g++ || true

        gcc --version
        which gcc
    }

    install_cmake_from_source() {
        apt-get update -y
        apt-get install -y wget gzip curl git openssl libssl-dev coreutils

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
                make \
                libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev
            apt-get install -y python python-pip python3 python3-pip coreutils

            check_command g++
            check_command gcc

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

            /opt/python/bin/python3.11 -m pip install --upgrade pip setuptools wheel
        }

        update_alternatives() {
            rm -rf /usr/local/bin/{python,python2,python3}
            rm -rf /usr/local/bin/{pip,pip2,pip3}
            rm -rf /usr/local/bin/{pydoc,pydoc2,pydoc3}
            rm -rf /usr/local/bin/{python-config,python2-config,python3-config}

            python2="$(readlink -f "$(which python2)")"
            pip2="$(readlink -f "$(which pip)")"
            pydoc2="$(readlink -f "$(which pydoc2.7)")"
            python2_config="$(readlink -f "$(which python2-config)")"

            python3="$(readlink -f "$(which python3)")"
            pip3="$(readlink -f "$(which pip3)")"
            pydoc3="$(readlink -f "$(which pydoc3)")"
            python3_config="$(readlink -f "$(which python3-config)")"

            py_custom="/opt/python/bin/python3.11"
            pip_custom="/opt/python/bin/pip3.11"
            pydoc_custom="/opt/python/bin/pydoc3.11"
            python_config_custom="/opt/python/bin/python3.11-config"

            # -----------------------------------------------------------

            update-alternatives --remove-all pip2 || true
            update-alternatives --remove-all python2 || true
            update-alternatives --remove-all pydoc2 || true
            update-alternatives --remove-all python2-config || true

            update-alternatives --install /usr/local/bin/python2 python2 "${python2}" 1 \
                --slave /usr/local/bin/pip2 pip2 "${pip2}" \
                --slave /usr/local/bin/pydoc2 pydoc2 "${pydoc2}" \
                --slave /usr/local/bin/python2-config python2-config "${python2_config}" || (echo "set python2 alternatives failed" && exit 1)

            update-alternatives --auto python2
            update-alternatives --display python2

            # -----------------------------------------------------------

            update-alternatives --remove-all pip3 || true
            update-alternatives --remove-all python3 || true
            update-alternatives --remove-all pydoc3 || true
            update-alternatives --remove-all python3-config || true

            update-alternatives --install /usr/local/bin/python3 python3 "${python3}" 1 \
                --slave /usr/local/bin/pip3 pip3 "${pip3}" \
                --slave /usr/local/bin/pydoc3 pydoc3 "${pydoc3}" \
                --slave /usr/local/bin/python3-config python3-config "${python3_config}" ||
                (echo "set python3 alternatives failed" && exit 1)

            update-alternatives --install /usr/local/bin/python3 python3 "${py_custom}" 2 \
                --slave /usr/local/bin/pip3 pip3 "${pip_custom}" \
                --slave /usr/local/bin/pydoc3 pydoc3 "${pydoc_custom}" \
                --slave /usr/local/bin/python3-config python3-config "${python_config_custom}" || (echo "set python3 alternatives failed" && exit 1)

            update-alternatives --auto python3
            update-alternatives --display python3

            # -----------------------------------------------------------

            update-alternatives --remove-all pip || true
            update-alternatives --remove-all python || true
            update-alternatives --remove-all pydoc || true
            update-alternatives --remove-all python-config || true

            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python2 1 \
                --slave /usr/local/bin/pip pip /usr/local/bin/pip2 \
                --slave /usr/local/bin/pydoc pydoc /usr/local/bin/pydoc2 \
                --slave /usr/local/bin/python-config python-config /usr/local/bin/python2-config || (echo "set python alternatives failed" && exit 1)

            update-alternatives --install /usr/local/bin/python python /usr/local/bin/python3 2 \
                --slave /usr/local/bin/pip pip /usr/local/bin/pip3 \
                --slave /usr/local/bin/pydoc pydoc /usr/local/bin/pydoc3 \
                --slave /usr/local/bin/python-config python-config /usr/local/bin/python3-config || (echo "set python alternatives failed" && exit 1)

            update-alternatives --auto python
            update-alternatives --display python

            python --version
            which python
        }

        build_python_from_source
        update_alternatives

    }

    install_gdb_from_source() {
        apt-get update -y
        apt-get install -y wget curl coreutils

        local Directory=$(mktemp -d /tmp/gdb.XXXXXX)

        if [ -d "$Directory" ]; then
            echo "Directory $Directory exists. Removing and recreating it..."
            rm -rf "$Directory"
            mkdir "$Directory"
        else
            echo "Directory $Directory does not exist. Creating it..."
            mkdir -p "$Directory"
        fi

        curl -so- https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.gz | tar --strip-components 1 -C "${Directory}" -xzf -
        pushd "${Directory}"
        ./configure --with-python=/usr/local/bin/python --prefix=/usr/local || (echo "gdb configure failed" && exit 1)
        make -j "$(nproc)" || (echo "gdb compile failed" && exit 1)
        make install || (echo "gdb install failed" && exit 1)
        popd
        rm -rf "${Directory}"
        apt-get remove -y gdb || true

        gdb --version
        which gdb
    }

    install_gcc_from_source
    install_cmake_from_source
    install_python_from_source
    install_gdb_from_source
}

function useful_tools_from_source() {
    install_vim_from_source() {
        apt-get update -y
        apt-get install -y curl git openssl libssl-dev coreutils vim
        apt-get install -y libncurses5-dev libperl-dev python-dev ruby-dev mercurial checkinstall lua5.2 liblua5.2-dev

        check_command g++
        check_command gcc

        local Directory=$(mktemp -d /tmp/vim.XXXXXX)

        if [ -d "$Directory" ]; then
            echo "Directory $Directory exists. Removing and recreating it..."
            rm -rf "$Directory"
            mkdir "$Directory"
        else
            echo "Directory $Directory does not exist. Creating it..."
            mkdir -p "$Directory"
        fi

        pushd "${Directory}"
        git clone --depth=1 https://github.com/vim/vim.git .
        cd src
        ./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp \
            --enable-pythoninterp=yes \
            --enable-python3interp=yes \
            --enable-perlinterp \
            --enable-luainterp \
            --enable-cscope \
            --enable-gui=auto \
            --enable-gtk2-check \
            --with-compiledby="j.jith" \
            --prefix=/usr/local
        make -j "$(nproc)"
        make install
        cd ..
        popd
        rm -rf "${Directory}"

        tee /etc/profile.d/vim.sh <<'EOF'
# shellcheck shell=sh

export EDITOR=$(which vim)
EOF

        if [ -d "$Directory" ]; then
            echo "Directory $Directory exists. Removing and recreating it..."
            rm -rf "$Directory"
            mkdir "$Directory"
        else
            echo "Directory $Directory does not exist. Creating it..."
            mkdir -p "$Directory"
        fi

        pushd "${Directory}"
        git clone --depth=1 https://github.com/sqjian/venv.git
        git clone --depth=1 https://github.com/amix/vimrc.git
        cat vimrc/vimrcs/basic.vim >/root/.vimrc
        cat venv/dockerfiles/os/ubuntu/scripts/internal/vimrc >>/root/.vimrc
        popd
        rm -rf "${Directory}"

        apt-get remove -y vim || true

        vim --version
        which vim
    }
    install_curl_from_source() {
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

        curl --version
        which curl
    }
    install_vim_from_source
    install_curl_from_source
}

function main() {
    update
    dev_tools_from_source
    useful_tools_from_source
}

main
