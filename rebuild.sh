#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
[ "$(readlink ~/.dotfiles 2>/dev/null)" = "$DIR" ] || ln -sfn "$DIR" ~/.dotfiles

# Works whether you run ./rebuild.sh or sudo ./rebuild.sh. sudo resets PATH to a
# secure default that excludes the nix profiles, so look in the system profile
# as well as on PATH, and only add sudo when we are not root already.
DARWIN_REBUILD="$(command -v darwin-rebuild || true)"
[ -n "$DARWIN_REBUILD" ] || DARWIN_REBUILD=/run/current-system/sw/bin/darwin-rebuild
if [ ! -x "$DARWIN_REBUILD" ]; then
  echo "darwin-rebuild not found. Run ./bootstrap.sh first." >&2
  exit 1
fi

# The host label - if you renamed it, change it here, in flake.nix, and in
# bootstrap.sh too.
if [ "$(id -u)" -eq 0 ]; then
  exec "$DARWIN_REBUILD" switch --flake "$DIR#mac"
else
  exec sudo "$DARWIN_REBUILD" switch --flake "$DIR#mac"
fi
