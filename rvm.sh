#!/bin/bash

RB_VERSION=2.3.0
CN_MIRROR=https://ruby.taobao.org/

function do_init() {
    sudo yum -y install nodejs libcurl-devel
}

function do_install() {
    if [[ ! -d ~/.rvm ]]; then
        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        curl -sSL https://get.rvm.io | bash -s stable --ruby=${RB_VERSION}
    fi
}

function do_config() {
    if [[ -d ~/.rvm ]]; then
        source ~/.profile
        rvm default

        # change gem mirror to china
        gem source -r https://rubygems.org/
        gem source -a ${CN_MIRROR}
    fi
}


do_init
do_install
do_config
