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

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No packages found in $APTFILE"
  exit 0
fi

sudo apt update
sudo apt install -y "${packages[@]}"
