#!/usr/bin/env bash
set -e

if [ "${SECRET_VALUES}" != "" ]; then
  echo ${SECRET_VALUES} | \
  jq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""' > /etc/profile.d/secrets.sh
  chmod 755 /etc/profile.d/secrets.sh
  cat /etc/profile.d/secrets.sh >> ~/.bashrc
  source /etc/profile.d/secrets.sh
fi

bundle exec rails db:migrate

exec bundle exec pumactl start -F ${APP_ROOT}/.container/web/pumaconf.rb
