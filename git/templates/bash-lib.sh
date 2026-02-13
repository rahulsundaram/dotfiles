#!/usr/bin/env bash
#
# lib.sh - Shared functions for [project] scripts
#
# Source this file, don't execute it:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib.sh"

# Guard against direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This file should be sourced, not executed directly."
  exit 1
fi

# ============================================================================
# Configuration
# ============================================================================

AUTO_APPROVE=false

# Set project-wide defaults. Override env vars to customize.
init_vars() {
  # PROJECT_NAME="${PROJECT_NAME:-my-project}"
  # CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/$PROJECT_NAME}"
  true
}

# ============================================================================
# Flag Parsing & Help
# ============================================================================

# Parse common flags shared across all scripts.
# The sourcing script should define show_help() before calling this.
#
# Supported flags:
#   --help, -h    Call show_help() and exit
#   --yes, -y     Set AUTO_APPROVE=true (skip confirmation prompts)
#
# Unknown flags are silently skipped so scripts can add their own
# flags before or after calling this function.
parse_flags() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --help|-h)
        if declare -f show_help >/dev/null 2>&1; then
          show_help
        else
          echo "No help available."
        fi
        exit 0
        ;;
      --yes|-y)
        AUTO_APPROVE=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

# Interactive confirmation prompt. Skipped when AUTO_APPROVE=true.
confirm() {
  local prompt="${1:-Continue?}"
  if [[ "$AUTO_APPROVE" == true ]]; then
    return 0
  fi
  read -rp "$prompt (y/N): " response
  case $response in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) echo "Cancelled."; exit 0 ;;
  esac
}

# ============================================================================
# Resource Checks
# ============================================================================

# Check if a command/tool is available
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd"
    exit 1
  fi
}

# ============================================================================
# set -e Safe Patterns
# ============================================================================
#
# GOTCHA: Under `set -e`, if a function can fail and you capture its
# output in a variable assignment, the script exits immediately on
# failure — the error-handling code after the assignment never runs.
#
#   BAD:
#     get_ip() { some_command 2>/dev/null; }
#     IP=$(get_ip)                    # Script dies here if some_command fails
#     if [[ -z "$IP" ]]; then ...     # Never reached
#
#   GOOD:
#     get_ip() { some_command 2>/dev/null || true; }
#     IP=$(get_ip)                    # Returns empty string on failure
#     if [[ -z "$IP" ]]; then ...     # Reached — can handle the error
#
# Apply `|| true` inside any function whose output is captured via $().
# See also: bash-gotchas.md

# Example: safe wrapper that returns empty string on failure
# get_value() {
#   some_command --format="get(field)" 2>/dev/null || true
# }
#
# require_value() {
#   local val
#   val=$(get_value)
#   if [[ -z "$val" ]]; then
#     echo "Value not found. Set it up first with: make setup"
#     exit 1
#   fi
#   # Export for callers
#   VALUE="$val"
# }

# ============================================================================
# Word Splitting for Multi-Word Commands
# ============================================================================
#
# GOTCHA: When a variable holds multiple words that should be separate
# arguments, quoting prevents word splitting:
#
#   BAD:
#     resource_type="compute instances"
#     gcloud "$resource_type" describe foo   # Passes "compute instances" as ONE arg
#
#   GOOD:
#     # shellcheck disable=SC2086
#     gcloud $resource_type describe foo     # Passes "compute" and "instances" separately
#
# This is one of the rare cases where you intentionally skip quoting.
# Always add the shellcheck disable comment to document the intent.

# Example: generic resource existence check
# resource_exists() {
#   local resource_type=$1   # e.g., "compute instances" — intentionally unquoted below
#   local resource_name="$2"
#   shift 2
#   # shellcheck disable=SC2086
#   gcloud $resource_type describe "$resource_name" "$@" &>/dev/null
# }

# ============================================================================
# SSH Patterns (delete if not needed)
# ============================================================================
#
# GOTCHA: SSH reads stdin, which breaks read loops and piped input.
#
#   BAD:
#     while read -r host; do
#       ssh "$host" "uptime"     # SSH consumes remaining stdin — loop runs once
#     done < hosts.txt
#
#   GOOD:
#     while read -r host; do
#       ssh -n "$host" "uptime"  # -n prevents SSH from reading stdin
#     done < hosts.txt
#
# For gcloud compute ssh, use: --command="..." --quiet --ssh-flag="-n"

# SSH with strict host key checking (stable hosts)
# remote_ssh() {
#   local host="$1"
#   shift
#   ssh -o StrictHostKeyChecking=accept-new -n "$host" "$@" 2>/dev/null
# }

# SSH with permissive host key checking (ephemeral/recreated hosts)
# remote_ssh_permissive() {
#   local host="$1"
#   shift
#   ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -n "$host" "$@" 2>/dev/null
# }
