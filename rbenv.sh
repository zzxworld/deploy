#!/bin/bash

RB_VERSION=2.3.1
CN_MIRROR=https://gems.ruby-china.org/

function do_init() {
    sudo yum install gcc -y
}

function do_install() {
    if [[ ! -d ~/.rbenv ]]; then
        git clone git://github.com/sstephenson/rbenv.git --depth=1 .rbenv
    fi

    if [[ ! -d ~/.rbenv/plugins/ruby-build ]]; then
        git clone git://github.com/sstephenson/ruby-build.git --depth=1 ~/.rbenv/plugins/ruby-build
    fi

    if [[ ! -d ~/.rbenv/plugins/ruby-china-mirror ]]; then
        git clone https://github.com/andorchen/rbenv-china-mirror.git --depth=1 ~/.rbenv/plugins/rbenv-china-mirror
    fi

    if [[ ! -f ~/.gemrc ]]; then
        echo "gem: --no-document" > ~/.gemrc
    fi

    if grep -Fq rbenv ~/.bash_profile
    then
        echo 'WARING: rbenv is exists!'
    else
        echo '' >> ~/.bash_profile
        echo '# rbenv support start' >> ~/.bash_profile
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
        echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
        echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
        echo '# rbenv support end' >> ~/.bash_profile
    fi

    ~/.rbenv/bin/rbenv install -v ${RB_VERSION}
    ~/.rbenv/bin/rbenv global ${RB_VERSION}
}

function do_config() {
    echo 'install rbenv successful.'
}


do_init
do_install
do_config
