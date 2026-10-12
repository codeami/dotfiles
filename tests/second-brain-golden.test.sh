#!/usr/bin/env bash
# Behavior checks for second-brain/scripts/golden.py: deterministic keyword
# ranking, per-category Recall@5 / Hit@5 / abstain rate, fixture overlay and
# the supersession structure check. No model or network call anywhere.
set -u -o pipefail

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

GOLDEN="${GOLDEN_PY:-$ROOT/second-brain/scripts/golden.py}"
FIX="$ROOT/tests/fixtures/second-brain-golden"

run() { python3 "$GOLDEN" --nodes "$FIX/nodes" --questions "$FIX/questions.tsv" --fixtures "${1:-$FIX/fixtures}" --k 1 --threshold 1 2>&1 | tr -s ' '; }

out=$(run); rc=$?
[ "$rc" -eq 0 ] || fail "runner failed (rc=$rc): $out"
assert_contains "$out" "single 2 0.50 0.50 -" "single row: one of two found should score 0.50/0.50"
pass "single-source scoring counts a miss"

assert_contains "$out" "no-answer 1 - - 1.00" "unrelated question must abstain"
pass "no-answer question abstains"

assert_contains "$out" "contradiction 1 1.00 1.00 -" "overlay fixture node must be retrievable"
assert_contains "$out" "supersession: ok" "well-formed fixture should pass the supersession check"
pass "fixture overlay and supersession check"

out=$(run "$FIX/fixtures-broken-does-not-exist"); rc=$?
[ "$rc" -ne 0 ] || fail "missing fixture dir must not exit 0"
pass "missing fixture dir fails"

# broken fixture: older position not marked superseded -> reported
out=$(run "$FIX/fixtures-broken")
assert_contains "$out" "supersession: FAIL" "unmarked older position must fail the check"
pass "unmarked older position fails the supersession check"

# determinism: two runs are byte-identical
a=$(run); b=$(run)
[ "$a" = "$b" ] || fail "runner output is not deterministic"
pass "output is deterministic"

# real nodes untouched by a run
before=$(find "$ROOT/second-brain/nodes" -type f -exec shasum {} + | sort)
python3 "$GOLDEN" >/dev/null 2>&1
after=$(find "$ROOT/second-brain/nodes" -type f -exec shasum {} + | sort)
[ "$before" = "$after" ] || fail "runner modified nodes"
pass "runner is read-only on real nodes"

# hub nodes (front matter `type: hub`) are reading orders, not evidence: they must not take ranking slots
out=$(python3 "$GOLDEN" --nodes "$FIX/hubs/nodes" --questions "$FIX/hubs/questions.tsv" --fixtures "$FIX/fixtures" --k 1 --threshold 1 2>&1 | tr -s ' ')
assert_contains "$out" "single 1 1.00 1.00 -" "a hub must not outrank the real node"
pass "hub nodes are skipped when ranking"
