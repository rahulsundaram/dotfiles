# Bash Gotchas & Patterns

Patterns learned from building multi-script projects with `set -euo pipefail`.

## 1. `set -e` kills subshell assignments silently

Under `set -e`, a failed command inside `$()` exits the script immediately.
The variable never gets assigned, and your error handling never runs.

```bash
# BAD — script dies at the assignment, never reaches the if
IP=$(get_ip)
if [[ -z "$IP" ]]; then
  echo "IP not found"  # never reached
fi

# GOOD — add || true inside the function
get_ip() {
  gcloud compute instances describe foo --format="get(ip)" 2>/dev/null || true
}
IP=$(get_ip)            # returns empty string on failure
if [[ -z "$IP" ]]; then
  echo "IP not found"  # reached
fi
```

**Rule:** Any function whose output is captured via `$()` must not fail under `set -e`. Add `|| true` at the end of the command that might fail.

## 2. Quoted multi-word variables become one argument

When a variable holds space-separated words that should be separate arguments,
quoting defeats word splitting — which is usually what you want, except here.

```bash
# BAD — "compute instances" is passed as a single argument
resource_type="compute instances"
gcloud "$resource_type" describe foo    # gcloud: "compute instances" is not a command

# GOOD — intentional word splitting
# shellcheck disable=SC2086
gcloud $resource_type describe foo      # gcloud compute instances describe foo
```

**Rule:** When you intentionally need word splitting, use `# shellcheck disable=SC2086` to document it. This is rare — most of the time, quote everything.

## 3. SSH consumes stdin from pipes and loops

SSH reads stdin by default. In a loop reading from stdin (or piped input),
SSH steals the remaining input and the loop only runs once.

```bash
# BAD — SSH eats remaining lines after first iteration
while read -r host; do
  ssh "$host" "uptime"
done < hosts.txt

# GOOD — -n prevents SSH from reading stdin
while read -r host; do
  ssh -n "$host" "uptime"
done < hosts.txt
```

For `gcloud compute ssh`, use `--ssh-flag="-n"` or redirect stdin:
```bash
gcloud compute ssh "$instance" --command="uptime" < /dev/null
```

## 4. Shared library pattern for multi-script projects

When multiple scripts share logic, extract it into `lib.sh`:

```bash
# lib.sh — sourced by all scripts
parse_flags()   # --help calls show_help() callback, --yes sets AUTO_APPROVE
confirm()       # interactive prompt, skipped when AUTO_APPROVE=true
init_vars()     # project-wide defaults
```

```bash
# any-script.sh — consumer
source "$SCRIPT_DIR/lib.sh"
show_help() { cat << EOF; ... ; EOF; }  # define before parse_flags
init_vars
parse_flags "$@"
confirm "Deploy?"
```

**Why a callback:** `parse_flags` lives in lib.sh but each script has its own help text. Defining `show_help()` before calling `parse_flags` lets the library call back into the script.

## 5. Trap ordering matters

```bash
# cleanup runs on any exit (normal, error, signal)
trap cleanup EXIT

# interrupt handler for Ctrl+C — just exit, cleanup trap fires automatically
trap 'exit 130' INT TERM
```

Don't put cleanup logic in the INT/TERM trap — the EXIT trap already covers it.

## 6. Check resource existence before create/delete

Idempotent scripts should check before acting:

```bash
# Pattern: exists → skip, else → create
if resource_exists "compute instances" "my-instance"; then
  echo "Already exists (skipping)"
else
  gcloud compute instances create my-instance ...
fi
```

Show a plan first for destructive operations:
```bash
PLAN_CREATE=()
PLAN_SKIP=()
resource_exists "thing" "name" && PLAN_SKIP+=("name") || PLAN_CREATE+=("name")
# Show plan, confirm, then execute
```
