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
  Gets the status of the specified service from Docker.
EOF
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")

if [ -z "$EXISTS" ]; then
  echo "The container for this service doesn't exist."
else
  docker ps --all --quiet --filter id="$EXISTS" --format '{{.Status}}'
fi
