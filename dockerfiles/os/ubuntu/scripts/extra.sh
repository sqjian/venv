#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

update() {
    echo "updata tools"
    apt-get update -y
}

install_extra_tools() {
    # Audio Libraries
    apt-get install -y \
        libsndfile1 \
        libsndfile1-dev \
        libflac-dev

    # Image Libraries
    apt-get install -y \
        libjpeg-turbo8-dev \
        zlib1g-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libharfbuzz-dev \
        libfribidi-dev

    # Tcl/Tk
    apt-get install -y \
        tcl \
        tcl-dev \
        tk-dev \
        dejagnu

    # Other
    apt-get install -y \
        libncursesw5-dev \
        libmpich-dev

}

function main() {
    update
    install_extra_tools
}

main
