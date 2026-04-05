#!/usr/bin/env bash
# Clone and install work dotfiles, then print post-install hints.
# Can be run standalone: bash 03-work.sh
set -euo pipefail
source "$(dirname "$0")/_common.sh"

# ─── clone and install dotfiles-work ──────────────────────────────────────────
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

# ─── post-install hints ────────────────────────────────────────────────────────
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
  echo "    - bfg         https://rtyley.github.io/bfg-repo-cleaner (requires Java)"
  echo "    - Zed         https://zed.dev/docs/linux"
  echo "    - Claude Code https://docs.anthropic.com/claude-code"
  echo "    - VSCode      https://code.visualstudio.com/docs/setup/linux"
  echo "                  (sign in to sync extensions automatically)"
  echo ""
fi
