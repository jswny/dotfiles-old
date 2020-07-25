#!/usr/bin/env bash
# shellcheck disable=SC2016
# shellcheck disable=SC2181
# Runs custom linting rules on a specified input

script_name="$(basename "${0}")"

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

check_lint_result() {
  if [ "${1}" = '' ]; then
    log 'debug' 'Lint succeeded!'
  else
    log 'debug' 'Lint failed!'
    any_lint_failed_current_file=1
    any_lint_failed=1
    echo "${1}"
  fi
}

lint_file() {
  local target="${1}"
  local target_content
  target_content=$(cat "${1}")
  any_lint_failed_current_file=0

  log 'info' "Linting file \"${target}\"..."

  # Variables without brackets
  log 'info' 'Checking for variables without brackets...'
  set +e
  variables_without_brackets=$(
    echo "${target_content}" |
    # Escaped "$" characters
    grep -E -n -v '.*\\\$.+' |
    # Fish-style variables in the format "{$var}"
    grep -E -v '^[0-9]*: *.*{\$([A-z]|[0-9]|\?|@)+}' |
    # Comments
    grep -E -v '^[0-9]*: *#.*$' |
    # Awk expressions
    grep -E -v '^[0-9]*: *.*awk.*' |
    grep --color=always -E '\$([A-z]|[0-9]|\?|@)+'
  )
  set -e

  check_lint_result "${variables_without_brackets}"

  if [ "${any_lint_failed_current_file}" = 1 ]; then
    log 'error' "Linting failed for file \"${target}\"!"
  else
    log 'info' "Linting succeeded for file \"${target}\"!"
  fi
}

# Parse command-line options
for opt in "${@:-}"; do
  case "${opt}" in
    --help)
      help
      exit 0
      ;;
    --debug)
      debug=1
      log 'debug' 'Running in debug mode'
      ;;
    '')
      log 'error' 'No files provided!'
      help
      exit 1
      ;;
    *)
      if [[ "${opt}" == --* ]]; then
        log 'error' "Unknown option: \"${opt}\""
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
