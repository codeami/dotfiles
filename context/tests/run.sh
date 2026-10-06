#!/usr/bin/env bash
# Structure tests for the base context. No network, no tokens.
# S1 levels · S2 map/rooms/tools · S3 storage vs context + the session loop.
# MAP defaults to dotfiles/home/AGENTS.md; override: MAP=path bash tests/run.sh
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; DOT="$(cd "$CTX/.." && pwd)"
MAP="${MAP:-$DOT/home/AGENTS.md}"; [ -e "$MAP" ] && MAP="$(cd "$(dirname "$MAP")" && pwd)/$(basename "$MAP")"; cd "$CTX"
pass=0; fail=0; warn=0
ok(){ printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
bad(){ printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
note(){ printf '  WARN  %s\n' "$1"; warn=$((warn+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
[ -r "$MAP" ] || { echo "cannot read map: $MAP"; exit 1; }
echo "map: $MAP"
rows(){ awk '/^\| *Task/{t=1;next} t&&/^\|---/{next} t&&/^\|/{print} t&&!/^\|/{t=0}' "$MAP"; }

echo "S1  Levels: work is captured as files, not left in chats"
while IFS='|' read -r _ _ room _; do r=$(echo "$room"|grep -o '`[^`]*`'|tr -d '`'); [ -z "$r" ] && continue
  check "room $r has CONTEXT.md (the process is written down)" "[ -f '${r%/}/CONTEXT.md' ]"; done < <(rows)
check "blog room has voice.md (a refined prompt saved as a file)" "[ -f areas/blog/voice.md ]"
check "blog room has template.md (reusable structure)" "[ -f areas/blog/template.md ]"

echo "S2  Map, rooms, tools: one short map, linked into every tool"
n=$(wc -l < "$MAP"|tr -d ' ')
check "map is short enough to scan ($n ≤ 120 lines)" "[ $n -le 120 ]"
check "map has a routing table" "grep -q '^| *Task *|' '$MAP'"
check "routing table has a fallback row" "grep -qi 'ask which room' '$MAP'"
while IFS='|' read -r _ task room readfirst _; do r=$(echo "$room"|grep -o '`[^`]*`'|tr -d '`'); [ -z "$r" ] && continue
  for f in $(echo "$readfirst"|grep -o '`[^`]*`'|tr -d '`'); do check "route '$(echo $task|xargs)' → $r$f exists" "[ -e '${r%/}/$f' ]"; done
done < <(rows)
for v in .claude/CLAUDE.md .codex/AGENTS.md .config/opencode/AGENTS.md .gemini/GEMINI.md; do
  check "home.nix links ~/$v to home/AGENTS.md" "grep -A1 -F '\"$v\"' '$DOT/home.nix' | grep -q 'home/AGENTS.md'"; done
check "home.nix links ~/context to dotfiles/context" "grep -A1 -E 'home.file.\"context\"' '$DOT/home.nix' | grep -q '/context\"'"
check "no room repeats the base ('Who I am' only in the map)" "! grep -rlq '^## Who I am' areas"

echo "S3  Storage is not context, and the session loop"
check "map asks agents to report files actually read" "grep -qi 'actually read' '$MAP'"
check "map carries a canary so loading can be proven" "grep -q '^ctx-canary: ' '$MAP'"
check "map says what to do on \"end of session\"" "grep -qi 'end of session' '$MAP'"
check "map forbids editing itself from a session" "grep -qi 'never edit this file' '$MAP'"
check "session template has 'Where the AI went its own way'" "grep -q '^## Where the AI went its own way' inbox/_template.md"
check "session template has 'Files read'" "grep -q '^## Files read' inbox/_template.md"
check "inbox/sessions/ exists" "[ -d inbox/sessions ]"

echo "Live links (Mac only, after ./rebuild.sh)"
for v in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$HOME/context/inbox"; do
  [ -e "$v" ] && ok "$v present" || note "$v not linked yet"; done
echo; echo "passed $pass · failed $fail · warnings $warn"; [ $fail -eq 0 ]
