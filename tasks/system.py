# -*- coding: utf-8 -*-

from fabric.api import run, local, put, execute, env
from fabric.contrib.files import exists as file_exists
from . import _sudo

"""
env options:
    - ssh_port
    - deploy_password
    - deploy_ssl_file
    - current_user_password
    - current_user_ssl_file
"""

DEFAULT_SSH_PORT=2202

def system_update():
    _sudo('aptitude update')
    _sudo('aptitude upgrade -y -q')
    _sudo('aptitude install -y sudo')

def system_config_ssh():

    path = '/etc/ssh/sshd_config'
    backup_path = "{}.{}".format(path, 'bak')

    if file_exists(backup_path):
        return

    _sudo('cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak')

    _sudo('sed -i -e "s/Port 22/Port {}/g" '
        '-e "s/PermitRootLogin yes/PermitRootLogin no/g" '
        '-e "s/PasswordAuthentication yes/PasswordAuthentication no/g" '
        '{}'.format(env.get('ssh_port', DEFAULT_SSH_PORT), path))

def _create_user(username, password, identity_file=None):
    from time import time
    from hashlib import md5
    from os import path

    home_path = '/home/{}'.format(username)
    home_path = '/home/{}'.format(username)
    ssh_path = '{}/.ssh'.format(home_path)
    authorize_file = '{}/authorized_keys'.format(ssh_path)

    if not file_exists(home_path):
        _sudo('useradd -m -G sudo -s /bin/bash {}'.format(username))
        _sudo('usermod -a -G www-data {}'.format(username))
        if not password:
            password = md5(str(time())).hexdigest()[0:6]
            _sudo('echo {} > {}/.password'.format(password, home_path))
            _sudo('chown {}:{} {}/.password'.format(username, username, home_path))
        _sudo('echo {}:{}|chpasswd'.format(username, password))

    if identity_file and path.exists(identity_file):
        if file_exists(ssh_path):
            return

        _sudo('mkdir {}'.format(ssh_path))
        _sudo('chmod 700 {}'.format(ssh_path))

        if env.user == 'root':
            put(identity_file, authorize_file)
        else:
            put(identity_file, authorize_file, use_sudo=True)

        _sudo('chmod 644 {}'.format(authorize_file))
        _sudo('chown -R {}:{} {}'.format(username, username, ssh_path))

def system_config_deploy_user():
    username = 'deploy'
    _create_user(username,
            env.get('deploy_password'),
            env.get('deploy_ssl_file'))

def system_config_current_user():
    _create_user(env.local_user,
            env.get('current_user_password'),
            env.get('current_user_ssl_file'))

def system_config_firewall():
    ufw_file = '/etc/default/ufw'
    ufw_backup_file = '{}.bak'.format(ufw_file)

    if not file_exists('/usr/sbin/ufw'):
        _sudo('aptitude install -y ufw', quiet=True)

    if not file_exists(ufw_backup_file):
        _sudo('cp {} {}'.format(ufw_file, ufw_backup_file))

    _sudo('sed -i "s/IPV6=yes/IPV6=no/g" {}'.format(ufw_file))

    _sudo('ufw allow 80/tcp')
    _sudo('ufw allow 443/tcp')
    _sudo('ufw allow {}/tcp'.format(env.get('ssh_port', DEFAULT_SSH_PORT)))

def system_enable_firewall(**kwargs):
    _sudo('echo y|ufw enable')
    if kwargs.get('reboot'):
        _sudo('reboot')
