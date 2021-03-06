#! /usr/bin/env bash

set -o errexit
shopt -s extglob

pushd "$(dirname "$0")" 1> /dev/null || return
trap "shopt -u extglob && popd 1> /dev/null" EXIT

source ./util.sh

function usage() { cat << EOF
Usage:
  $(basename "$0") $(services_list_pipe_separated_str)
What it does:
  Destroys the specified service. Stops and removes its container(s).
  The host's mounted volumes with shared files are unaffected.
EOF
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")

if [ -n "$EXISTS" ]; then
  docker-compose rm --force --stop "$SERVICE"
  docker network rm $(docker network ls -q) 2> /dev/null
else
  echo "Nothing to destroy."
fi
