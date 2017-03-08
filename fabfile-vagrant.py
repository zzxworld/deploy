# -*- coding: utf-8 -*-

from fabric.api import env, execute
from tasks.nginx import *
from tasks.mysql import *
from tasks.redis import *
from tasks.ruby import *
from tasks.php import *
from tasks.nodejs import *

env.hosts = ['127.0.0.1']
env.port = 2222
env.user = 'vagrant'
env.password = 'vagrant'

env.mysql_root_password = '123456'

env.ruby_mirror = 'https://gems.ruby-china.org'
env.rbuild_mirror = 'https://cache.ruby-china.org'

env.php_mirror = 'http://cn2.php.net'
