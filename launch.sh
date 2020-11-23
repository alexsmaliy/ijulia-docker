#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)
IS_RUNNING=${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}

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

if [ -z "$EXISTS" ]; then
  # Perms inside image in /opt/julia default to 1000:$NB_GID, but imported artifacts seem
  # to get created with drwx--S---, not drwsrws---. We keep the default $NB_UID and only
  # change $NB_GID to be able to read/write the host's mounted volume.
  NB_UID=1000 \
  NB_GID=$(id -g) \
  EXTRA_ARGS="${EXTRA_ARGS[@]}" \
  docker-compose --compatibility up --build --detach \
  && docker-compose logs --follow 2> /dev/null
elif [ -n "$IS_RUNNING" ]; then
  echo "Already running. Try looking at the logs or restarting to get a URL with an access token."
else
  echo "Launched, but not running. Consider restarting it. Current status: $(./status.sh)"
fi
