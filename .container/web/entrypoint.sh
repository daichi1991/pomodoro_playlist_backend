#!/usr/bin/env bash
set -e

if [[ $JOB != 'true' ]]; then
  # db:createは初回実行時のみコメントインして実施する
  bundle exec rails db:create
  bundle exec rails db:migrate
fi

# Exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
