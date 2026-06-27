#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}[ok]${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}x${RESET} $*"; }
step()    { echo -e "\n${BOLD}---- $* ----${RESET}"; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JAR_DIR="${PLANTUML_JAR_DIR:-$HOME/.local/share/plantuml}"
JAR_PATH="${PLANTUML_JAR:-$JAR_DIR/plantuml.jar}"
BIN_DIR="${PLANTUML_BIN_DIR:-$HOME/.local/bin}"
WRAPPER_SRC="$ROOT_DIR/shared/.local/bin/plantuml"
WRAPPER_DEST="$BIN_DIR/plantuml"
DOWNLOAD_URL="${PLANTUML_DOWNLOAD_URL:-https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar}"
INSTALL_DEPS=1

usage() {
  cat <<'EOF'
Usage: bash scripts/install-plantuml.sh [--skip-deps]

Installs PlantUML CLI support in isolation from the main dotfiles installer.

Options:
  --skip-deps   Do not install Java, Graphviz, or curl with brew/apt.
  -h, --help    Show this help.

Environment:
  PLANTUML_DOWNLOAD_URL  Override the plantuml.jar download URL.
  PLANTUML_JAR_DIR       Override the jar directory.
  PLANTUML_JAR           Override the jar path used by the wrapper.
  PLANTUML_BIN_DIR       Override where the plantuml wrapper symlink is placed.
EOF
}

parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --skip-deps)
        INSTALL_DEPS=0
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

detect_os() {
  if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl2"
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo "osx"
  elif [[ "$(uname)" == "Linux" ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

need_command() {
  local command_name="$1"
  local install_hint="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  error "$command_name was not found."
  echo "$install_hint" >&2
  exit 1
}

install_brew_packages() {
  need_command brew "Install Homebrew first, then re-run this script."

  local packages=(openjdk graphviz)
  local missing=()

  for package in "${packages[@]}"; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      success "$package already installed"
    else
      missing+=("$package")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    info "Installing: ${missing[*]}"
    brew install "${missing[@]}"
  fi
}

install_apt_packages() {
  need_command apt "This installer supports Debian/Ubuntu apt systems for Linux and WSL2."

  info "Updating apt package lists..."
  sudo apt update

  info "Installing Java, Graphviz, and curl..."
  sudo apt install -y default-jre graphviz curl
}

install_dependencies() {
  local platform="$1"

  step "dependencies"
  case "$platform" in
    osx)
      install_brew_packages
      ;;
    linux|wsl2)
      install_apt_packages
      ;;
    *)
      error "Unsupported platform: $platform"
      exit 1
      ;;
  esac
}

download_jar() {
  step "plantuml.jar"
  mkdir -p "$JAR_DIR"

  local tmp_file
  tmp_file="$(mktemp)"

  info "Downloading PlantUML..."
  curl -fsSL -o "$tmp_file" "$DOWNLOAD_URL"
  mv "$tmp_file" "$JAR_PATH"
  chmod 0644 "$JAR_PATH"
  success "$JAR_PATH"
}

install_wrapper() {
  step "wrapper"
  mkdir -p "$BIN_DIR"
  chmod +x "$WRAPPER_SRC"

  if [[ -L "$WRAPPER_DEST" || ! -e "$WRAPPER_DEST" ]]; then
    ln -sfn "$WRAPPER_SRC" "$WRAPPER_DEST"
    success "$WRAPPER_DEST -> $WRAPPER_SRC"
  elif cmp -s "$WRAPPER_SRC" "$WRAPPER_DEST"; then
    success "$WRAPPER_DEST already installed"
  else
    warn "$WRAPPER_DEST exists and is not managed by this repo; leaving it unchanged"
    warn "Use this wrapper directly: $WRAPPER_SRC"
  fi
}

verify_install() {
  step "verify"

  local plantuml_cmd
  if [[ -x "$WRAPPER_DEST" ]]; then
    plantuml_cmd="$WRAPPER_DEST"
  else
    plantuml_cmd="$WRAPPER_SRC"
  fi

  if ! "$plantuml_cmd" -version; then
    warn "PlantUML version check reported a problem"
  fi

  if command -v dot >/dev/null 2>&1; then
    dot -V
  else
    warn "Graphviz dot was not found in PATH; some diagrams may fail"
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  printf '@startuml\nAlice -> Bob: Hello\n@enduml\n' > "$tmp_dir/test.puml"
  if ! "$plantuml_cmd" -tsvg "$tmp_dir/test.puml" >/dev/null; then
    rm -rf "$tmp_dir"
    error "PlantUML failed to generate the test SVG"
    exit 1
  fi

  if [[ -f "$tmp_dir/test.svg" ]]; then
    success "Generated test SVG"
    rm -rf "$tmp_dir"
  else
    rm -rf "$tmp_dir"
    error "PlantUML did not generate the test SVG"
    exit 1
  fi
}

main() {
  parse_args "$@"

  local platform
  platform="$(detect_os)"

  echo ""
  info "Detected system: ${BOLD}$platform${RESET}"

  if [[ "$INSTALL_DEPS" -eq 1 ]]; then
    install_dependencies "$platform"
  else
    step "dependencies"
    warn "Skipping dependency install"
  fi

  download_jar
  install_wrapper
  verify_install

  echo ""
  success "PlantUML CLI is ready"
  echo -e "${DIM}Try: plantuml -tsvg diagram.puml${RESET}"
}

main "$@"
