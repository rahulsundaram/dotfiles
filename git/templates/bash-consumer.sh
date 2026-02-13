#!/usr/bin/env bash
#
# example-script.sh - Brief description
#
# Part of a multi-script project that shares logic via lib.sh.
# See bash-lib.sh for the shared library template.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

# ============================================================================
# Help (called by lib.sh parse_flags when --help is passed)
# ============================================================================

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Brief description of what this script does.

Options:
  --yes, -y          Skip confirmation prompts (for automation)
  --help, -h         Show this help message

Environment Variables:
  SOME_VAR           Description (default: some-default)

See also:
  make target-name                   # Description
EOF
}

# ============================================================================
# Main
# ============================================================================

init_vars
parse_flags "$@"

echo "=== Doing the thing ==="
echo ""

confirm "Continue?"

# Your logic here, using lib.sh functions:
#   require_command "jq"
#   require_value                    # sets VALUE or exits
#   resource_exists "type" "name"    # returns true/false
