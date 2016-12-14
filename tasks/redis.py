# -*- coding: utf-8 -*-

from fabric.api import execute
from . import _sudo

def redis_install():
    _sudo('aptitude install -y redis-server')

def redis_config():
    _sudo("sed -i 's/# maxmemory <bytes>/maxmemory 64mb/' /etc/redis/redis.conf")

def redis():
    execute(redis_install)
    execute(redis_config)
