#!/usr/bin/env bash
#
# Script Name: script-name.sh
# Description: Brief description of what this script does
# Author: Your Name
# Created: YYYY-MM-DD
# Last Modified: YYYY-MM-DD
#
# Usage: ./script-name.sh [OPTIONS] [ARGUMENTS]
#
# Examples:
#   ./script-name.sh --help
#   ./script-name.sh --verbose input.txt
#
# Dependencies:
#   - jq (optional)
#   - curl (optional)
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'        # Set safe Internal Field Separator

# ============================================================================
# Configuration & Defaults
# ============================================================================

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_NAME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly SCRIPT_VERSION="1.0.0"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Default values
VERBOSE=false
DRY_RUN=false
OUTPUT_FILE=""

# Temporary directory (created only if needed)
TEMP_DIR=""

# ============================================================================
# Functions
# ============================================================================

# Print usage information
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] [ARGUMENTS]

Brief description of what this script does.

OPTIONS:
    -h, --help              Show this help message and exit
    -v, --verbose           Enable verbose output
    -V, --version           Show version information
    -n, --dry-run           Show what would be done without doing it
    -o, --output FILE       Write output to FILE

ARGUMENTS:
    input_file              Input file to process

EXAMPLES:
    $SCRIPT_NAME input.txt
    $SCRIPT_NAME --verbose --output result.txt input.txt
    $SCRIPT_NAME --dry-run input.txt

EOF
}

# Print version information
version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $*" >&2
    fi
}

# Create temporary directory
create_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    log_debug "Created temporary directory: $TEMP_DIR"
}

# Error handler - called on script exit
cleanup() {
    local exit_code=$?

    # Clean up temporary directory if we created one
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        log_debug "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi

    # Exit with original exit code
    exit "$exit_code"
}

# Set up cleanup on exit
trap cleanup EXIT

# Graceful interrupt handler
interrupt() {
    log_warn "Script interrupted by user"
    exit 130
}
trap interrupt INT TERM

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
check_dependencies() {
    local missing_deps=()

    # Add required commands here
    local required_commands=(
        # "jq"
        # "curl"
    )

    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Install with: brew install ${missing_deps[*]}"
        exit 1
    fi
}

# Validate input file
validate_input_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "Input file not found: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        log_error "Input file not readable: $file"
        return 1
    fi

    log_debug "Validated input file: $file"
    return 0
}

# Main processing function
process_file() {
    local input_file="$1"

    log_info "Processing file: $input_file"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would process: $input_file"
        return 0
    fi

    # Example: Create temp dir if needed
    # create_temp_dir

    # Your main logic here
    local line_count
    line_count=$(wc -l < "$input_file")

    log_success "Processed $line_count lines from $input_file"

    if [[ -n "$OUTPUT_FILE" ]]; then
        log_info "Writing output to: $OUTPUT_FILE"
        # Write output logic here
    fi
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_args() {
    # No arguments provided
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi

    local input_file=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -V|--version)
                version
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -o|--output)
                if [[ -z "${2:-}" ]]; then
                    log_error "Option $1 requires an argument"
                    exit 1
                fi
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                # Positional argument
                if [[ -z "$input_file" ]]; then
                    input_file="$1"
                else
                    log_error "Too many arguments"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$input_file" ]]; then
        log_error "Missing required argument: input_file"
        usage
        exit 1
    fi

    # Return the input file via global or stdout
    echo "$input_file"
}

# ============================================================================
# Main
# ============================================================================

main() {
    log_debug "Starting $SCRIPT_NAME"
    log_debug "Script directory: $SCRIPT_DIR"

    # Check dependencies
    check_dependencies

    # Parse arguments
    local input_file
    input_file=$(parse_args "$@")

    # Validate input
    validate_input_file "$input_file" || exit 1

    # Process the file
    process_file "$input_file"

    log_success "Script completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
