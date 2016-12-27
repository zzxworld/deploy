# -*- coding: utf-8 -*-

from fabric.api import run
from . import _sudo

def nodejs():
    _sudo('aptitude install -y curl')
    run('curl -sL https://deb.nodesource.com/setup_6.x')
    _sudo('aptitude install -y nodejs')
