#!/usr/bin/env bash
# Shared helpers — source this file, do not execute directly

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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "Detecting OS..."
case "$(uname -s)" in
  Darwin) PLATFORM="osx" ;;
  Linux)
    grep -qi microsoft /proc/version 2>/dev/null && PLATFORM="wsl2" || PLATFORM="linux"
    ;;
  *) abort "Unsupported OS: $(uname -s)" ;;
esac
success "Platform: $PLATFORM"
