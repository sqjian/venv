#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y \
            bzip2 \
            curl \
            lua5.3 \
            pkg-config \
            libtool \
            gcc \
            make \
            vim \
            locales \
            gosu

apt-get install -y \
            libssl-dev \
            libpcre3 \
            libpcre3-dev \
            libpcap-dev \
            flex \
            hwloc \
            libncurses5-dev \
            tcl \
            tcl-dev \
            libboost-dev
