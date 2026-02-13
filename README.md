# Dotfiles

Modern development environment managed with [chezmoi](https://chezmoi.io). Works on **macOS** and **Fedora Linux** (including immutable variants: Silverblue, Bazzite, Bluefin, Aurora).

## What You Get

- 30+ modern CLI tools replacing legacy Unix commands
- 100+ shell aliases for kubectl, git, docker, and general use
- fzf-powered fuzzy history search, file finder, and interactive kubectl workflows
- oh-my-posh prompt with git status and Kubernetes context display
- Side-by-side git diffs via git-delta
- Neovim config with LSP, treesitter, telescope, and autocompletion
- VS Code with vim bindings, 30+ extensions, and language-specific formatters
- Single Brewfile (macOS) with a Linux variant, automatic OS detection

---

## Reproduce This Setup

### macOS

```bash
# 1. Install Homebrew (skip if already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi, initialize from this repo, and apply dotfiles
brew install chezmoi
chezmoi init --apply https://github.com/rahulsundaram/dotfiles.git

# 3. Install all tools (chezmoi deploys ~/.Brewfile from dot_Brewfile)
brew bundle --file=~/.Brewfile

# 4. Start a new shell
exec zsh
```

### Linux (Fedora)

#### Standard Fedora

```bash
# 1. Install build dependencies
sudo dnf groupinstall -y 'Development Tools'
sudo dnf install -y procps-ng curl file git zsh

# 2. Install Homebrew (Linuxbrew)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 3. Install chezmoi, initialize from this repo, and apply dotfiles
brew install chezmoi
chezmoi init --apply https://github.com/rahulsundaram/dotfiles.git

# 4. Install all tools
brew bundle --file=~/.local/share/chezmoi/Brewfile.linux

# 5. Install Nerd Fonts (required for prompt icons)
sudo dnf copr enable che/nerd-fonts && sudo dnf install nerd-fonts

# 6. Set zsh as default shell and start it
chsh -s $(which zsh)
exec zsh
```

#### Immutable Fedora (Silverblue, Bazzite, Bluefin, Aurora)

On immutable variants, dev tools live in a distrobox container. The install script handles everything:

```bash
curl -fsSL https://raw.githubusercontent.com/rahulsundaram/dotfiles/main/install.sh | bash
```

Or step by step:

```bash
# 1. Install distrobox if not present (Silverblue ships toolbox, not distrobox)
#    Universal Blue variants (Bazzite, Bluefin, Aurora) already have it.
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"

# 2. Install chezmoi standalone (no Homebrew on the host)
sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$HOME/.local/bin"

# 3. Initialize and apply — creates distrobox container + installs all tools inside
chezmoi init --apply https://github.com/rahulsundaram/dotfiles.git

# 4. Open a new terminal — auto-enters the container
```

**Auto-entry toggle:** Opening a terminal automatically enters the container. To control this:

```bash
distrobox-toggle                             # flip auto-entry on/off
# or manually:
touch ~/.config/dotfiles/no-distrobox        # stay on host
rm ~/.config/dotfiles/no-distrobox           # resume auto-entry
```

### Font Setup

Nerd Fonts are required for prompt icons. On macOS they install automatically via Brewfile. On Fedora, install via `sudo dnf copr enable che/nerd-fonts && sudo dnf install nerd-fonts`. Configure your terminal to use one:

- **Terminal.app**: Preferences > Profiles > Font > "MesloLGS Nerd Font"
- **iTerm2**: Preferences > Profiles > Text > Font > "MesloLGS Nerd Font"
- **VS Code**: `"terminal.integrated.fontFamily": "MesloLGS Nerd Font"` in settings.json

---

## Tools Installed

### Modern CLI Replacements

| Replaces | Tool | What It Does |
|----------|------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) | File listing with icons, git status, tree view |
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax highlighting, line numbers, git integration |
| `find` | [fd](https://github.com/sharkdp/fd) | 10x faster, sane defaults, regex support |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | 17x faster, respects .gitignore |
| `du` | [dust](https://github.com/bootandy/dust) | Visual disk usage with tree layout |
| `df` | [duf](https://github.com/muesli/duf) | Color-coded disk free table |
| `top` | [bottom](https://github.com/ClementTsang/bottom) | Graphical system monitor |
| `ps` | [procs](https://github.com/dalance/procs) | Colored, searchable process list |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | Learns your directories, jump with fragments |

`ls` and `cat` are aliased; the rest (`dust`, `duf`, `btm`, `procs`, `fd`, `rg`) are used directly.

### Kubernetes

| Tool | What It Does |
|------|-------------|
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [kubectx / kubens](https://github.com/ahmetb/kubectx) | Fast context and namespace switching |
| [k9s](https://k9scli.io/) | Full-screen Kubernetes TUI |
| [helm](https://helm.sh/) | Kubernetes package manager |
| [stern](https://github.com/stern/stern) | Tail logs from multiple pods simultaneously |
| [kind](https://kind.sigs.k8s.io/) | Run local Kubernetes clusters in Docker |

### Development

| Tool | What It Does |
|------|-------------|
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git (`lg`) |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Terminal UI for Docker (`ld`) |
| [git-delta](https://github.com/dandavison/delta) | Side-by-side syntax-highlighted diffs |
| [gh](https://cli.github.com/) | GitHub CLI |
| [neovim](https://neovim.io/) | Modern vim (`vim`/`vi`/`v` aliased) |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [httpie](https://httpie.io/) | Human-friendly HTTP client |
| [jq](https://jqlang.github.io/jq/) / [yq](https://github.com/mikefarah/yq) | JSON/YAML processors |
| [dive](https://github.com/wagoodman/dive) | Explore Docker image layers |
| [glow](https://github.com/charmbracelet/glow) | Render Markdown in the terminal |

### Productivity

| Tool | What It Does |
|------|-------------|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (`Ctrl+R` history, `Ctrl+T` files, `Alt+C` dirs) |
| [oh-my-posh](https://ohmyposh.dev/) | Cross-shell prompt with git/k8s segments |
| [direnv](https://direnv.net/) | Auto-load `.envrc` files |
| [chezmoi](https://chezmoi.io) | Dotfile manager |

> **Note (macOS):** `Alt+C` requires your terminal to send Option as Meta/Esc+.
> iTerm2: Preferences > Profiles > Keys > Left Option Key > "Esc+".
> Terminal.app: Preferences > Profiles > Keyboard > "Use Option as Meta key".

---

## Shell Configuration

`.zshrc` includes 100+ aliases and functions. See the file directly for the full list. Highlights:

- **Prompt**: oh-my-posh `powerlevel10k_rainbow` theme (alternatives commented out)
- **kubectl**: `k`, `kgp`, `kgd`, `kgs`, `kd`, `kl`, `ka`, `kdel`, `kdr`, plus fzf-powered `ksh`, `klogs`, `kdesc`, `kpy`
- **git**: `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `lg` (lazygit)
- **docker**: `dps`, `di`, `dex`, `dlog`, `ld` (lazydocker)

---

## Neovim

`~/.config/nvim/init.lua` — single-file config using [lazy.nvim](https://github.com/folke/lazy.nvim). Includes treesitter, telescope, nvim-cmp, gitsigns, nvim-tree, go.nvim, and LSP via Mason (pyright, gopls, bashls, lua_ls, ansiblels). Leader key is Space.

---

## VS Code

Settings, keybindings, and 30+ extensions auto-installed via `run_once_after_install-vscode-extensions.sh.tmpl`. Vim bindings with Space as leader, matching neovim keymaps where possible. Language-specific formatters: Ruff (Python), gofumpt (Go), Prettier (JS/JSON), shell-format (Bash).

---

## Architecture

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl                              # Detects OS, sets variables
├── .chezmoiignore                                  # Source-only files (not deployed)
├── Brewfile.linux                                  # Linux packages (synced with dot_Brewfile)
├── dot_Brewfile                                    # macOS packages (brew bundle dump)
├── dot_config/nvim/init.lua                        # Neovim configuration
├── dot_gitconfig                                   # Git config (delta as pager)
├── dot_zshrc.tmpl                                  # Shell config (templated per OS)
├── install.sh                                      # Standalone install script
├── dot_config/Code/User/settings.json               # VS Code settings
├── dot_config/Code/User/keybindings.json            # VS Code keybindings
├── run_once_before_setup-brewfile.sh.tmpl           # Auto-links correct Brewfile per OS
├── run_once_after_setup-vscode-config.sh.tmpl       # Symlinks VS Code config on macOS
├── run_once_after_install-go-tools.sh.tmpl          # Installs Go dev tools
├── run_once_after_install-node-tools.sh.tmpl        # Installs Node language servers
├── run_once_after_install-vscode-extensions.sh.tmpl # Installs VS Code extensions
├── run_once_after_setup-distrobox.sh.tmpl           # Distrobox container setup (immutable OS)
└── README.md
```

**How it works:**

1. `chezmoi init` reads `.chezmoi.toml.tmpl` and detects macOS vs Linux (+ immutable OS)
2. `run_once_before_setup-brewfile.sh.tmpl` symlinks the correct Brewfile per OS
3. `dot_zshrc.tmpl` renders with the correct Homebrew prefix (+ distrobox auto-entry on immutable OS)
4. `run_once_after_` scripts install Go tools, Node language servers, and VS Code extensions
5. `brew bundle` installs all tools from the linked Brewfile
6. On immutable OS: `run_once_after_setup-distrobox.sh.tmpl` creates a distrobox container with all tools inside

---

## Maintenance

Chezmoi auto-syncs to git on every operation:

```toml
[git]
    autoAdd = true
    autoCommit = true
    autoPush = true
```

```bash
# Edit a config
vim ~/.zshrc && chezmoi add ~/.zshrc

# Or edit through chezmoi
chezmoi edit ~/.zshrc

# Re-add all changed managed files
chezmoi re-add

# Add a new dotfile
chezmoi add ~/.config/k9s/config.yaml

# Sync from another machine
chezmoi update

# Add a new tool
brew install <tool>
brew bundle dump --file=~/.Brewfile --force && chezmoi add ~/.Brewfile
# Also update Brewfile.linux if cross-platform
```
