#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive

ats=https://downloads.apache.org/trafficserver/trafficserver-9.2.1.tar.bz2

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
dpkg-reconfigure locales

# Install TrafficServer
# https://trafficserver.apache.org/downloads
# http://www-eu.apache.org/dist/trafficserver
mkdir /opt/ats_src
cd /opt/ats_src
curl -L ${ats} | tar -xj --strip-components 1
./configure --prefix=/opt/ats --with-user=nobody
make
make install
cd /opt/ats
bin/traffic_server -R 1

chmod 777 -R /opt/ats/var/trafficserver/
