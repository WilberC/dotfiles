#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}    ✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}    ! $*${RESET}"; }
error()   { echo -e "${RED}    ✗ $*${RESET}"; }
abort()   { error "$*"; exit 1; }

# ─── 1. detect OS ─────────────────────────────────────────────────────────────
info "Detecting OS..."
case "$(uname -s)" in
  Darwin) PLATFORM="osx" ;;
  Linux)
    grep -qi microsoft /proc/version 2>/dev/null && PLATFORM="wsl2" || PLATFORM="linux"
    ;;
  *) abort "Unsupported OS: $(uname -s)" ;;
esac
success "Platform: $PLATFORM"

# ─── 2. prerequisites ─────────────────────────────────────────────────────────
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

# ─── 3. stow personal dotfiles ────────────────────────────────────────────────
info "Stowing dotfiles ($PLATFORM)..."
cd "$DOTFILES_DIR"
for dir in git zsh shared "$PLATFORM"; do
  stow --restow "$dir"
  success "stowed $dir"
done

# ─── 4. install packages ──────────────────────────────────────────────────────
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

# ─── 5. install aqua + CLI tools ──────────────────────────────────────────────
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

# ─── 6. verify personal setup ─────────────────────────────────────────────────
info "Verifying personal setup..."

echo ""
echo -e "  ${BOLD}Git identity${RESET}"
GIT_NAME="$(git config --global user.name || true)"
GIT_EMAIL="$(git config --global user.email || true)"
[[ -n "$GIT_NAME" ]]  && success "name:  $GIT_NAME"  || warn "user.name not set"
[[ -n "$GIT_EMAIL" ]] && success "email: $GIT_EMAIL" || warn "user.email not set"

echo ""
echo -e "  ${BOLD}SSH — GitHub (critical)${RESET}"
SSH_RESULT="$(ssh -T git@github.com 2>&1 || true)"
if echo "$SSH_RESULT" | grep -q "successfully authenticated"; then
  success "GitHub SSH OK"
else
  error "GitHub SSH FAILED"
  warn "Open 1Password and make sure the SSH agent is enabled, then re-run."
  abort "Cannot continue — GitHub SSH is required to clone dotfiles-work."
fi

# ─── 7. clone and install dotfiles-work ───────────────────────────────────────
info "Setting up dotfiles-work..."
DOTFILES_WORK_REPO="git@github.com:WilberC/dotfiles-work.git"
DOTFILES_WORK_DIR="$HOME/Projects/Personal/dotfiles-work"

if [[ ! -d "$DOTFILES_WORK_DIR" ]]; then
  git clone "$DOTFILES_WORK_REPO" "$DOTFILES_WORK_DIR"
  success "Cloned dotfiles-work"
else
  success "dotfiles-work already present"
fi

bash "$DOTFILES_WORK_DIR/install.sh"

# ─── 8. post-install hints ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}All done! Manual steps remaining:${RESET}"
echo ""
echo -e "  ${BOLD}All platforms${RESET}"
echo "    - Set up tool versions:  mise install"
echo "    - Sign into GitHub CLI:  gh auth login"
echo ""
if [[ "$PLATFORM" == "osx" ]]; then
  echo -e "  ${BOLD}Recommended${RESET}"
  echo "    - VSCode  (sign in to sync extensions automatically)"
  echo ""
else
  echo -e "  ${BOLD}Install manually (no apt package available):${RESET}"
  echo "    - Zed         https://zed.dev/docs/linux"
  echo "    - Claude Code https://docs.anthropic.com/claude-code"
  echo "    - VSCode      https://code.visualstudio.com/docs/setup/linux"
  echo "                  (sign in to sync extensions automatically)"
  echo ""
fi
