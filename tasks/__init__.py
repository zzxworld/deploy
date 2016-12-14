# -*- coding: utf-8 -*-

from os import path

def _sudo(*args, **kwargs):
    from fabric.api import env, run, sudo as _sudo
    if env.user == 'root':
        run(*args, **kwargs)
    else:
        _sudo(*args, **kwargs)

def _has_string(file, string):
    from fabric.api import run, sudo as _sudo
    result = run('cat {}|grep {}'.format(file, string), warn_only=True, quiet=True)
    return result != ''

def _has_source(name):
    return path.exists(path.join(path.dirname(path.dirname(__file__)),
        'sources', name))

def _get_source(name):
    return path.join(path.dirname(path.dirname(__file__)),
        'sources', name);
