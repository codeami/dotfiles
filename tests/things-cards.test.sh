#!/usr/bin/env bash
# Every card in second-brain/things/ (except _template.md) must have all six
# 5W1H slots (who, what, when, where, why, how) in both the PRODUCT and TECH blocks.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

THINGS="$ROOT/second-brain/things"
SLOTS="who what when where why how"
count=0

for card in "$THINGS"/*.md; do
  name=$(basename "$card")
  case "$name" in _template.md) continue ;; esac
  count=$((count + 1))
  for block in PRODUCT TECH; do
    body=$(awk -v b="## $block" '
      $0 == b { on = 1; next }
      /^## / { on = 0 }
      on' "$card")
    [ -n "$body" ] || fail "$name: missing block $block"
    for slot in $SLOTS; do
      printf '%s\n' "$body" | grep -q "^- $slot: " || fail "$name: $block block has no '$slot' slot"
    done
  done
done

[ "$count" -gt 0 ] || fail "no cards found in second-brain/things/"
pass "things-cards: $count cards have all six slots in PRODUCT and TECH"
