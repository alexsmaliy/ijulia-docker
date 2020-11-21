#! /usr/bin/env bash

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)

if [ -z "$EXISTS" ]; then
  echo "Service doesn't seem to have been launched. Try launching it."
else
  docker-compose logs --follow --tail=20 2> /dev/null
fi

