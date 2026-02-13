#!/bin/bash

# Dotfiles Installation Script
# Installs Homebrew, chezmoi, all tools, and applies dotfiles

set -e

echo "🚀 Starting dotfiles installation..."
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Darwin*)  OS_TYPE="macos" ;;
  Linux*)   OS_TYPE="linux" ;;
  *)        echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Detect immutable OS (Silverblue, Bazzite, Bluefin, Aurora, etc.)
IS_IMMUTABLE=false
if [ -f /usr/bin/rpm-ostree ]; then
  IS_IMMUTABLE=true
fi

echo "✓ Detected OS: $OS_TYPE"
if [ "$IS_IMMUTABLE" = true ]; then
  echo "✓ Immutable OS detected (rpm-ostree)"
fi
echo ""

# ---------- Immutable OS path ----------
# On immutable Fedora-based systems, skip Homebrew on the host entirely.
# Install chezmoi standalone; it will create a distrobox container with all tools.
if [ "$IS_IMMUTABLE" = true ]; then
  # Install distrobox if not present (Silverblue ships toolbox, not distrobox)
  if ! command -v distrobox &> /dev/null; then
    echo "📦 Installing distrobox..."
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix "$HOME/.local"
    echo "✓ distrobox installed to ~/.local/bin"
  else
    echo "✓ distrobox already installed"
  fi

  echo ""

  # Install chezmoi standalone
  if ! command -v chezmoi &> /dev/null; then
    echo "📦 Installing chezmoi (standalone)..."
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    echo "✓ chezmoi installed to ~/.local/bin"
  else
    echo "✓ chezmoi already installed"
  fi

  echo ""

  # Initialize and apply — triggers run_once_after_setup-distrobox.sh
  echo "⚙️  Initializing and applying dotfiles..."
  chezmoi init --apply https://github.com/rahulsundaram/dotfiles.git
  echo "✓ Dotfiles applied"

  echo ""
  echo "✨ Installation complete!"
  echo ""
  echo "🎯 Next steps:"
  echo "  1. Open a new terminal — it will auto-enter the distrobox container"
  echo "  2. To disable auto-entry: distrobox-toggle"
  echo "  3. Test: ll, k9s, lazygit, fzf (Ctrl+R)"
  echo ""
  echo "📚 Documentation: ~/.local/share/chezmoi/README.md"
  echo ""
  exit 0
fi

# ---------- Mutable OS path (macOS / standard Linux) ----------

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
  echo "📦 Installing Homebrew..."
  if [ "$OS_TYPE" = "macos" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    # Linux
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for Linux
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  echo "✓ Homebrew installed"
else
  echo "✓ Homebrew already installed"
fi

echo ""

# Install chezmoi if not installed
if ! command -v chezmoi &> /dev/null; then
  echo "📦 Installing chezmoi..."
  brew install chezmoi
  echo "✓ chezmoi installed"
else
  echo "✓ chezmoi already installed"
fi

echo ""

# Install all tools from Brewfile
BREWFILE="$HOME/.local/share/chezmoi/Brewfile"
if [ -f "$BREWFILE" ]; then
  echo "📦 Installing all tools from Brewfile..."
  brew bundle --file="$BREWFILE"
  echo "✓ Tools installed"
else
  echo "⚠️  Brewfile not found at $BREWFILE"
fi

echo ""

# Apply dotfiles
echo "⚙️  Applying dotfiles..."
chezmoi apply
echo "✓ Dotfiles applied"

echo ""
echo "✨ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Test installation: ll (should use eza)"
echo "  3. Try: k9s, lazygit, fzf (Ctrl+R)"
echo ""
echo "📚 Documentation: ~/.local/share/chezmoi/README.md"
echo ""
