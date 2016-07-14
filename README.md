# deploy

常用的开发工具部署脚本。

## 测试平台:

* CentOS 7

## 使用:

1. clone 项目到本地。
2. 给相应的脚本执行权限，然后直接执行。也可使用下面两种方式:

   * `cat [name].sh|bash`: 可以省去添加执行权限的操作。
   * `curl -sSL [url].sh|bash`: 可以省去 clone 项目和执行权限的操作。

## 脚本介绍

### mariadb.sh

MySQL 数据库的替代方案。安装时会自动生成一个随机的 root 用户密码，并在安装完毕后显示这个随机密码。

### rbenv.sh

基于 rbenv 的 Ruby 运行环境。默认安装 Ruby 版本 *2.3.1*，并启用了 rbenv-vars 插件。

#### 使用镜像

如果在国内安装，需要添加镜像地址，如使用 ruby-china 的镜像:

    rbenv.sh https://gems.ruby-china.org

如果是使用 `cat` 或 `curl` 的方式，使用镜像地址时，需要添加 `-s` 参数:

    cat rbenv.sh | bash -s https://gems.ruby-china.org

### unicorn_rails.sh [beta!]

创建 Rails 项目的默认部署环境。

> 此脚本必须在 rails 项目主目录运行。默认生成的配置文件只是保证项目能在部署机器上能正常运行，并不是最佳实践。

脚本创建了以下文件:

* `bin/unicorn`: 控制 unicorn 启动和停止。
* `config/unicorn.rb`: unicorn 配置文件。
* `config/nginx.conf`: nginx 配置。
* `.rbenv-vars`: 项目环境变量。（创建 RAILS_ENV 和 SECRET_KEY_BASE 环境变量)

#### TODO:

* 使用 puma 部署 rails 5
