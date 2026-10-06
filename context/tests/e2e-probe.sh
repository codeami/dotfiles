#!/usr/bin/env bash
# End-to-end: ask each installed agent for the canary from a fresh, empty folder.
# If it answers correctly, the base context really reached that tool.
# Costs a few tokens per tool. Run on the Mac after wiring (see README).
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; MAP="${MAP:-$CTX/../home/AGENTS.md}"
CANARY=$(sed -n 's/^ctx-canary: //p' "$MAP")
Q="What is the context canary? Reply with the canary value only."
TMP=$(mktemp -d); cd "$TMP"
pass=0; fail=0; skip=0
probe() { # name, command...
  local name=$1; shift
  if ! command -v "$1" >/dev/null 2>&1; then echo "  SKIP  $name (not installed)"; skip=$((skip+1)); return; fi
  out=$(timeout 120 "$@" 2>/dev/null | tail -5)
  if echo "$out" | grep -q "$CANARY"; then echo "  PASS  $name loaded the base"; pass=$((pass+1))
  else echo "  FAIL  $name did not return the canary: $(echo "$out" | tr '\n' ' ' | cut -c1-80)"; fail=$((fail+1)); fi
}
echo "Probing from $TMP for canary '$CANARY'"
probe "Claude Code" claude -p "$Q"
probe "Codex"       codex exec --skip-git-repo-check "$Q"
probe "Gemini CLI"  gemini -p "$Q"
probe "OpenCode"    opencode run "$Q"
rm -rf "$TMP"
echo; echo "passed $pass · failed $fail · skipped $skip"
[ $fail -eq 0 ]
