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
  Initializes and runs the container(s) for the specified service, then
  follows the logs for peace of mind (Ctrl+C to stop following logs).
  Does nothing if containers already exist.
EOF
}

function launch_jupyter() {
  if [ -f security/cert/localhost.crt ]; then
    EXTRA_ARGS=(
      "--NotebookApp.certfile=/home/jovyan/.local/cert/localhost.crt"
      "--NotebookApp.keyfile=/home/jovyan/.local/cert/localhost.key"
      "--NotebookApp.custom_display_url=https://localhost:8888"
    )
  else
    EXTRA_ARGS=(
      "--NotebookApp.custom_display_url=http://0.0.0.0:8888"
    )
  fi
  # Perms inside image in /opt/julia default to 1000:$NB_GID, but imported artifacts seem
  # to get created with drwx--S---, not drwsrws---. We keep the default $NB_UID and only
  # change $NB_GID to be able to read/write the host's mounted volume.
  NB_UID=1000 NB_GID=$(id -g) EXTRA_ARGS="${EXTRA_ARGS[@]}" \
    docker-compose --compatibility up --build --detach "$SERVICE"
}

function launch_pluto() {
  NB_UID=$(id -u) NB_GID=null EXTRA_ARGS=null \
    docker-compose --compatibility up --build --detach "$SERVICE"
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")
IS_RUNNING=${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}

if [ -z "$EXISTS" ]; then
  case $1 in
    jupyter) launch_jupyter;;
    pluto) launch_pluto;;
  esac
  docker-compose logs --follow --tail 25 "$SERVICE" 2> /dev/null
elif [ -n "$IS_RUNNING" ]; then
  echo "Already running. Try looking at the logs or restarting to get a URL with an access token."
else
  unset -f print_usage_and_stop_if_needed # hack to placate extglob
  echo "Launched, but not running. Consider restarting it. Current status: $(./status.sh "$1")"
fi
