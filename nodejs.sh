#!/bin/bash

function npm_is_installed() {
    if rpm -ql npm|grep -q 'not installed'; then
        return 1
    fi
    return 0
}

function install_nodejs() {
    if rpm -ql nodejs|grep -q 'not installed'; then
        sudo yum install nodejs -y
    fi
}

function install_npm() {
    if ! npm_is_installed; then
        sudo yum install npm -y
    fi
}


function do_init() {
    if rpm -ql epel-release|grep -q 'not installed'; then
        sudo yum install epel-release -y
    fi
}

function do_install() {
    install_nodejs
    install_npm
}

function do_config() {
    if npm_is_installed; then
        sudo npm cache clean -f
        sudo npm i n -g
        sudo n stable
    fi
}

do_init
do_install
do_config
