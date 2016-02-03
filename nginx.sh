#!/bin/bash

# custom nginx version
FILE_NAME='nginx-1.9.10.tar.gz'
# install location
OPT_PATH='/opt/nginx'

CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn)
IFS='.' read -a FILE_NAMES <<< "${FILE_NAME}"
FOLDER_NAME=`(IFS=.; echo "${FILE_NAMES[*]:0:3}")`

function do_init() {
    sudo yum install pcre-devel openssl-devel -y

    if [[ ! -d ${OPT_PATH} ]]; then
        sudo mkdir ${OPT_PATH}
        sudo chown ${CURRENT_USER}:${CURRENT_GROUP} ${OPT_PATH}
    fi

    if [[ ! -d /var/log/nginx ]]; then
        sudo mkdir /var/log/nginx
    fi

    if [[ ! -f ${FILE_NAME} ]]; then
        wget -c http://nginx.org/download/${FILE_NAME}
    fi

    if [[ -f ${FILE_NAME} ]]; then
        if [[ ! -d  ${FOLDER_NAME} ]]; then
            tar zxvf ${FILE_NAME}
        fi
    fi
}

function do_install() {
    if [[ -d ${FOLDER_NAME} ]]; then
        cd ${FOLDER_NAME}
        ./configure --prefix=${OPT_PATH} \
            --user=${CURRENT_USER} \
            --group=${CURRENT_GROUP} \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --with-http_ssl_module \
            --with-http_v2_module
        ${CURRENT_GROUP}
        make
        make install
    fi
}

function do_config() {
    if [[ -d "${OPT_PATH}/conf" ]]; then
        cd ${OPT_PATH}/conf
        if [[ ! -d ${OPT_PATH}/conf/conf.d ]]; then
            mkdir conf.d
            cp nginx.conf.default nginx.conf
            sed -i '/http {/a \ \ \ \ server_tokens off;' nginx.conf
            sed -i '$i \ \ \ \ include conf.d/*.conf;' nginx.conf
        fi
    fi
}


do_init
do_install
do_config
