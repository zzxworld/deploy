#!/bin/bash

PASSWORD=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)

function is_installed() {
    if rpm -ql mariadb-server|grep -q 'not installed'; then
        return 1
    fi

    if rpm -ql mariadb-devel|grep -q 'not installed'; then
        return 1
    fi

    return 0
}

function is_have_password() {
    if mysql -uroot -e 'show databases'|grep -q 'Database'; then
        return 1
    fi
    return 0
}

function display_password() {
    echo -e "\e[33mWaring: \e[0mDon't forget that the password for \e[1mroot\e[21m: \033[31m$PASSWORD\e[0m"
}

function config_password() {
    if is_have_password; then
        echo -e "\e[33mWaring: password does have for root.\e[0m"
    else
        mysql -uroot -e "UPDATE mysql.user SET Password = PASSWORD('$PASSWORD') WHERE User='root'"
        mysql -uroot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
        mysql -uroot -e "DELETE FROM mysql.user WHERE User=''"
        mysql -uroot -e "DROP DATABASE test"
        mysql -uroot -e "FLUSH PRIVILEGES"

        display_password
    fi
}

function config_utf8_charset() {
    if [[ ! -f /etc/my.cnf ]]; then
        echo -e "\e[33mWaring: does't found the my.cnf in /etc/ \e[0m"
        return
    fi

    if ! cat /etc/my.cnf|grep -q '# set utf8 charset on default'; then
        sudo cp /etc/my.cnf /etc/my.cnf.bak

        sudo sed -i "/\[mysqld_safe\]/i \\
# set utf8 charset on default\\
init_connect='SET collation_connection = utf8_unicode_ci'\\
init_connect='SET NAMES utf8'\\
character-set-server=utf8\\
collation-server=utf8_unicode_ci\\
skip-character-set-client-handshake\\
        " /etc/my.cnf
    fi
}

function do_install() {
    if ! is_installed; then
        sudo yum install mariadb-server mariadb-devel -y
        sudo systemctl enable mariadb
        sudo systemctl start mariadb
    fi
}

function do_config() {
    if ! is_installed; then
        echo -e "\e[31mError: mariadb not install.\e[0m"
        return
    fi

    config_password
    config_utf8_charset
}

do_install
do_config
echo -e "\e[32mMariadb install successful\e[0m"
