#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)

if [ -z "$EXISTS" ]; then
  echo "The container doesn't exist."
else
  echo "$(docker ps --all --quiet --filter id=$EXISTS --format '{{.Status}}')"
fi
