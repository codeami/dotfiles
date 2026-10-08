#!/usr/bin/env bash
# Structure tests for the factory chain (areas/factory). No network, no tokens.
# T1 router · T2 contracts · T3 references · T4 size caps · T5 map row · T6 one-way · T7-T9 chain-check.
# FM defaults to ~/github/firstmate (T3 and T6 skip with a WARN if it is absent).
# MAP defaults to dotfiles/home/AGENTS.md; while the new map is unmerged, T5 reads AGENTS.proposed.md.
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; DOT="$(cd "$CTX/.." && pwd)"; cd "$CTX"
FM="${FM:-$HOME/github/firstmate}"; MAP="${MAP:-$DOT/home/AGENTS.md}"
R=areas/factory; FX=tests/fixtures/chain
pass=0; fail=0; warn=0
ok(){ printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
bad(){ printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
note(){ printf '  WARN  %s\n' "$1"; warn=$((warn+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
stages=$(awk -F'|' '/^\| *0[0-9] *\|/{gsub(/ /,"",$2);print $2}' $R/CONTEXT.md | tr '\n' ' ')

echo "T1  Router: stages 01 to 08, contiguous, each with a gate"
check "stages are '01 02 03 04 05 06 07 08' (got: $stages)" "[ '$stages' = '01 02 03 04 05 06 07 08 ' ]"
check "every router row ends in a gate of yes, no or conditional" \
  "[ \$(awk -F'|' '/^\| *0[0-9] *\|/{g=\$(NF-1); if (g ~ /yes|no|conditional/) n++} END{print n+0}' $R/CONTEXT.md) -eq 8 ]"

echo "T2  Contracts: every stage folder has Inputs, Process, Outputs, Human gate"
for d in $R/0*/; do for h in Inputs Process Outputs 'Human gate'; do
  check "${d#$R/}CONTEXT.md has '## $h'" "grep -q '^## $h' '${d}CONTEXT.md'"; done; done

echo "T3  References: Inputs files exist and quoted headings are in them"
if [ -d "$FM" ]; then
  for c in $R/0*/CONTEXT.md; do
    while IFS='|' read -r _ _ file sect _; do
      f=$(echo "$file" | grep -o '`~/[^`]*`' | tr -d '`'); [ -z "$f" ] && continue
      f="${f/#\~\/github\/firstmate/$FM}"; f="${f/#\~/$HOME}"
      check "$c → $f exists" "[ -f '$f' ]"
      h=$(echo "$sect" | grep -o '"[^"]*"' | head -1 | tr -d '"')
      [ -n "$h" ] && check "$c → heading '$h' in $(basename "$f")" "grep -qFx '$h' '$f'"
    done < <(awk '/^## Inputs/{t=1;next} /^## /{t=0} t&&/^\|/&&!/^\|(---| *Source)/' "$c")
  done
else note "T3 skipped: $FM not found"; fi

echo "T4  Size caps (about 4 bytes per token)"
check "router ≤ 2000 B" "[ \$(wc -c < $R/CONTEXT.md) -le 2000 ]"
for c in $R/0*/CONTEXT.md; do check "$c ≤ 2000 B" "[ \$(wc -c < $c) -le 2000 ]"; done
check "map ≤ 120 lines" "[ \$(wc -l < '$MAP') -le 120 ]"

echo "T5  Map routes areas/factory/ and its read-first files exist"
m="$MAP"; grep -q '^| *Task *|' "$m" || { m="$CTX/AGENTS.proposed.md"; note "T5 reads AGENTS.proposed.md (map not merged yet)"; }
row=$(grep -F '`areas/factory/`' "$m" | head -1)
check "routing row for areas/factory/ exists" "[ -n '$row' ]"
for f in $(echo "$row" | awk -F'|' '{print $4}' | grep -o '`[^`]*`' | tr -d '`'); do check "read-first $f exists" "[ -e $R/$f ]"; done

echo "T6  One-way dependency: Firstmate never points back here"
if [ -d "$FM" ]; then
  check "no ~/context or areas/factory in Firstmate AGENTS.md, bin, docs, .agents" \
    "! grep -rlE '~/context|areas/factory' '$FM/AGENTS.md' '$FM/bin' '$FM/docs' '$FM/.agents' 2>/dev/null | grep -q ."
else note "T6 skipped: $FM not found"; fi

echo "T7-T9  chain-check on fixtures"
check "T7 passes fixtures/chain/ok" "bin/chain-check $FX/ok >/dev/null"
check "T8 fails bad-orphan-criterion (A with no I)" "! bin/chain-check $FX/bad-orphan-criterion >/dev/null"
check "T9 fails bad-unapproved (02 exists, 01 not approved)" "! bin/chain-check $FX/bad-unapproved >/dev/null"
echo; echo "passed $pass · failed $fail · warnings $warn"; [ $fail -eq 0 ]
