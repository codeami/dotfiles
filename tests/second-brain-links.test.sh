#!/usr/bin/env bash
# Behavior checks for second-brain/scripts/check_links.py: dangling links,
# orphan nodes, clean exit, read-only, and a malformed-frontmatter fixture.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

CHECK="${CHECK_LINKS:-$ROOT/second-brain/scripts/check_links.py}"
FIX="$ROOT/tests/fixtures/second-brain"

run() { python3 "$CHECK" "$1" 2>&1; }

# clean fixture: exit 0, no output
out=$(run "$FIX/clean/nodes"); rc=$?
[ "$rc" -eq 0 ] || fail "clean fixture should exit 0 (got $rc: $out)"
[ -z "$out" ] || fail "clean fixture should print nothing (got: $out)"
pass "clean fixture exits 0 and prints nothing"

# broken fixture: nonzero, dangling + orphan reported as file:line message
out=$(run "$FIX/broken/nodes"); rc=$?
[ "$rc" -ne 0 ] || fail "broken fixture should exit nonzero"
assert_contains "$out" "a.md:3: link to missing node 'ghost'" "dangling link not reported with file:line"
assert_contains "$out" "lonely.md:1: orphan" "orphan node not reported"
assert_not_contains "$out" "b.md" "b.md is linked and has valid links; must not be flagged"
pass "broken fixture reports a dangling link and an orphan"

# multi-line YAML list, quoted items, and [[wikilink]] brackets are understood
tmp=$(dotfiles_test_tmproot sb-links); mkdir -p "$tmp/nodes"
printf -- '---\ntags: [t]\nlinks:\n  - "b"\n  - [[c]]\nsource: s\n---\n' > "$tmp/nodes/a.md"
printf -- '---\nlinks: [a]\n---\n' > "$tmp/nodes/b.md"
printf -- '---\nlinks: [a]\n---\n' > "$tmp/nodes/c.md"
out=$(run "$tmp/nodes"); rc=$?
[ "$rc" -eq 0 ] || fail "multi-line/quoted/wikilink forms should parse clean (rc=$rc: $out)"
pass "multi-line, quoted and [[wikilink]] link forms parse"

# list items under a later key (tags:) are not links
printf -- '---\nlinks:\n  - b\n  - c\ntags:\n  - zzz\n---\n' > "$tmp/nodes/a.md"
out=$(run "$tmp/nodes"); rc=$?
[ "$rc" -eq 0 ] || fail "list items under a later key were read as links (rc=$rc: $out)"
pass "list items after the links list are ignored"

# self-link does not rescue an orphan
printf -- '---\nlinks: [a, c]\n---\n' > "$tmp/nodes/a.md"
printf -- '---\nlinks: [c]\n---\n' > "$tmp/nodes/b.md"
printf -- '---\nlinks: [b]\n---\n' > "$tmp/nodes/c.md"
out=$(run "$tmp/nodes")
assert_contains "$out" "a.md:1: orphan" "a node linked only by itself or nothing must be an orphan"
pass "node with no inbound link is an orphan"

# a node with no links: line is not an error by itself
rm -rf "$tmp/nodes"; mkdir -p "$tmp/nodes"
printf -- '---\ntags: [t]\n---\n' > "$tmp/nodes/solo.md"
out=$(run "$tmp/nodes")
assert_contains "$out" "solo.md:1: orphan" "lone node with no links line should be an orphan"
assert_not_contains "$out" "missing" "no links line must not create dangling findings"
pass "missing links: line handled"

# read-only: running the check changes no file
before=$(find "$FIX" -type f -exec shasum {} + | sort)
run "$FIX/broken/nodes" >/dev/null
after=$(find "$FIX" -type f -exec shasum {} + | sort)
[ "$before" = "$after" ] || fail "checker modified files"
pass "checker is read-only"

# missing directory is a clear error, not a clean pass
out=$(run "$tmp/does-not-exist"); rc=$?
[ "$rc" -ne 0 ] || fail "missing nodes dir must not exit 0"
pass "missing nodes dir exits nonzero"
