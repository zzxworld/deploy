# -*- coding: utf-8 -*-

from fabric.api import env, run, cd, execute, put
from fabric.utils import warn
from fabric.contrib.files import sed, exists as file_exists
from . import _sudo, _has_source, _get_source, _has_string

"""
env options:
    - ruby_version
    - ruby_mirror
    - rbuild_mirror
"""

DEFAULT_VERSION = '2.3.3'

def ruby_require():
    _sudo('aptitude install -y git libreadline-dev zlib1g-dev libsqlite3-dev')

def ruby_install():
    version = env.get('ruby_version', DEFAULT_VERSION)
    rbuild_mirror = env.get('rbuild_mirror')
    rbenv_path = '~/.rbenv'
    ruby_path = '{}/versions/{}'.format(rbenv_path, version)
    source_filename = 'ruby-{}.tar.bz2'.format(version)
    source_file = '/tmp/{}'.format(source_filename)

    if file_exists(ruby_path):
        warn('ruby {} is installed'.format(version))
        return

    if _has_source(source_filename) and not file_exists(source_file):
        put(_get_source(source_filename), source_file)

    if not file_exists(rbenv_path):
        run('git clone https://github.com/rbenv/rbenv.git --depth=1 {}'.format(rbenv_path))

    rbuild_path = '{}/plugins/ruby-build'.format(rbenv_path)
    if not file_exists(rbuild_path):
        run('git clone https://github.com/rbenv/ruby-build.git --depth=1 {}'.format(rbuild_path))

    if file_exists(source_file):
        run('env RUBY_BUILD_MIRROR_URL=file:///tmp/{}# ~/.rbenv/bin/rbenv install -v {}'.format(source_filename, version))
    elif rbuild_mirror:
        mirror_url = '{}/pub/ruby/{}/ruby-{}.tar.bz2'.format(
                rbuild_mirror, '.'.join(version.split('.')[0:2]), version)
        run('env RUBY_BUILD_MIRROR_URL={}# ~/.rbenv/bin/rbenv install -v {}'.format(
            mirror_url, version))
    else:
        run('~/.rbenv/bin/rbenv install -v {}'.format(version))

    run('~/.rbenv/bin/rbenv global {}'.format(version))

def ruby_config():
    ruby_mirror = env.get('ruby_mirror')
    gem_file = '~/.rbenv/shims/gem'
    bundle_file = '~/.rbenv/shims/bundle'
    bundle_config_file = '~/.bundle/config'
    gemrc_file = '~/.gemrc'

    if not file_exists(gemrc_file):
        run('echo "---" > {}'.format(gemrc_file))
        run('echo "gem: --no-ri --no-rdoc --no-document" >> {}'.format(gemrc_file))

    if ruby_mirror and not _has_string(gemrc_file, ruby_mirror):
        run('{} sources --add {}/ --remove https://rubygems.org/'.format(
            gem_file, ruby_mirror))
        run('{} update --system'.format(gem_file))

    if not file_exists(bundle_file) and file_exists(gem_file):
        run('{} install bundle'.format(gem_file))

    if ruby_mirror and file_exists(bundle_file) and not file_exists(bundle_config_file):
        run('{} config mirror.https://rubygems.org {}'.format(bundle_file,
            ruby_mirror))

    vars_path = '~/.rbenv/plugins/rbenv-vars'
    if not file_exists(vars_path):
        run('git clone https://github.com/rbenv/rbenv-vars.git --depth=1 {}'.format(vars_path))

    if not _has_string('~/.profile', 'rbenv') and file_exists('~/.profile'):
        run('echo "" >> ~/.profile')
        run('echo "# rbenv support start" >> ~/.profile')
        run('echo \'export PATH="$HOME/.rbenv/bin:$PATH"\' >> ~/.profile')
        run('echo \'eval "$(rbenv init -)"\' >> ~/.profile')
        run('echo \'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"\' >> ~/.profile')
        run('echo "# rbenv support end" >> ~/.profile')

def ruby():
    execute(ruby_require)
    execute(ruby_install)
    execute(ruby_config)
