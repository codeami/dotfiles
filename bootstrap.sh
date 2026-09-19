#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# has to exist before the first switch or the build will fail to find them.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: personalize the configured username"
# Do this before any sudo call: sudo resets $USER to root, so whoami has to
# run as the real interactive user first.
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ -z "$FLAKE_USER" ]; then
  echo "    Could not find the single \"user = \" line in flake.nix."
  echo "    Edit flake.nix yourself before continuing."
  exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i '' -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    echo "    Updated. Review the change with: git diff flake.nix"
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

echo "==> Step 4: turn on the nix-command and flakes experimental features"
# Determinate's installer enables these for you. A nix that was already on the
# machine from some other installer has them off, and without them step 5 dies
# with "experimental Nix feature 'nix-command' is disabled".
# `nix config show` is itself a nix-command, so it only answers once the
# features are on - which is exactly the question being asked here.
# Both root and you are asked, because sudo's root reads /var/root for user
# config: a line in ~/.config/nix/nix.conf would satisfy the first check and
# still leave step 5 broken. /etc/nix/nix.conf is the system config both read.
features_on() {
  local out
  out="$("$@" config show experimental-features 2>/dev/null || true)"
  [[ "$out" == *nix-command* && "$out" == *flakes* ]]
}
# sudo resets PATH to a secure default that excludes /nix/.../bin, so a
# freshly installed `nix` would not be found under sudo even though it's
# on PATH here. Resolve the absolute path and invoke that from here on.
NIX_BIN="$(command -v nix)"
if features_on "$NIX_BIN" && features_on sudo "$NIX_BIN"; then
  echo "    already enabled"
else
  echo "    adding \"experimental-features = nix-command flakes\" to /etc/nix/nix.conf"
  # Appending is safe: nix-darwin leaves this file alone (see nix.enable in
  # configuration.nix), and a later line wins over an earlier one in nix.conf.
  echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf >/dev/null
  if ! features_on "$NIX_BIN" || ! features_on sudo "$NIX_BIN"; then
    echo "    nix still reports both features as off."
    echo "    Make /etc/nix/nix.conf contain this line by hand, then re-run ./bootstrap.sh:"
    echo "      experimental-features = nix-command flakes"
    exit 1
  fi
  echo "    done"
fi

echo "==> Step 5: first darwin-rebuild switch (pinned to nix-darwin-26.05)"
# darwin-rebuild doesn't exist yet on a fresh machine, so run it straight
# from the flake this once. After this, rebuild.sh works normally.
# This fetches the darwin-rebuild tool from the nix-darwin-26.05 release branch,
# not the exact flake.lock revision. The system config it applies is still pinned
# by this repo's flake.lock.
# nix warns "$HOME is not owned by you" under sudo: macOS sudo hands root your
# HOME, and nix refuses a home it does not own, using /var/root instead. Harmless.
# "mac" is the flake host label - if you renamed it, change it in flake.nix
# and rebuild.sh too.
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac
# If this still fails with "nix: command not found", open a new terminal
# (Determinate adds nix to new shells' PATH) and re-run ./bootstrap.sh.

echo "==> Done. Use ./rebuild.sh for future changes."
