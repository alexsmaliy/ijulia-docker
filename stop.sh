#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)
IS_RUNNING="${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}"
IS_RESTARTING="${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=restarting)}"

if [ -z "$EXISTS" ]; then
  echo "Nothing to stop."
elif [ -z "$IS_RUNNING" ] && [ -z "$IS_RESTARTING" ]; then
  echo "The container isn't running. Current status: $(./status.sh)"
else
  docker-compose stop
fi
