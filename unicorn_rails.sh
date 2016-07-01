#!/bin/bash

UNICORN_CONTROL_FILE=bin/unicorn
UNICORN_CONFIG_FILE=config/unicorn.rb
NGINX_CONFIG_FILE=config/nginx.conf
RBENV_VARS_FILE=.rbenv-vars
APP_PATH=$(cd $(dirname "$0") && pwd)

if [[ ! -f ./Gemfile ]]; then
    echo "must runing in rails application folder."
    exit 0
fi

function generate_unicorn_control_script() {
    if [[ ! -f $UNICORN_CONTROL_FILE ]]; then

cat > $UNICORN_CONTROL_FILE << EOL
#!/bin/sh
USAGE="Usage: \$0 <start|stop>"
APP_PATH=\$(cd \$(dirname "\$(dirname "\$0")") && pwd)
PID="\$APP_PATH/tmp/pids/unicorn.pid"

cd \$APP_PATH || exit 1

sig () {
    test -s "\$PID" && kill -\$1 \`cat \$PID\`
}

case \$1 in
  start)
    sig 0 && echo >&2 "Already running" && exit 0
    echo "Starting app"
    cd \$APP_PATH && bundle exec unicorn_rails -c config/unicorn.rb -D
    ;;
  stop)
    echo "Stopping app"
    sig QUIT && exit 0
    echo >&2 "Not running"
    ;;
  *)
    echo >&2 \$USAGE
    exit 1
    ;;
esac
EOL
        chmod +x $UNICORN_CONTROL_FILE

    fi
}

function generate_unicorn_config() {
    if [[ ! -f $UNICORN_CONFIG_FILE ]]; then

cat > $UNICORN_CONFIG_FILE << EOL
app_path = File.expand_path("../..", __FILE__)
working_directory app_path
worker_processes 1
timeout 30

listen "#{app_path}/tmp/sockets/unicorn.sock", :backlog => 64
pid "#{app_path}/tmp/pids/unicorn.pid"
stderr_path "#{app_path}/log/unicorn.stderr.log"
stdout_path "#{app_path}/log/unicorn.stdout.log"

preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
EOL
    fi
}

function generate_nginx_config() {
    if [[ ! -f $NGINX_CONFIG_FILE ]]; then

cat > $NGINX_CONFIG_FILE << EOL
upstream this_app_name {
    server unix:$APP_PATH/tmp/sockets/unicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name localhost;

    root $APP_ROOT/public;
    try_files \$uri/index.html \$uri @app;

    error_page 500 502 503 504 /500.html;
    keepalive_timeout 10;

    location @app {
        proxy_pass http://this_app_name;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
    }
}
EOL

    fi
}

function generate_rbenv_vars() {
    if [[ ! -f $RBENV_VARS_FILE ]]; then
        echo 'RAILS_ENV=production' > $RBENV_VARS_FILE
        rake secret|awk '{print "SECRET_KEY_BASE="$1}' >> $RBENV_VARS_FILE
    fi
}

function do_init() {
    bundle install
}

function do_install() {
    generate_unicorn_control_script
    generate_unicorn_config
    generate_nginx_config
    generate_rbenv_vars
}

function do_config() {
    echo "config"
}

do_init
do_install

echo 'deploy successful!'
