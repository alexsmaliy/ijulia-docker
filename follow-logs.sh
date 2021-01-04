#! /usr/bin/env bash

set -o errexit
shopt -s extglob

pushd "$(dirname "$0")" 1> /dev/null || return
trap "shopt -u extglob && popd 1> /dev/null" EXIT

source ./util.sh

function usage() { cat << EOF
Usage:
  $(basename "$0") $(services_list_pipe_separated_str) [NUMBER|all]
What it does:
  Prints the last few lines from the logs of the specified service,
  then monitors for any further incoming log lines (Ctrl+C to stop).
  Accepts an optional second argument for the maximum number of
  preceding lines to print, or "all" to print all preceding logs.
EOF
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")

if [ -z "$EXISTS" ]; then
  echo "This service doesn't seem to have been launched. Try launching it."
else
  docker-compose logs --follow --tail="${2-25}" "$SERVICE"
fi
