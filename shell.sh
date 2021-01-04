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
  Opens an interactive shell inside the container for the specified
  service. The actual shell varies by service and is pretty spartan,
  but should be sufficient for simple troubleshooting. Use Ctrl+D or
  \`exit\` to terminate the shell session.
EOF
}

function jupyter_shell() {
  JUPYTER_USER=jovyan # The default non-root user the container sets up.
  echo "Opening a Bash shell as $JUPYTER_USER in $SERVICE..."
  docker-compose exec --user "$JUPYTER_USER" "$SERVICE" bash
}

function pluto_shell() {
  PLUTO_USER=pluto
  echo "Opening a Bash shell as $PLUTO_USER in $SERVICE..."
  docker-compose exec --user "$PLUTO_USER" "$SERVICE" bash
}

print_usage_and_stop_if_needed "$1"

SERVICE="$1-service"

EXISTS=$(docker-compose ps --quiet "$SERVICE")
IS_RUNNING=${EXISTS:+$(docker ps --all --quiet --filter id="$EXISTS" --filter status=running)}

if [ -z "$EXISTS" ] || [ -z "$IS_RUNNING" ]; then
  unset -f print_usage_and_stop_if_needed
  echo "Not running. Status: $(./status.sh "$1")"
else
  case $1 in
    jupyter) jupyter_shell;;
    pluto) pluto_shell;;
  esac
fi
