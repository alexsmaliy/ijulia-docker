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
  Starts or restarts the container(s) for the specified service, then
  follows the logs for peace of mind (Ctrl+C to stop following logs).
EOF
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")

if [ -z "$EXISTS" ]; then
  unset -f print_usage_and_stop_if_needed # hack to placate extglob
  ./launch.sh "$1"
else
  docker-compose restart "$SERVICE"
  docker-compose logs --follow --tail 25 "$SERVICE"
fi
