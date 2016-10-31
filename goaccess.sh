#!/bin/bash

VERSION=1.0.2
LOCATION=/opt/goaccess

CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn)
TAR_FILENAME=goaccess-$VERSION.tar.gz
SRC_NAME=goaccess-$VERSION

function download() {
    if [[ ! -f $TAR_FILENAME ]]; then
        wget -c http://tar.goaccess.io/$TAR_FILENAME
    fi
}

function do_init() {
    sudo yum install ncurses-devel geoip-devel -y
}

function do_install() {
    download
    if [[ -f $TAR_FILENAME ]]; then
        tar zxvf $TAR_FILENAME
    fi
    if [[ -d  $SRC_NAME ]]; then
        cd $SRC_NAME
        ./configure --prefix=$LOCATION \
            --enable-geoip \
            --enable-utf8
        make
        sudo make install
    fi
}

function do_config() {
    if [[ ! -f $LOCATION/etc/goaccess.conf ]]; then
        exit 0
    fi

    if [[ ! -f $LOCATION/etc/goaccess.conf.bak ]]; then
        sudo cp $LOCATION/etc/goaccess.conf $LOCATION/etc/goaccess.conf.bak
    fi

    sudo sed -i 's/#time-format %H:%M:%S/time-format %H:%M:%S/' $LOCATION/etc/goaccess.conf
    sudo sed -i 's/#date-format %d\/%b\/%Y/date-format %d\/%b\/%Y/' $LOCATION/etc/goaccess.conf
    sudo sed -i 's/#log-format %h %^\[%d:%t %^\] "%r" %s %b "%R" "%u"/log-format %h %^\[%d:%t %^\] "%r" %s %b "%R" "%u"/' $LOCATION/etc/goaccess.conf

}


do_init
do_install
do_config
