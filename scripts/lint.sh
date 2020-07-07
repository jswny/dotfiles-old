#!/usr/bin/env bash
# shellcheck disable=SC2016
# shellcheck disable=SC2181
# Runs custom linting rules on a specified input

script_name="$(basename "$0")"

# shellcheck source=scripts/common.sh
source "$(dirname "${0}")"/common.sh

set -euo pipefail

debug=0
any_lint_failed=0
any_lint_failed_current_file=0
files_to_lint=()

help() {
  cat << EOF
usage: ${0} [OPTIONS] file(s)
  --help                Show this message
  --debug               Display extra debug info
EOF
}

grep_wrapper() {
  log 'debug' "thing: ${1}, ${2}"
  grep --color=always -n -E "${1}" < "${2}" || true
  log 'debug' 'here'
}

check_lint_result() {
  if [ "${?}" = 0 ]; then
    log 'debug' 'Lint failed!'
    any_lint_failed_current_file=1
    any_lint_failed=1
  else
    log 'debug' 'Lint succeeded!'
  fi
}

lint_file() {
  local target="${1}"
  any_lint_failed_current_file=0

  log 'info' "Linting file \"${target}\"..."

  # Variables without brackets
  log 'info' 'Checking for variables without brackets...'
  grep_wrapper '\$([A-z]|[0-9])+' "${target}"
  log 'debug' 'here'

  check_lint_result

  if [ "${any_lint_failed_current_file}" = 1 ]; then
    log 'error' "Linting failed for file \"${target}\"!"
  else
    log 'info' "Linting succeeded for file \"${target}\"!"
  fi
}

# Parse command-line options
for opt in "$@"; do
  case $opt in
    --help)
      help
      exit 0
      ;;
    --debug)
      debug=1
      log 'debug' 'Running in debug mode'
      ;;
    *)
      if [[ "${opt}" == --* ]]; then
        log 'error' "unknown option: \"$opt\""
        help
        exit 1
      fi

      if check_file_exists "${opt}"; then
        files_to_lint+=("${opt}")
        log 'debug' "Added \"${opt}\" to the list of files to lint"
      else
        log 'error' "The path \"${opt}\" is not a valid file!"
        exit 1
      fi
      ;;
  esac
done

log 'debug' "Files to lint: \"${files_to_lint[*]}\""
for opt in "${files_to_lint[@]}"; do
  lint_file "${opt}"
done

if [ "${any_lint_failed}" = 1 ]; then
  log 'error' 'Linting failed!'
else
  log 'info' 'Linting succeeded!'
fi

exit "${any_lint_failed}"
