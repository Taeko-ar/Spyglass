#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/var/home/taeko/Documents/Patagonia/Interface/AddOns/Spyglass"

rsync -av --delete --exclude='.git' --exclude='deploy.sh' "$SRC/" "$DEST/"
