#! /usr/bin/env bash

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)

if [ -f security/cert/localhost.crt ]; then
  URL="https://localhost:8888"
  EXTRA_ARGS=(
    "--NotebookApp.certfile=/home/jovyan/.local/cert/localhost.crt"
    "--NotebookApp.keyfile=/home/jovyan/.local/cert/localhost.key"
  )
else
  URL="http://0.0.0.0:8888"
  EXTRA_ARGS=()
fi

if [ -z "$EXISTS" ]; then
  NB_UID=$(id -u) \
  NB_GID=$(id -g) \
  URL="$URL" \
  EXTRA_ARGS="${EXTRA_ARGS[@]}" \
  docker-compose --compatibility up --detach \
  && docker-compose logs --follow 2> /dev/null
else
  echo "Already launched. Try starting it if it's stopped."
fi

