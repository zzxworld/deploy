# -*- coding: utf-8 -*-

from fabric.api import env, execute
from fabric.contrib.files import exists as file_exists
from . import _sudo

"""
env options:
    - mysql_root_password
"""

def mysql_install():
    from time import time
    from hashlib import md5

    if not file_exists('/usr/bin/mysql'):
        password = env.get('mysql_root_password')
        if not password:
            password = md5(str(time())).hexdigest()[0:6]
            _sudo('echo {} > .mysql_password'.format(password))

        _sudo("debconf-set-selections <<< 'mysql-server mysql-server/root_password password {}'".format(password))
        _sudo("debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password {}'".format(password))
        _sudo('aptitude install -y mariadb-server libmariadb-dev')

def mysql_config():
    if file_exists('/etc/mysql/conf.d/mariadb.cnf'):
        _sudo("sed -i -e 's/#character-set-server/character-set-server/' "
                "-e 's/#collation-server/collation-server/' "
                "-e 's/#character_set_server/character_set_server/' "
                "-e 's/#collation_server/collation_server/' "
                "/etc/mysql/conf.d/mariadb.cnf")
        _sudo('systemctl restart mysql')

def mysql():
    execute(mysql_install)
    execute(mysql_config)
