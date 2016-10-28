#!/bin/bash

VERSION=7.0.8
LOCATION=/opt/php

CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn)
TAR_FILENAME=php-$VERSION.tar.gz
SRC_NAME=php-$VERSION

function is_installed() {
    if rpm -ql $1|grep -q 'not installed'; then
        return 1
    fi
    return 0
}

function yum_install() {
    for n in $*
    do
        if ! is_installed $n; then
            sudo yum install $n -y
        fi
    done
}

function download() {
    if [[ ! -f $TAR_FILENAME ]]; then
        wget -c http://php.net/get/$TAR_FILENAME/from/this/mirror -O $TAR_FILENAME
    fi
}

function compile() {
    if [[ ! -f $TAR_FILENAME ]]; then
        return
    fi

    if [[ ! -d $SRC_NAME ]]; then
        tar zxvf $TAR_FILENAME
    fi

    if [[ ! -d $LOCATION ]]; then
        cd $SRC_NAME
        ./configure --prefix=/opt/php \
            --with-config-file-path=/usr/local/etc \
            --with-pdo-mysql \
            --with-mysqli \
            --with-gd \
            --with-jpeg-dir \
            --with-png-dir \
            --with-zlib \
            --with-curl \
            --with-mcrypt \
            --with-icu-dir=/usr \
            --with-fpm-user=$CURRENT_USER \
            --with-fpm-group=$CURRENT_GROUP \
            --with-libxml-dir \
            --with-openssl \
            --enable-fpm \
            --enable-mysqlnd \
            --enable-zip \
            --enable-mbstring \
            --enable-opcache \
            --enable-sockets \
            --enable-intl \
            --enable-exif \
            --enable-gd-native-ttf \
            --disable-ipv6 \
            --disable-rpath
        make
        sudo make install

        if [[ ! -d $LOCATION ]]; then
            return
        fi

        sudo cp php.ini-development $LOCATION/lib/php.ini
        sudo cp sapi/fpm/init.d.php-fpm $LOCATION/sbin/php-fpm.sh
        sudo cp $LOCATION/etc/php-fpm.conf.default $LOCATION/etc/php-fpm.conf
        sudo cp $LOCATION/etc/php-fpm.d/www.conf.default $LOCATION/etc/php-fpm.d/www.conf
    fi

}

function do_init() {
    yum_install gcc-c++ autoconf libicu libicu-devel libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel libmcrypt-devel
}

function do_install() {
    download
    compile
}

function do_config() {
    if [[ -f $LOCATION/sbin/php-fpm.sh ]]; then
        sudo chmod +x $LOCATION/sbin/php-fpm.sh
    fi

    if [[ -f $LOCATION/lib/php.ini ]]; then
        sudo sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/' $LOCATION/lib/php.ini
    fi
}

do_init
do_install
do_config
