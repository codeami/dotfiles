#!/usr/bin/env bash
# Tests for bin/taste-check (the intent gates of areas/factory). No network, no tokens, no model.
# U1 intent · U2 seal · U3 spec · U4 result · U5 ask · U6 transcript · U7 exit status and bad input.
# Fixtures: tests/fixtures/taste (README.md lists what each folder breaks).
# TASTE_CHECK overrides the checker under test; tests/mutate-taste.py uses that to prove these tests bite.
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; cd "$CTX"
TC="${TASTE_CHECK:-$CTX/bin/taste-check}"; FX=tests/fixtures/taste
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
bad(){ printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
run(){ OUT=$("$TC" "$@" 2>&1); RC=$?; }
# fails_only ID cmd...  : exit 1, and every FAIL line carries ID (at least one does)
fails_only(){ local id=$1; shift; run "$@"; local ids; ids=$(printf '%s\n' "$OUT" | awk '$1=="FAIL" && NF>2 {print $2}' | sort -u | tr '\n' ' ')
  [ $RC -eq 1 ] && [ "$ids" = "$id " ]; }
# passes cmd... : exit 0 and no FAIL line
passes(){ run "$@"; [ $RC -eq 0 ] && ! printf '%s\n' "$OUT" | grep -q '^FAIL '; }
says(){ printf '%s\n' "$OUT" | grep -q -- "$1"; }
fresh(){ rm -rf "$T/$2"; cp -R "$FX/$1" "$T/$2"; }

echo "U1  intent: verbatim I lines and a sealed approval"
check "ok passes" "passes intent $FX/ok"
check "bad-unsaid-line fails TG1 only, naming the line" "fails_only TG1 intent $FX/bad-unsaid-line && says 'I1 is not something the captain said'"
check "bad-unsealed fails TG2 only" "fails_only TG2 intent $FX/bad-unsealed"
check "bad-edited-after-seal fails TG2 only (words match, hash does not)" "fails_only TG2 intent $FX/bad-edited-after-seal && says 'changed after approval'"
check "bad-blocking-open fails TG2 only, naming the question" "fails_only TG2 intent $FX/bad-blocking-open && says 'blocking question is open'"
check "warn-date-only passes with a TG2 WARN" "passes intent $FX/warn-date-only && says '^WARN TG2'"
fresh ok noI; printf '## Captain'"'"'s words\n' > "$T/noI/01-intent.md"
check "an intent with no I lines fails TG1" "run intent $T/noI; [ \$RC -eq 1 ] && says 'FAIL TG1 01-intent.md has no I lines'"
fresh ok ctx; sed -i.bak 's/^I5: context: .*/I5: context: something nobody said./' "$T/ctx/01-intent.md"
check "a context: line needs no verbatim match (but the hash moves, so TG2)" "fails_only TG2 intent $T/ctx"
fresh ok mal; sed -i.bak 's/^approved: .*/approved: yesterday/' "$T/mal/01-intent.md"
check "a malformed approved line fails TG2" "fails_only TG2 intent $T/mal && says malformed"

echo "U2  seal: write the approved line only on his word"
fresh bad-unsealed s1
check "seal writes who, date, a 12-hex hash and the source" \
  "run seal $T/s1 --who captain --source 'chat 14:02' --today 2026-10-08; [ \$RC -eq 0 ] && printf '%s\n' \"\$OUT\" | grep -Eq '^approved: 2026-10-08 captain [0-9a-f]{12} via chat 14:02\$'"
check "the sealed intent now passes" "passes intent $T/s1"
check "the approved line is on top (chain-check reads the first 5 lines)" "head -1 $T/s1/01-intent.md | grep -q '^approved: 2026-10-08 captain'"
check "sealing twice leaves one approved line" \
  "run seal $T/s1 --who captain --source again --today 2026-10-09; [ \$(grep -c '^approved:' $T/s1/01-intent.md) -eq 1 ]"
fresh bad-blocking-open s2; cp "$T/s2/01-intent.md" "$T/s2/before"
check "seal refuses while a blocking question is open" "run seal $T/s2 --who captain --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'blocking question'"
check "a refused seal leaves the file as it was" "cmp -s $T/s2/01-intent.md $T/s2/before"
fresh bad-edited-after-seal s3
check "re-sealing blesses the edit, and the intent then passes" "run seal $T/s3 --who captain --source chat --today 2026-10-08; passes intent $T/s3"
check "seal needs --who" "run seal $T/s1 --source chat; [ \$RC -ne 0 ]"
check "seal without --today uses today's date" \
  "fresh bad-unsealed s4; run seal $T/s4 --who captain --source chat; printf '%s\n' \"\$OUT\" | grep -q \"^approved: \$(date +%Y-%m-%d) \""

echo "U3  spec: chain-check coverage, then hard words carried"
check "ok passes, and a derived criterion is passed on as a WARN for the captain" "passes spec $FX/ok && says '^WARN CHAIN ask: A5 is derived'"
check "bad-spec-number fails TG3 only, naming the number and the bound word" "fails_only TG3 spec $FX/bad-spec-number && says \"number '150'\" && says \"'bound' kind\""
check "bad-spec-quoted fails TG3 only" "fails_only TG3 spec $FX/bad-spec-quoted && says \"quoted 'night'\""
check "bad-spec-negation fails TG3 only" "fails_only TG3 spec $FX/bad-spec-negation && says \"'negation' kind\""
check "bad-spec-only fails TG3 only" "fails_only TG3 spec $FX/bad-spec-only && says \"'only' kind\""
check "bad-spec-uncovered fails CHAIN only, with chain-check's own words" "fails_only CHAIN spec $FX/bad-spec-uncovered && says 'I4 is not covered'"
check "bad-spec-orphan fails CHAIN only" "fails_only CHAIN spec $FX/bad-spec-orphan && says 'A3 cites no I'"
check "an unapproved intent with a 02 fails CHAIN (chain-check refuses it)" "fails_only CHAIN spec $FX/bad-unsealed && says 'approved'"
check "no 02-spec.md is a clean failure, not a crash" "fresh ok no02; rm $T/no02/02-spec.md; run spec $T/no02; [ \$RC -eq 1 ] && says 'FAIL IO'"
mkdir -p "$T/lone"; cp "$TC" "$T/lone/taste-check"
check "without chain-check beside it, spec fails CHAIN rather than skipping coverage" \
  "OUT=\$(python3 $T/lone/taste-check spec $FX/ok 2>&1); RC=\$?; [ \$RC -eq 1 ] && says 'FAIL CHAIN' && says 'chain-check'"

echo "U4  result: a row per I, evidence that resolves, an Unrequested section"
R="--root $FX/ok/root"
check "ok passes" "passes result $FX/ok $R"
for d in missing-row extra-row outcome; do
  check "bad-result-$d fails TG4 only" "fails_only TG4 result $FX/bad-result-$d --root $FX/bad-result-$d/root"; done
check "TG4 names the missing I" "fails_only TG4 result $FX/bad-result-missing-row --root $FX/ok/root && says 'I3 has no row'"
check "TG4 names the invented I" "fails_only TG4 result $FX/bad-result-extra-row --root $FX/ok/root && says 'row I9'"
check "TG4 names the bad outcome" "fails_only TG4 result $FX/bad-result-outcome --root $FX/ok/root && says \"outcome 'done'\""
check "bad-result-no-evidence fails TG5 only" "fails_only TG5 result $FX/bad-result-no-evidence --root $FX/ok/root && says 'cites no evidence'"
for d in dead-file:'does not exist' dead-line:'has [0-9]* lines' dead-heading:'no heading' dead-test:'no test named'; do
  check "bad-result-${d%%:*} fails TG5 only, saying why" "fails_only TG5 result $FX/bad-result-${d%%:*} --root $FX/ok/root && says '${d#*:}'"; done
check "bad-result-no-unrequested fails TG6 only" "fails_only TG6 result $FX/bad-result-no-unrequested --root $FX/ok/root"
check "warn-result-url passes with a TG5 WARN" "passes result $FX/warn-result-url --root $FX/ok/root && says '^WARN TG5'"
check "a changed row with a dead pointer fails TG5, like a delivered one" \
  "fresh ok ch; sed -i.bak 's/^| I1 | delivered | src\/header.ts:2-4 |/| I1 | changed | src\/gone.ts:1 |/' $T/ch/06-result.md; fails_only TG5 result $T/ch --root $T/ch/root"
check "a not-delivered row needs no evidence" \
  "fresh ok nd; sed -i.bak 's/^| I1 | delivered | src\/header.ts:2-4 |/| I1 | not-delivered | - |/' $T/nd/06-result.md; passes result $T/nd --root $T/nd/root"
check "without --root, pointers resolve against the run folder" \
  "fresh ok rr; cp -R $T/rr/root/. $T/rr/; passes result $T/rr"

echo "U5  ask: which questions does an ask already answer"
check "a precise ask answers all 12" "run ask $FX/asks/precise.txt; [ \$RC -eq 0 ] && says 'coverage: 12 of 12' && says 'ask next: none'"
for q in 'q1 purpose' 'q2 audience' 'q3 one-job' 'q4 done' 'q5 example' 'q6 flow' 'q7 non-goal' 'q8 constraint' 'q10 growth' 'q11 term' 'q12 case' 'q14 assume'; do
  check "precise ask answers $q" "run ask $FX/asks/precise.txt; printf '%s\n' \"\$OUT\" | grep '^answered:' | grep -q '$q'"; done
check "a vague ask answers none and lists all 12 to ask" "run ask $FX/asks/vague.txt; [ \$RC -eq 0 ] && says 'coverage: 0 of 12' && says 'answered: none' && says 'ask next: q1 purpose'"

echo "U6  transcript: the shape of an intent interview"
K="--known $FX/transcripts/known-facts.txt"; TR=$FX/transcripts
check "good passes, complete and with known facts" "passes transcript $TR/good.md $K --complete"
check "no-recommendation fails TR1 only" "fails_only TR1 transcript $TR/no-recommendation.md $K --complete && says 'Recommended'"
check "no-rounds fails TR1 only" "fails_only TR1 transcript $TR/no-rounds.md $K && says 'Round'"
check "a round of exactly 5 questions is allowed" "passes transcript $TR/five-ok.md $K --complete"
check "too-many fails TR2 only" "fails_only TR2 transcript $TR/too-many.md $K --complete && says 'asks 6 questions'"
check "asked-a-fact fails TR3 only" "fails_only TR3 transcript $TR/asked-a-fact.md $K --complete && says 'header file'"
check "asked-a-fact passes when no known facts are given" "passes transcript $TR/asked-a-fact.md --complete"
check "no-readback fails TR4 only when the session is complete" "fails_only TR4 transcript $TR/no-readback.md $K --complete"
check "no-readback passes while the session is unfinished" "passes transcript $TR/no-readback.md $K"
check "untagged fails TR5 only" "fails_only TR5 transcript $TR/untagged.md $K --complete"

echo "U7  exit status and bad input"
check "a WARN alone exits 0" "run intent $FX/warn-date-only; [ \$RC -eq 0 ] && says '1 for judgement'"
check "a FAIL exits 1 and the last line counts problems" "run intent $FX/bad-unsealed; [ \$RC -eq 1 ] && tail -1 <<<\"\$OUT\" | grep -q '^FAIL: 1 problem(s)'"
check "a pass prints an ok summary" "run intent $FX/ok; tail -1 <<<\"\$OUT\" | grep -q '^ok: 0 problem(s), 0 for judgement'"
check "a missing run folder is a clean failure" "run intent $T/nowhere; [ \$RC -eq 1 ] && says 'FAIL IO'"
check "an unknown command is refused" "run bogus; [ \$RC -ne 0 ]"
check "the checker is executable and runs on system python 3.9+" "[ -x '$CTX/bin/taste-check' ] && head -1 '$CTX/bin/taste-check' | grep -q python3"
echo; echo "passed $pass · failed $fail"; [ $fail -eq 0 ]
