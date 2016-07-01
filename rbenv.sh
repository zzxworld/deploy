#!/bin/bash

RUBY_VERSION=2.3.1
MIRROR=$1


function install_plugin_china_mirror() {
    if [[ ! -z "${MIRROR}" ]]; then
        WORD="ruby-china.org"
        echo "use mirror"
        if test "${MIRROR#*${WORD}}" != "${MIRROR}"
        then
            if [[ ! -d ~/.rbenv/plugins/rbenv-china-mirror ]]; then
                git clone https://github.com/andorchen/rbenv-china-mirror.git --depth=1 ~/.rbenv/plugins/rbenv-china-mirror
            fi
        fi
    fi
}

function install_ruby() {
    if [[ -f ~/.rbenv/bin/rbenv ]]; then
        ~/.rbenv/bin/rbenv install -v ${RUBY_VERSION}
        ~/.rbenv/bin/rbenv global ${RUBY_VERSION}
    fi
}

function install_gem() {
    if [[ -f ~/.rbenv/shims/ruby ]]; then
        git clone https://github.com/rubygems/rubygems.git --depth=1
        if [[ -d rubygems ]]; then
            cd rubygems
            ~/.rbenv/shims/ruby setup.rb
        fi
    fi

    if [[ ! -z "${MIRROR}" ]]; then
        if [[ -f ~/.rbenv/shims/gem ]]; then
            ~/.rbenv/shims/gem sources --add ${MIRROR}/ --remove https://rubygems.org/
        fi
    fi
}

function install_bundle() {
    if [[ -f ~/.rbenv/shims/gem ]]; then
        ~/.rbenv/shims/gem install bundle
    fi

    if [[ ! -z "${MIRROR}" ]]; then
        if [[ -f ~/.rbenv/shims/bundle ]]; then
            ~/.rbenv/shims/bundle config mirror.https://rubygems.org ${MIRROR}
        fi
    fi
}

function do_init() {
    sudo yum install git gcc openssl-devel readline-devel zlib-devel gdbm-devel sqlite-devel -y
}

function do_install() {
    if [[ ! -d ~/.rbenv ]]; then
        git clone git://github.com/sstephenson/rbenv.git --depth=1 ~/.rbenv
    fi

    if [[ ! -d ~/.rbenv/plugins/ruby-build ]]; then
        git clone git://github.com/sstephenson/ruby-build.git --depth=1 ~/.rbenv/plugins/ruby-build
    fi

    install_plugin_china_mirror
    install_ruby
    install_gem
    install_bundle
}

function do_config() {
    if [[ ! -d ~/.rbenv/plugins/rbenv-vars ]]; then
        git clone https://github.com/rbenv/rbenv-vars.git --depth=1 ~/.rbenv/plugins/rbenv-vars
    fi

    if [[ ! -f ~/.gemrc ]]; then
        echo "gem: --no-document" > ~/.gemrc
    fi

    if grep -Fq rbenv ~/.bash_profile
    then
        echo 'WARING: rbenv is exists in bash_profile!'
    else
        echo '' >> ~/.bash_profile
        echo '# rbenv support start' >> ~/.bash_profile
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
        echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
        echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
        echo '# rbenv support end' >> ~/.bash_profile
    fi

    source ~/.bash_profile
}


do_init
do_install
do_config

echo 'install rbenv successful.'
