#!/usr/bin/env bash
set -e

if [ "${SECRET_VALUES}" != "" ]; then
  echo ${SECRET_VALUES} | \
  jq -r 'to_entries | .[] | "export \(.key)=\"\(.value)\""' > /etc/profile.d/secrets.sh
  chmod 755 /etc/profile.d/secrets.sh
  cat /etc/profile.d/secrets.sh >> ~/.bashrc
  source /etc/profile.d/secrets.sh
fi

if [[ $JOB != 'true' ]]; then
  # db:createは初回実行時のみコメントインして実施する
  # bundle exec rails db:create
  bundle exec rails db:migrate
fi

# Exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
