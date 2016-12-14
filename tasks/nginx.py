# -*- coding: utf-8 -*-

from fabric.api import run, local, put, execute, env, cd
from fabric.contrib.files import exists as file_exists
from . import _sudo, _has_source, _get_source

"""
env options:
    - nginx_version
"""

DEFAULT_VERSION = '1.10.2'
PID_FILE = '/var/run/nginx.pid'

def nginx_require():
    _sudo('aptitude install -y libpcre++-dev libssl-dev')

def nginx_download():
    version = env.get('nginx_version', DEFAULT_VERSION)
    tar_url = 'http://nginx.org/download/nginx-{}.tar.gz'.format(version)
    tar_filename = 'nginx-{}.tar.gz'.format(version)
    tar_file = '/tmp/{}'.format(tar_filename)

    if _has_source(tar_filename):
        put(_get_source(tar_filename), tar_file)
    else:
        run('wget -c {} -O {}'.format(tar_url, tar_file))

def nginx_build():
    version = env.get('nginx_version', DEFAULT_VERSION)
    tar_filename = 'nginx-{}.tar.gz'.format(version)
    tar_file = '/tmp/{}'.format(tar_filename)

    if not file_exists(tar_file):
        return

    with cd('/tmp'):
        run('tar zxf {}'.format(tar_filename))

    source_path = '/tmp/nginx-{}'.format(version)

    if not file_exists(source_path):
        return

    with cd(source_path):
        run('./configure --prefix=/opt/nginx '
                '--user=www-data '
                '--group=www-data '
                '--error-log-path=/var/log/nginx/error.log '
                '--http-log-path=/var/log/nginx/access.log '
                '--pid-path={} '
                '--with-http_ssl_module '
                '--with-http_v2_module '.format(PID_FILE))
        run('make')
        _sudo('make install')

def nginx_config():
    from os import path

    conf_path = '/opt/nginx/conf'
    conf_file = '{}/nginx.conf'.format(conf_path)
    sbin_file = '/opt/nginx/sbin/nginx'

    if not file_exists(conf_file):
        return

    if not file_exists('{}/conf.d'.format(conf_path)):
        _sudo('mkdir {}/conf.d'.format(conf_path))
        _sudo('chown www-data:www-data {}/conf.d'.format(conf_path))
        _sudo('chmod 774 {}/conf.d'.format(conf_path))

    _sudo('cp {}/nginx.conf.default {}'.format(conf_path, conf_file))
    _sudo("sed -i "
            "-e '/http {/a \ \ \ \ server_tokens off;' "
            "-e '$i \ \ \ \ include conf.d/*.conf;' "
            " "+conf_file)

    service_file = '/lib/systemd/system/nginx.service'
    if not file_exists(service_file):
        home_path = run('pwd', quiet=True)

        put(path.join(path.dirname(path.dirname(__file__)), 'etc', 'nginx.service'),
                '~/')
        _sudo('cp {}/nginx.service {}'.format(home_path, service_file))

        _sudo("sed -i "
                "-e 's/PID_FILE/{}/g' "
                "-e 's/SBIN_FILE/{}/g' "
                "{}".format(PID_FILE.replace('/', '\/'),
                    sbin_file.replace('/', '\/'),
                    service_file))

        _sudo('systemctl enable nginx')

        run('rm ~/nginx.service')

def nginx():
    execute(nginx_require)
    execute(nginx_download)
    execute(nginx_build)
    execute(nginx_config)
