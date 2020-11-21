#! /usr/bin/env bash

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)
IS_RUNNING=${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}

if [ -z "$EXISTS" ]; then
  ./launch.sh
elif [ -n "$IS_RUNNING" ]; then
  echo "Service seems to be running already. Try following logs."
else
  docker-compose restart
fi

