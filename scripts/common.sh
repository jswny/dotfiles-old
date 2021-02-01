#!/usr/bin/env bash

# Common script functions

set -euo pipefail

# Default variable values
debug=0
script_name="$(basename "${0}")"

# Log a message at different levels
log() {
  local prefix_spacer='-----'
  local prefix="${prefix_spacer} [${script_name}]"
  if [ "${1}" = 'debug' ]; then
    if [ "${debug}" = 1 ]; then
      echo "${prefix} DEBUG: ${2}"
    fi
  elif [ "${1}" = 'info' ]; then
    echo "${prefix} INFO: ${2}"
  elif [ "${1}" = 'warn' ]; then
    echo "${prefix} WARN: ${2}" >&2
  elif [ "${1}" = 'error' ]; then
    echo "${prefix} ERROR: ${2}" >&2
  else
    echo "${prefix} INTERNAL ERROR: invalid option \"${1}\" for log() with message \"${2}\"" >&2
  fi
}

# Verifies that a variable is set given it's name
verify_var_set() {
  if [ -z "${!1}" ]; then
    if [ -z "${2}" ]; then
      log 'error' "\"${1}\" is blank or unset!"
    else
      log 'error' "${2}"
    fi
    exit 1
  fi
}

check_file_exists() {
  if [ ! -f "${1}" ]; then
    if [ -e "${1}" ]; then
      log 'error' "Item at path \"${1}\" already exists, but it is not a file!"
      exit 1
    else
      log 'info' "File \"${1}\" does not exist!"
    fi
    return 1
  else
    log 'info' "File \"${1}\" already exists!"
  fi
  return 0
}
