#!/usr/bin/env bash
# Full setup — runs all steps in order.
# To run a single step: bash 01-packages.sh / 02-verify-ssh.sh / 03-work.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$DIR/01-packages.sh"
bash "$DIR/02-verify-ssh.sh"
bash "$DIR/03-work.sh"
