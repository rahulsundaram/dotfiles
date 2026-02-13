# Development Standards & Configuration

## Personal Configuration

**Identity:**
- Personal repos: ~/git/
- Work repos: ~/git/corp/
- Git email: set per-repo, never globally (see CLAUDE.local.md for addresses)

**Tools:**
- Shell: zsh (~/.zshrc)
- Dotfiles: chezmoi (~/.local/share/chezmoi) — auto-syncs via autoAdd/autoCommit/autoPush
- Package manager: brew (Brewfile)

## Code Standards

**General:**
- Comments only where "why" isn't obvious — never restate what code does
- Keep functions small and single-purpose
- Prefer early returns over deep nesting
- No dead code — delete unused functions and commented blocks
- Keep code modular and reusable — extract functions, avoid inline logic blocks
- Don't use heredocs — use variables, arrays, or files instead
- Prefer clean data structures (arrays, associative arrays) over string manipulation

**Shell Scripts:**
- Standalone scripts: `set -euo pipefail` at the top
- Sourced scripts / shell configs: `set -u` is sufficient (no -e/-o pipefail which break interactive use)
- Quote all variable expansions: `"$var"` not `$var`
- Use `${var:-}` for intentionally optional variables under `set -u`
- Use `local` for variables inside functions
- Prefer `[[ ]]` over `[ ]` in bash/zsh
- Error messages to stderr: `echo "error: something failed" >&2`
- Scripts must be idempotent — safe to run multiple times
- Never use `eval` with variables that could contain untrusted input

**Validation (run before pushing):**
- Shell: `shellcheck <file>`, `zsh -n ~/.zshrc`
- Python: `ruff check .`, `ruff format --check .`, `ty check .`
- Go: `golangci-lint run`, `go vet ./...`
- Terraform: `terraform fmt -check`, `terraform validate`
- YAML: `yamllint <file>`
- JSON: `jq . <file>`

**Testing:**
- Run existing tests after code changes — match what CI runs
- Shell functions: test interactively before committing
- Infrastructure: always dry-run first (kubectl, terraform)
- Ansible: `ansible-lint`, `ansible-playbook --check` before applying

**Ansible:**
- All tasks must be idempotent — including `command`, `shell`, and `raw` modules
- Use `creates`, `removes`, or `when` guards on command/shell tasks to prevent re-runs
- Prefer dedicated modules over command/shell (e.g., `ansible.builtin.apt` not `command: apt install`)
- Use fully qualified collection names (e.g., `ansible.builtin.copy` not `copy`)

**Dotfiles (chezmoi):**
- After dotfile edits: `chezmoi add <file>` (auto-commits and pushes)
- After package changes: update Brewfile and `chezmoi add ~/.Brewfile`
- Verify: `chezmoi diff` should be empty after any operation
- If you `chezmoi apply` without adding local edits first, local changes are overwritten

## Workflow Rules

**Always test before changing:**
1. Verify the problem exists — test current behavior first
2. Make minimal changes to fix verified issues
3. Test again to confirm the fix

**Destructive operations — always ask first:**
- Never delete files, run force operations, or drop data without explicit permission
- When asked to "clean up" or "remove", confirm which specific items

**Changes:**
- Read existing code before modifying
- Make smallest change that solves the problem
- Don't refactor adjacent code unless asked
- When changing code, update related docs (README, comments, architecture diagrams) in the same change — don't let docs go stale
- Use consistent terminology — don't mix synonyms for the same concept (e.g., pick one of "OS-aware" or "cross-platform", not both)

**Commits:**
- Concise messages — what changed and why
- No volatile stats (counts, percentages)
- NEVER add Co-Authored-By lines for Claude/AI — all commits are authored by the user
