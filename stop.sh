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
  Stops, but does not destroy, the container(s) for the specified service.
EOF
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")
IS_RUNNING="${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}"
IS_RESTARTING="${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=restarting)}"

if [ -z "$EXISTS" ]; then
  echo "Nothing to stop."
elif [ -z "$IS_RUNNING" ] && [ -z "$IS_RESTARTING" ]; then
  unset -f print_usage_and_stop_if_needed # hack to placate extglob
  echo "The container isn't running. Current status: $(./status.sh "$1")"
else
  docker-compose stop "$SERVICE"
fi
