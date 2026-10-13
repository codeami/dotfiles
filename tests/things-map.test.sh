#!/usr/bin/env bash
# The easywiki map (second-brain/things/map/): builder output is deterministic,
# edges point at real nodes, full cards have all twelve slots, the page is
# self-contained, and the committed data matches a fresh build.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MAP="$ROOT/second-brain/things/map"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/things-map.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

build() { python3 "$MAP/build.py" --out "$1/data.json" --html "$1/index.html" >/dev/null || fail "build.py failed"; }

for d in a b; do mkdir "$tmp/$d"; cp "$MAP/index.html" "$tmp/$d/index.html"; build "$tmp/$d"; done
cmp -s "$tmp/a/data.json" "$tmp/b/data.json" || fail "things-map: data.json differs between two runs"
cmp -s "$tmp/a/index.html" "$tmp/b/index.html" || fail "things-map: index.html differs between two runs"
cmp -s "$tmp/a/data.json" "$MAP/data.json" || fail "things-map: committed data.json is stale, run map/build.py"
cmp -s "$tmp/a/index.html" "$MAP/index.html" || fail "things-map: inline data in index.html is stale, run map/build.py"

python3 - "$MAP/data.json" <<'PY' || fail "things-map: data check failed"
import json, sys
d = json.load(open(sys.argv[1]))
ids = {n["id"] for n in d["nodes"]}
assert len(ids) == len(d["nodes"]), "duplicate node id"
for e in d["edges"]:
    assert e["from"] in ids and e["to"] in ids, "edge points at a missing node: %s" % e
    assert e["source"] == "card" and e["votes"] == 0 and e["why"], "bad edge: %s" % e
slots = ["who", "what", "when", "where", "why", "how"]
full = [n for n in d["nodes"] if not n["stub"]]
assert full, "no full cards"
for n in full:
    for block in ("product", "tech"):
        for s in slots:
            assert s in n[block] and n[block][s]["text"], "%s %s.%s missing" % (n["id"], block, s)
            assert n[block][s]["source"] in ("source-backed", "model-drafted", "captain"), "%s %s.%s source" % (n["id"], block, s)
anv = [n for n in d["nodes"] if n["id"] == "anvaka-map-of-github"]
assert anv and anv[0]["stub"] and "2025-05-10" in anv[0]["line"] and "shared stargazers" in anv[0]["line"], "map-of-github stub"
PY

# No resource loads. Links shown as text in the data are fine.
if grep -Eq '(src|href|action|poster)="(https?:)?//|url\(|@import|<link|<img|<iframe|<script[^>]* src=|fetch\(|XMLHttpRequest|WebSocket|sendBeacon' "$MAP/index.html"; then
  fail "things-map: index.html loads an outside resource"
fi
grep -q 'type="application/json"' "$MAP/index.html" || fail "things-map: no inline data block"

pass "things-map: deterministic build, valid edges, 12 slots per card, page loads nothing"
