# -*- coding: utf-8 -*-

from fabric.api import env, run, cd, execute, put
from fabric.contrib.files import sed, exists as file_exists
from . import _sudo, _has_source, _get_source

"""
env options:
    - php_version
    - php_mirror
"""

DEFAULT_VERSION = '7.1.0'
DEFAULT_MIRROR = 'http://php.net'
TEMP_PATH = '/tmp'

def php_require():
    _sudo('aptitude install -y '
            'g++ '
            'libcurl4-openssl-dev '
            'libxml2-dev '
            'libjpeg-dev '
            'libwebp-dev '
            'libpng-dev '
            'libicu-dev '
            'libmcrypt-dev '
            'libsystemd-dev '
            'pkg-config')

def php_download():
    from os import path

    version = env.get('php_version', DEFAULT_VERSION)
    mirror = env.get('php_mirror', DEFAULT_MIRROR)
    tar_filename = 'php-{}.tar.gz'.format(version)
    tar_file = '/{}/{}'.format(TEMP_PATH, tar_filename)
    tar_url = '{}/get/{}/from/this/mirror'.format(mirror, tar_filename)

    if file_exists(tar_file):
        return

    if _has_source(tar_filename):
        put(_get_source(tar_filename), tar_file)
    else:
        with cd(TEMP_PATH):
            run('wget -c {} -O {}'.format(tar_url, tar_filename))

def php_build():
    version = env.get('php_version', DEFAULT_VERSION)
    tar_filename = 'php-{}.tar.gz'.format(version)
    tar_file = '/{}/{}'.format(TEMP_PATH, tar_filename)
    tar_folder = 'php-{}'.format(version)

    if not file_exists(tar_file):
        return

    with cd(TEMP_PATH):
        if not file_exists(tar_folder):
            run('tar zxf {}'.format(tar_filename))

    temp_folder_name = '{}/{}'.format(TEMP_PATH, tar_folder)

    if not file_exists(temp_folder_name):
        return

    with cd(temp_folder_name):
        run('./configure '
            '--prefix=/opt/php '
            '--with-pdo-mysql '
            '--with-mysqli '
            '--with-gd '
            '--with-jpeg-dir '
            '--with-png-dir '
            '--with-zlib '
            '--with-curl '
            '--with-mcrypt '
            '--with-icu-dir=/usr '
            '--with-fpm-user=www-data '
            '--with-fpm-group=www-data '
            '--with-fpm-systemd '
            '--with-libxml-dir '
            '--with-openssl '
            '--enable-fpm '
            '--enable-mysqlnd '
            '--enable-zip '
            '--enable-mbstring '
            '--enable-opcache '
            '--enable-sockets '
            '--enable-intl '
            '--enable-exif '
            '--enable-gd-native-ttf '
            '--disable-ipv6 '
            '--disable-rpath')

        if file_exists('main/php_config.h'):
            run('make')
            _sudo('make install')

        if not file_exists('/opt/php'):
            return

        ini_file = '/opt/php/lib/php.ini.default'
        if not file_exists(ini_file):
            _sudo('cp php.ini-production {}'.format(ini_file))

        script_file = '/opt/php/sbin/php-fpm.sh'
        if not file_exists(script_file):
            _sudo('cp sapi/fpm/init.d.php-fpm {}'.format(script_file))
            _sudo('chmod +x {}'.format(script_file))

        service_file = '/opt/php/sbin/php-fpm.service.default'
        if not file_exists(service_file):
            _sudo('cp sapi/fpm/php-fpm.service {}'.format(service_file))

def php_config():
    if not file_exists('/opt/php'):
        return

    fpm_conf_file = '/opt/php/etc/php-fpm.conf'
    if not file_exists(fpm_conf_file):
        _sudo('cp {}.default {}'.format(fpm_conf_file, fpm_conf_file))

    www_conf_file = '/opt/php/etc/php-fpm.d/www.conf'
    if not file_exists(www_conf_file):
        _sudo('cp {}.default {}'.format(www_conf_file, www_conf_file))

    ini_file = '/opt/php/lib/php.ini'
    if not file_exists(ini_file):
        _sudo('cp {}.default {}'.format(ini_file, ini_file))

        sed(ini_file, before=';date.timezone =',
                after="date.timezone = Asia/Shanghai",
                use_sudo=True, backup='')
        sed(ini_file, before=';opcache.enable=0',
                after="opcache.enable=1",
                use_sudo=True, backup='')
        sed(ini_file, before=';opcache.enable_cli=0',
                after="opcache.enable_cli=1",
                use_sudo=True, backup='')
        _sudo("sed -i '/\[opcache\]/a\zend_extension=opcache.so' "
                "{}".format(ini_file))

    service_file = '/lib/systemd/system/php-fpm.service'
    if not file_exists(service_file):
        _sudo('cp /opt/php/sbin/php-fpm.service.default {}'.format(service_file))

        sed(service_file, before='\$\{prefix\}', after="/opt/php",
                use_sudo=True, backup='')
        sed(service_file, before='\$\{exec_prefix\}', after="/opt/php",
                use_sudo=True, backup='')

        _sudo('systemctl enable php-fpm')

def php():
    execute(php_require)
    execute(php_download)
    execute(php_build)
    execute(php_config)
