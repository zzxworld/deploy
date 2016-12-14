# deploy

基于 [fabric](https://github.com/fabric/fabric/) 的服务器部署框架。

## 依赖:

* 服务器系统 __Debian 8__
* 本地系统有 Python 环境，并安装了 __fabric__

## 使用

1. 基于默认 `fabfile.py` 文件的使用：

		fab -H 127.0.0.1 --port=2222 -u vagrant -p vagrant system_update

2. (__推荐__) 自定义配置文件，如: `fabfile-vagrant.py`:

		fab -f fabfile-vagrant.py system_update
