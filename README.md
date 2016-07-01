# deploy

常用的开发工具部署脚本。

## 测试平台:

* CentOS 7

## 使用:

### install rbenv
```
curl -sSL https://raw.githubusercontent.com/zzxworld/deploy/master/rbenv.sh | bash
```

使用镜像 (_Ruby China_):
```
curl -sSL https://raw.githubusercontent.com/zzxworld/deploy/master/rbenv.sh | bash -s https://gems.ruby-china.org
```

### deploy rails

```
curl -sSL https://raw.githubusercontent.com/zzxworld/deploy/master/unicorn_rails.sh | bash
```

> 此脚本必须在 Rails 项目主目录运行。使用 unicorn 工具部署。会自动在项目中创建以下文件
> bin/unicorn: 控制 unicorn 启动和停止。
> config/unicorn.rb: unicorn 配置文件。
> config/nginx.conf: nginx 配置。
> .rbenv-vars: 项目环境变量。（创建 RAILS_ENV 和 SECRET_KEY_BASE 环境变量)
