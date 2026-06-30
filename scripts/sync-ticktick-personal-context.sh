#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}OK${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}ERROR${RESET} $*"; }

usage() {
  cat <<'EOF'
Usage:
  bash scripts/sync-ticktick-personal-context.sh pull
  bash scripts/sync-ticktick-personal-context.sh push

Actions:
  pull, download, fetch   Download personal-context/ from 1Password
  push, upload            Upload local personal-context/ to 1Password

Environment:
  OP_TICKTICK_PERSONAL_CONTEXT_ITEM   1Password item title
                                     default: dotfiles/ticktick-personal-context
  OP_TICKTICK_PERSONAL_CONTEXT_VAULT  Optional 1Password vault name

The script stores shared/.agents/skills/ticktick/personal-context/ as a
gzipped tar archive in a 1Password Document item.
EOF
}

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$DOTFILES_DIR/shared/.agents/skills/ticktick"
CONTEXT_NAME="personal-context"
CONTEXT_DIR="$SKILL_DIR/$CONTEXT_NAME"
ARCHIVE_NAME="ticktick-personal-context.tar.gz"

OP_ITEM="${OP_TICKTICK_PERSONAL_CONTEXT_ITEM:-dotfiles/ticktick-personal-context}"
OP_VAULT="${OP_TICKTICK_PERSONAL_CONTEXT_VAULT:-}"

ACTION="${1:-}"
TMP_DIR=""

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

require_command() {
  if ! command -v "$1" &>/dev/null; then
    error "$1 is required but was not found"
    exit 1
  fi
}

make_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/ticktick-personal-context.XXXXXX"
}

ensure_1password() {
  local signin_output

  require_command op

  if ! op whoami &>/dev/null 2>&1; then
    info "Not signed in to 1Password; starting sign-in..."
    signin_output="$(op signin)" || { error "1Password sign-in failed"; exit 1; }
    eval "$signin_output" || { error "1Password sign-in failed"; exit 1; }
  fi
}

vault_flag=()
[[ -n "$OP_VAULT" ]] && vault_flag=(--vault "$OP_VAULT")

download_document() {
  local out_file="$1"

  op document get "$OP_ITEM" \
    ${vault_flag[@]+"${vault_flag[@]}"} \
    --out-file "$out_file" \
    >/dev/null
}

document_exists() {
  local probe_file="$TMP_DIR/probe.tar.gz"
  download_document "$probe_file" >/dev/null 2>&1
}

validate_archive() {
  local archive="$1"
  local entry
  local found=0

  if ! tar -tzf "$archive" >/dev/null; then
    error "Downloaded archive is not a readable tar.gz file"
    exit 1
  fi

  while IFS= read -r entry; do
    case "$entry" in
      /*|*../*|../*|*'/..')
        error "Refusing to extract unsafe archive path: $entry"
        exit 1
        ;;
      "$CONTEXT_NAME"|"$CONTEXT_NAME/"|"$CONTEXT_NAME"/*)
        found=1
        ;;
      *)
        error "Archive does not look like $CONTEXT_NAME/: $entry"
        exit 1
        ;;
    esac
  done < <(tar -tzf "$archive")

  if [[ "$found" -ne 1 ]]; then
    error "Archive is empty or missing $CONTEXT_NAME/"
    exit 1
  fi
}

push_context() {
  if [[ ! -d "$CONTEXT_DIR" ]]; then
    error "$CONTEXT_DIR does not exist"
    info "Create it first, or run:"
    echo "    bash scripts/sync-ticktick-personal-context.sh pull"
    exit 1
  fi

  TMP_DIR="$(make_tmp_dir)"
  local archive="$TMP_DIR/$ARCHIVE_NAME"

  require_command tar
  ensure_1password

  info "Creating archive from $CONTEXT_DIR..."
  tar -czf "$archive" -C "$SKILL_DIR" "$CONTEXT_NAME"

  if document_exists; then
    info "Updating 1Password document: $OP_ITEM"
    op document edit "$OP_ITEM" "$archive" \
      ${vault_flag[@]+"${vault_flag[@]}"} \
      --file-name "$ARCHIVE_NAME" \
      >/dev/null
  else
    info "Creating 1Password document: $OP_ITEM"
    op document create "$archive" \
      ${vault_flag[@]+"${vault_flag[@]}"} \
      --title "$OP_ITEM" \
      --file-name "$ARCHIVE_NAME" \
      --tags "dotfiles,ticktick" \
      >/dev/null
  fi

  success "Uploaded $CONTEXT_NAME/ to 1Password"
}

pull_context() {
  TMP_DIR="$(make_tmp_dir)"
  local archive="$TMP_DIR/$ARCHIVE_NAME"
  local backup=""

  require_command tar
  ensure_1password

  info "Downloading 1Password document: $OP_ITEM"
  if ! download_document "$archive"; then
    error "Item '$OP_ITEM' not found in 1Password"
    info "Upload it first with:"
    echo "    bash scripts/sync-ticktick-personal-context.sh push"
    exit 1
  fi

  validate_archive "$archive"

  if [[ -e "$CONTEXT_DIR" ]]; then
    backup="${CONTEXT_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Existing $CONTEXT_NAME/ found; moving it to $backup"
    mv "$CONTEXT_DIR" "$backup"
  fi

  mkdir -p "$SKILL_DIR"

  if tar -xzf "$archive" -C "$SKILL_DIR"; then
    success "Downloaded $CONTEXT_NAME/ to $CONTEXT_DIR"
    [[ -n "$backup" ]] && warn "Previous copy kept at $backup"
  else
    error "Extraction failed"
    if [[ -n "$backup" && -e "$backup" ]]; then
      mv "$backup" "$CONTEXT_DIR"
      warn "Restored previous $CONTEXT_NAME/"
    fi
    exit 1
  fi
}

case "$ACTION" in
  pull|download|fetch)
    pull_context
    ;;
  push|upload)
    push_context
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    error "Unknown action: $ACTION"
    echo
    usage
    exit 1
    ;;
esac
