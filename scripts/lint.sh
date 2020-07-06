#!/usr/bin/env bash
# shellcheck disable=SC2016

script_name="$(basename "$0")"

# shellcheck source=scripts/common.sh
source "$(dirname "${0}")"/common.sh

# Runs custom linting rules on a specified input

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

check_lint_result() {
  if [ "${?}" = 0 ]; then
    log 'error' 'Lint failed!'
  else
    log 'info' 'Lint succeeded!'
  fi
  
  if [ "${any_lint_failed_current_file}" = '1' ] || [ "${?}" = 0 ]; then
    any_lint_failed_current_file=1
  fi

  if [ "${any_lint_failed}" = '1' ] || [ "${?}" = 0 ]; then
    any_lint_failed=1
  fi
}

lint_file() {
  local target="${1}"
  any_lint_failed_current_file=0

  log 'info' "Linting file \"${target}\"..."

  # Variables without brackets
  log 'info' 'Checking for variables without brackets...'
  grep --color=always -E '\$([A-z]|[0-9])+' < "${target}"

  check_lint_result

  if [ "${any_lint_failed_current_file}" = 0 ]; then
    log 'error' "Linting failed for file \"${target}\"!"
  else
    log 'info' "Linting succeeded for file \"${target}\"!"
  fi
}

echo args: $@

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
        echo $files_to_lint
        log 'debug' "Added \"${opt}\" to the list of files to lint"
      else
        log 'error' "The path \"${opt}\" is not a valid file!"
        exit 1
      fi
      ;;
  esac
done

log 'debug' "Files to lint: \"${files_to_lint}\""
for opt in "${files_to_lint}"; do
  lint_file "${opt}"
done

if [ "${any_lint_failed}" = 0 ]; then
  log 'error' 'Linting failed!'
else
  log 'info' 'Linting succeeded!'
fi
