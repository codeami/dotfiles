#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# Resolve the absolute path first: sudo resets PATH to a secure default that
# excludes the nix profiles, the same trap bootstrap.sh works around.
DARWIN_REBUILD="$(command -v darwin-rebuild || true)"
if [ -z "$DARWIN_REBUILD" ]; then
  echo "darwin-rebuild not found on PATH. Run ./bootstrap.sh first." >&2
  exit 1
fi
exec sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#mac
