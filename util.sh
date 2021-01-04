#! /usr/bin/env bash

function services_list_str() {
  local SERVICES_ARR=($(docker-compose config --services 2> /dev/null))
  printf '%s' "${SERVICES_ARR[*]%%-service}"
}

function services_list_pipe_separated_str() {
  services_list_str | tr ' ' '|'
}

function print_usage_and_stop_if_needed() {
  case $1 in
    @($(services_list_pipe_separated_str)))
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '\e[1;31mInvalid selection:\e[0m\n  [%s]\n' "$1"
      usage
      exit 1
      ;;
  esac
}

export -f services_list_str
export -f services_list_pipe_separated_str
export -f print_usage_and_stop_if_needed
