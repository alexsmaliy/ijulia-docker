#! /usr/bin/env bash

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)

if [ -n "$EXISTS" ]; then
  NB_UID=$(id -u) NB_GID=$(id -g) docker-compose down --timeout 3
else
  echo "Nothing to destroy."
fi

