#!/usr/bin/env bash
# shellcheck disable=SC2016

# Runs custom linting rules on a specified input

set -euo pipefail

# Variables without brackets
! grep --color=always -E '\$([A-z]|[0-9])+' < "${1}"
