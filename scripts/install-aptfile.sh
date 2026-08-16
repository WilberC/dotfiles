#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APTFILE="$ROOT_DIR/os/linux/Aptfile"

if [[ ! -f "$APTFILE" ]]; then
  echo "Aptfile not found: $APTFILE" >&2
  exit 1
fi

if ! command -v apt >/dev/null 2>&1; then
  echo "apt was not found. This script is for Debian/Ubuntu systems." >&2
  exit 1
fi

mapfile -t packages < <(
  sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d' "$APTFILE"
)

# Debian ships the chromium package under a different name than Ubuntu.
if [[ -r /etc/os-release ]] && . /etc/os-release && [[ "${ID:-}" == "debian" ]]; then
  for i in "${!packages[@]}"; do
    if [[ "${packages[$i]}" == "chromium-browser" ]]; then
      packages[$i]="chromium"
    fi
  done
fi

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No packages found in $APTFILE"
  exit 0
fi

sudo apt update
sudo apt install -y "${packages[@]}"
