#! /usr/bin/env bash

set -o errexit

pushd "$(dirname "$0")" 1> /dev/null || return
trap "popd 1> /dev/null" EXIT

EXISTS=$(docker-compose ps --quiet)

if [ -n "$EXISTS" ]; then
  NB_UID="" NB_GID="" URL="" EXTRA_ARGS=() docker-compose down --timeout 3
else
  echo "Nothing to destroy."
fi
