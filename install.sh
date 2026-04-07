#!/usr/bin/env bash
# Full setup — runs all steps in order.
# To run a single step: bash 01-packages.sh / 02-verify-ssh.sh / 03-work.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$DIR/01-packages.sh"
bash "$DIR/02-verify-ssh.sh"
bash "$DIR/03-work.sh"

# ─── project folder structure ─────────────────────────────────────────────────
echo ""
echo -e "\033[1m==> Creating project folders...\033[0m"
mkdir -p "$HOME/Projects/Personal" "$HOME/Projects/Others"
echo -e "\033[32m    ✓ ~/Projects/Personal\033[0m"
echo -e "\033[32m    ✓ ~/Projects/Others\033[0m"
# ~/Projects/Work/<Company> dirs are created by dotfiles-work/install.sh
