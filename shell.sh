#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)
IS_RUNNING=${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}

if [ -z "$EXISTS" ] || [ -z "$IS_RUNNING" ]; then
  echo "Not running. Status: $(./status.sh)"
else
  SERVICE_NAME=$(docker-compose config --services 2> /dev/null)
  JUPYTER_USER=jovyan # The default non-root user the container sets up.
  echo "Opening a Bash shell as $JUPYTER_USER in $SERVICE_NAME..."
  docker-compose exec --user "$JUPYTER_USER" "$SERVICE_NAME" bash
fi
