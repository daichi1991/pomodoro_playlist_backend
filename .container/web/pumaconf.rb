app_root = ENV.fetch('APP_ROOT')
directory app_root
threads 8, 32
workers %x(grep -c processor /proc/cpuinfo)
bind "unix://#{app_root}/tmp/sockets/my_app.sock"
pidfile "#{app_root}/tmp/pids/puma.pid"
