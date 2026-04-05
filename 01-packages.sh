#!/usr/bin/env bash
# Install system packages and CLI tools via aqua.
# Can be run standalone: bash 01-packages.sh
set -euo pipefail
source "$(dirname "$0")/_common.sh"

# ─── prerequisites ─────────────────────────────────────────────────────────────
info "Installing prerequisites..."

if [[ "$PLATFORM" == "osx" ]]; then
  if ! xcode-select -p &>/dev/null; then
    warn "Xcode CLI tools not found — installing..."
    xcode-select --install
    echo "    Re-run this script after the Xcode CLI tools finish installing."
    exit 0
  fi
  success "Xcode CLI tools present"

  if ! command -v brew &>/dev/null && [[ ! -x "/opt/homebrew/bin/brew" ]] && [[ ! -x "/usr/local/bin/brew" ]]; then
    warn "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  success "Homebrew present"

  brew upgrade git &>/dev/null || brew install git
  success "git up to date"

  brew install stow &>/dev/null || true
  success "stow present"

else
  # Linux / WSL2
  info "Updating package lists..."
  sudo apt-get update -qq
  success "Package lists updated"

  # Latest git — needed before stowing dotfiles
  sudo add-apt-repository -y ppa:git-core/ppa &>/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y git stow &>/dev/null
  success "git and stow installed"
fi

# ─── stow dotfiles ─────────────────────────────────────────────────────────────
info "Stowing dotfiles ($PLATFORM)..."
cd "$DOTFILES_DIR"
for dir in git zsh shared "$PLATFORM"; do
  stow --restow "$dir"
  success "stowed $dir"
done

# ─── system packages ───────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "osx" ]]; then
  info "Installing packages via Brewfile..."
  brew bundle --file="$DOTFILES_DIR/shared/Brewfile"
  success "Packages installed"
else
  info "Adding apt repositories..."
  # mise
  if [[ ! -f /etc/apt/sources.list.d/mise.list ]]; then
    curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | \
      sudo tee /etc/apt/trusted.gpg.d/mise-archive-keyring.gpg &>/dev/null
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | \
      sudo tee /etc/apt/sources.list.d/mise.list &>/dev/null
  fi
  success "Apt repositories configured"

  info "Installing packages via Aptfile..."
  sudo apt-get update -qq
  grep -v '^#\|^[[:space:]]*$' "$DOTFILES_DIR/shared/Aptfile" | xargs sudo apt-get install -y -qq
  success "Packages installed"
fi

# ─── CLI tools via aqua ────────────────────────────────────────────────────────
info "Installing CLI tools via aqua..."
if ! command -v aqua &>/dev/null; then
  if [[ "$PLATFORM" == "osx" ]]; then
    brew install aquaproj/aqua/aqua &>/dev/null
  else
    curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/main/aqua-installer | bash &>/dev/null
    export PATH="$HOME/.local/share/aquaproj-aqua/bin:$PATH"
  fi
  success "aqua installed"
fi
export AQUA_GLOBAL_CONFIG="$HOME/.config/aquaproj-aqua/aqua.yaml"
aqua install --all
success "CLI tools installed"
