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
# edit FILE OLD NEW : replace the first OLD (fails if it is absent), bytes and line endings untouched
edit(){ python3 -I -c 'import sys; p,a,b=sys.argv[1:]; s=open(p,encoding="utf-8",newline="").read(); assert a in s, a; open(p,"w",encoding="utf-8",newline="").write(s.replace(a,b,1))' "$@"; }
reseal(){ "$TC" seal "$T/$1" --who captain --source chat --today 2026-10-08 >/dev/null; }

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
echo "U8  review fixes: pointers stay in the root, seal is safe, TG3 reads whole tokens, input is strict"
I3='Keep the page under 150 kb gzipped.'; I4="Call a person's space a workspace, not a sandbox."
# ptr NAME NEWPTR : copy of ok whose I1 evidence is NEWPTR
ptr(){ fresh ok "$1"; edit "$T/$1/06-result.md" 'src/header.ts:2-4' "$2"; }
# ivar NAME NEW_I4 OLD_A4 NEW_A4 : copy of ok with I4 (words and intent) and one spec line changed, then re-sealed
ivar(){ fresh ok "$1"; edit "$T/$1/01-words.txt" "$I4" "$2"; edit "$T/$1/01-intent.md" "$I4" "$2"
  edit "$T/$1/02-spec.md" "$3" "$4"; reseal "$1"; }
mkdir -p "$T/out"; printf 'line one\nsecret\n' > "$T/out/secret.md"
echo "  -- 1 evidence pointers resolve inside the root"
ptr e1 '../01-intent.md:1'
check "a ../ pointer that leaves the root fails TG5" "fails_only TG5 result $T/e1 --root $T/e1/root && says 'outside'"
ptr e2 "$T/e2/01-intent.md:1"
check "an absolute pointer to a real file outside the root fails TG5" "fails_only TG5 result $T/e2 --root $T/e2/root && says 'absolute'"
ptr e3 "$T/e3/root/src/header.ts:2"
check "an absolute pointer even into the root fails TG5" "fails_only TG5 result $T/e3 --root $T/e3/root && says 'absolute'"
ptr e4 'src/link.md:1'; ln -s "$T/out/secret.md" "$T/e4/root/src/link.md"
check "a pointer through a symlink out of the root fails TG5" "fails_only TG5 result $T/e4 --root $T/e4/root && says 'outside'"
ptr e5 'src/header.ts:2'; ln -s ../src/header.ts "$T/e5/root/NOTES-link.md"
check "a symlink that stays inside the root is fine" "passes result $T/e5 --root $T/e5/root"
fresh ok e6; rm "$T/e6/root/src/theme.test.ts"; printf "it('keeps the saved light theme when the toggle is flipped')\n" > "$T/out/theme.test.ts"; ln -s "$T/out/theme.test.ts" "$T/e6/root/src/theme.test.ts"
check "a test: pointer is not satisfied by a test file that is a symlink out of the root" "fails_only TG5 result $T/e6 --root $T/e6/root && says 'no test named'"
echo "  -- 8 line pointers"
ptr l1 'src/header.ts:0'
check "line 0 fails TG5" "fails_only TG5 result $T/l1 --root $T/l1/root && says 'start at 1'"
ptr l2 'src/header.ts:3-2'
check "a range that ends before it starts fails TG5" "fails_only TG5 result $T/l2 --root $T/l2/root && says 'before it starts'"
ptr l3 'src/header.ts:1-99'
check "a range past the last line fails TG5" "fails_only TG5 result $T/l3 --root $T/l3/root && says 'has [0-9]* lines'"
ptr l4 'src/header.ts:2-2'
check "a one-line range is fine" "passes result $T/l4 --root $T/l4/root"
echo "  -- 2 seal refuses a symlink and writes by rename"
fresh bad-unsealed q1; cp "$T/q1/01-intent.md" "$T/out/target.md"; rm "$T/q1/01-intent.md"; ln -s "$T/out/target.md" "$T/q1/01-intent.md"
check "seal refuses a symlinked 01-intent.md and leaves the target alone" \
  "run seal $T/q1 --who captain --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'symlink' && ! grep -q '^approved:' $T/out/target.md && [ -L $T/q1/01-intent.md ]"
fresh bad-unsealed q2; ino(){ python3 -I -c 'import os,sys; print(os.stat(sys.argv[1]).st_ino)' "$1"; }; before=$(ino "$T/q2/01-intent.md")
check "seal replaces the file by rename (a new inode) and leaves no temp file behind" \
  "run seal $T/q2 --who captain --source chat --today 2026-10-08; [ \$RC -eq 0 ] && [ \"\$(ino $T/q2/01-intent.md)\" != \"$before\" ] && [ \$(ls $T/q2 | wc -l) -eq \$(ls $FX/bad-unsealed | wc -l) ]"
fresh bad-unsealed q3; ln "$T/q3/01-intent.md" "$T/out/hardlink.md"
check "seal does not write through a hard link" "run seal $T/q3 --who captain --source chat --today 2026-10-08; [ \$RC -eq 0 ] && ! grep -q '^approved:' $T/out/hardlink.md"
echo "  -- 3 TG3 compares whole tokens, one criterion at a time"
fresh ok n1; edit "$T/n1/02-spec.md" 'under 150 kb' 'under 1500 kb'
check "150 is not carried by 1500" "fails_only TG3 spec $T/n1 && says \"number '150'\""
fresh ok n2; edit "$T/n2/01-words.txt" 'under 150 kb' 'under 15 kb'; edit "$T/n2/01-intent.md" 'under 150 kb' 'under 15 kb'; reseal n2
check "15 is not carried by 150" "fails_only TG3 spec $T/n2 && says \"number '15'\""
fresh ok n3; edit "$T/n3/02-spec.md" 'under 150 kb' 'under 1,500 kb'
check "150 is not carried by 1,500 either" "fails_only TG3 spec $T/n3 && says \"number '150'\""
fresh ok n4; edit "$T/n4/02-spec.md" 'under 150 kb' 'under 150.5 kb'
check "150 is not carried by 150.5" "fails_only TG3 spec $T/n4 && says \"number '150'\""
ivar w1 'Label the space "work".' 'User-facing text says workspace and never sandbox.' 'The space label reads workspace.'
check "a quoted word is not carried by a longer word that contains it" "fails_only TG3 spec $T/w1 && says \"quoted 'work'\""
ivar w2 'Label the space "workspace".' 'User-facing text says workspace and never sandbox.' 'The space label reads Workspace.'
check "a quoted word is carried whole, whatever its case" "passes spec $T/w2"
ivar m1 'Use the "dark mode" label.' 'A4 (I4): User-facing text says workspace and never sandbox.' 'A4 (I4): The label says dark
A6 (I4): mode names stay short'
check "a quoted phrase split across two criteria is not carried by either" "fails_only TG3 spec $T/m1 && says \"quoted 'dark mode'\""
fresh ok m2; edit "$T/m2/02-spec.md" 'A5 (derived' 'A6 (I3): It is under 99 kb.
A5 (derived'; edit "$T/m2/02-spec.md" 'A3 (I3): The built page is under 150 kb gzipped.' 'A3 (I3): The built page is lean'
check "a number kept only by a criterion that does not carry the rest still fails the one that is missing" "fails_only TG3 spec $T/m2 && says \"number '150'\""
fresh ok m3; edit "$T/m3/02-spec.md" 'A5 (derived' 'A6 (I3): Gzipped size is reported.
A5 (derived'
check "another criterion citing the I line does not stop the one that carries the tokens" "passes spec $T/m3"
echo "  -- 4 single-quoted and curly-quoted hard words"
ivar q1s "Label the space 'workspace'." 'User-facing text says workspace and never sandbox.' 'The space label reads sandbox.'
check "a single-quoted word must be kept" "fails_only TG3 spec $T/q1s && says \"quoted 'workspace'\""
ivar q2c 'Label the space “workspace”.' 'User-facing text says workspace and never sandbox.' 'The space label reads sandbox.'
check "a curly double-quoted word must be kept" "fails_only TG3 spec $T/q2c && says \"quoted 'workspace'\""
ivar q3c 'Label the space ‘workspace’.' 'User-facing text says workspace and never sandbox.' 'The space label reads sandbox.'
check "a curly single-quoted word must be kept" "fails_only TG3 spec $T/q3c && says \"quoted 'workspace'\""
ivar q4 "Don't call the space 'workspace'." 'User-facing text says workspace and never sandbox.' "Don't say it."
check "an apostrophe is not a quote: only the quoted word is a hard token" "fails_only TG3 spec $T/q4 && says \"quoted 'workspace'\" && ! says \"quoted 's\""
echo "  -- 5 duplicates are failures"
fresh ok d1; edit "$T/d1/01-intent.md" 'I4: ' 'I3: Keep the page under 150 kb gzipped.
I4: '
check "a duplicate I id fails TG1, naming it" "run intent $T/d1; [ \$RC -eq 1 ] && says 'FAIL TG1 I3 appears twice'"
check "a duplicate I id also fails spec and result" "run spec $T/d1; says 'FAIL TG1 I3 appears twice'; run result $T/d1 --root $T/d1/root; says 'FAIL TG1 I3 appears twice'"
check "seal refuses a duplicate I id" "run seal $T/d1 --who captain --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'twice'"
fresh ok d2; edit "$T/d2/06-result.md" '| I5 |' '| I1 | delivered | src/header.ts:5 |
| I5 |'
check "a duplicate result row fails TG4, naming it" "fails_only TG4 result $T/d2 --root $T/d2/root && says 'I1 has two rows'"
echo "  -- 6 the approved line"
fresh ok a1; edit "$T/a1/01-intent.md" ' via chat 2026-10-08 14:02' ''
check "a sealed approval with no via source fails TG2" "fails_only TG2 intent $T/a1 && says 'via'"
fresh ok a2; edit "$T/a2/01-intent.md" 'approved: 2026-10-08' 'approved: 2026-02-30'
check "an impossible calendar date fails TG2" "fails_only TG2 intent $T/a2 && says 'calendar date'"
fresh ok a3; edit "$T/a3/01-intent.md" 'approved: 2026-10-08' 'approved: 2026-13-45'
check "month 13 fails TG2" "fails_only TG2 intent $T/a3 && says 'calendar date'"
fresh bad-unsealed a4
check "seal refuses a date that is not on the calendar" "run seal $T/a4 --who captain --source chat --today 2026-02-30; [ \$RC -eq 1 ] && says 'calendar date' && ! grep -q '^approved:' $T/a4/01-intent.md"
check "seal refuses an empty source" "run seal $T/a4 --who captain --source '  ' --today 2026-10-08; [ \$RC -eq 1 ] && says 'source'"
check "seal refuses a who with a space (it would not parse back)" "run seal $T/a4 --who 'Ash Raina' --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'who'"
echo "  -- 7 seal rejects newlines in --who and --source"
fresh bad-unsealed s7; cp "$T/s7/01-intent.md" "$T/s7/before"
check "a newline in --who is refused and nothing is written" \
  "run seal $T/s7 --who \$'cap\nI9: injected' --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'who' && cmp -s $T/s7/01-intent.md $T/s7/before"
check "a newline in --source is refused and nothing is written" \
  "run seal $T/s7 --who captain --source \$'chat\nI9: injected' --today 2026-10-08; [ \$RC -eq 1 ] && says 'source' && cmp -s $T/s7/01-intent.md $T/s7/before"
check "a Unicode line separator in --source is refused too" \
  "run seal $T/s7 --who captain --source \$'chat\xe2\x80\xa8I9: injected' --today 2026-10-08; [ \$RC -eq 1 ] && says 'source' && cmp -s $T/s7/01-intent.md $T/s7/before"
echo "  -- 9 malformed UTF-8 is a clean FAIL IO"
fresh ok u1; printf 'Add a \xff\xfe toggle\n' > "$T/u1/01-words.txt"
check "bad bytes in 01-words.txt: FAIL IO, no traceback" "run intent $T/u1; [ \$RC -eq 1 ] && says '^FAIL IO' && ! says Traceback"
fresh ok u2; printf '## Captain\xff\n' > "$T/u2/01-intent.md"
check "bad bytes in 01-intent.md: FAIL IO from spec, result and seal" \
  "(for c in 'spec' 'result' 'seal --who a --source b'; do run \$c $T/u2; [ \$RC -eq 1 ] && says '^FAIL IO' && ! says Traceback || exit 1; done)"
echo "  -- 10 TG1 compares the exact I line"
fresh ok v1; edit "$T/v1/01-intent.md" 'I1: Add a dark' 'I1: add a dark'; reseal v1
check "a case change fails TG1" "fails_only TG1 intent $T/v1"
fresh ok v2; edit "$T/v2/01-words.txt" 'not a sandbox.' 'not a sandbox'
check "a full stop on the I line that the words do not have fails TG1" "fails_only TG1 intent $T/v2"
fresh ok v3; edit "$T/v3/01-intent.md" 'I1: Add a dark' 'I1: Add a  dark'; reseal v3
check "doubled inner whitespace fails TG1" "fails_only TG1 intent $T/v3"
fresh ok v4; edit "$T/v4/01-intent.md" 'not a sandbox.' 'not a sandbox. '; reseal v4
check "trailing whitespace on the I line fails TG1" "fails_only TG1 intent $T/v4"
fresh ok v5; python3 -I -c 'import sys; p=sys.argv[1]; s=open(p,newline="").read(); open(p,"w",newline="").write(s.replace("\n","\r\n"))' "$T/v5/01-words.txt"
check "CRLF line endings in the words file are the one allowed difference" "passes intent $T/v5"
fresh ok v6; python3 -I -c 'import sys; p=sys.argv[1]; s=open(p,newline="").read(); open(p,"w",newline="").write(s.replace("\n","\r\n"))' "$T/v6/01-intent.md"
check "CRLF line endings in the intent file pass too" "passes intent $T/v6"
echo "  -- 11 TR4 wants the I lines read back and a question about a shared understanding"
G=$FX/transcripts/good.md
sed 's/Is this a shared understanding?/This is a shared understanding./' $G > "$T/tr4a.md"
check "a read-back that does not ask fails TR4" "fails_only TR4 transcript $T/tr4a.md $K --complete"
sed 's/I1 to I3 are in 01-intent.md in your words\. //' $G > "$T/tr4b.md"
check "a question with no I lines read back fails TR4" "fails_only TR4 transcript $T/tr4b.md $K --complete"
check "the real read-back still passes" "passes transcript $G $K --complete"
echo "  -- 12 the header says what the seal is for"
check "the checker header says the seal detects accidental change, not deliberate edits" "head -25 '$TC' | tr '\n' ' ' | grep -q 'accidental change, not deliberate edits'"
echo "U9  third round: seal in a symlinked folder, re-checked seal, empty I lines, signed numbers, whole test names, pipes, hard links"
echo "  -- 1 seal refuses a run folder that is a symlink"
fresh bad-unsealed r1; ln -s "$T/r1" "$T/r1link"
check "seal refuses a symlinked run folder and writes nothing" \
  "run seal $T/r1link --who captain --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'symlink' && ! grep -q '^approved:' $T/r1/01-intent.md && [ \$(ls -A $T/r1 | wc -l) -eq \$(ls -A $FX/bad-unsealed | wc -l) ]"
echo "  -- 2 spec and result re-check the seal"
fresh ok t1; edit "$T/t1/01-intent.md" 'not a sandbox.' 'not a sandpit.'
check "an I line edited after sealing fails TG2 in spec" "fails_only TG2 spec $T/t1 && says 'changed after approval'"
check "an I line edited after sealing fails TG2 in result" "fails_only TG2 result $T/t1 --root $T/t1/root && says 'changed after approval'"
echo "  -- 3 an empty I line is a failure"
fresh ok x1; edit "$T/x1/01-intent.md" 'I4: ' 'I6:
I4: '
check "an empty I line fails TG1 in intent" "run intent $T/x1; [ \$RC -eq 1 ] && says 'FAIL TG1 I6 is empty'"
check "an empty I line fails TG1 in spec and result too" "run spec $T/x1; [ \$RC -eq 1 ] && says 'FAIL TG1 I6 is empty'; run result $T/x1 --root $T/x1/root; [ \$RC -eq 1 ] && says 'FAIL TG1 I6 is empty'"
fresh bad-unsealed x2; edit "$T/x2/01-intent.md" 'I4: ' 'I6:
I4: '
check "seal refuses an empty I line and writes nothing" "run seal $T/x2 --who captain --source chat --today 2026-10-08; [ \$RC -eq 1 ] && says 'I6 is empty' && ! grep -q '^approved:' $T/x2/01-intent.md"
echo "  -- 4 signed numbers are tokens"
fresh ok g1; edit "$T/g1/01-words.txt" 'under 150 kb' 'under -150 kb'; edit "$T/g1/01-intent.md" 'under 150 kb' 'under -150 kb'; reseal g1
check "-150 is not carried by 150" "fails_only TG3 spec $T/g1 && says \"number '-150'\""
fresh ok g2; edit "$T/g2/02-spec.md" 'under 150 kb' 'under -150 kb'
check "150 is not carried by -150" "fails_only TG3 spec $T/g2 && says \"number '150'\""
fresh ok g3; edit "$T/g3/01-words.txt" 'under 150 kb' 'under +150 kb'; edit "$T/g3/01-intent.md" 'under 150 kb' 'under +150 kb'; reseal g3
check "+150 is not carried by 150" "fails_only TG3 spec $T/g3 && says \"number '+150'\""
fresh ok g4; for f in 01-words.txt 01-intent.md 02-spec.md; do edit "$T/g4/$f" 'under 150 kb' 'under -150 kb'; done; reseal g4
check "-150 is carried by -150" "passes spec $T/g4"
fresh ok g5; for f in 01-words.txt 01-intent.md; do edit "$T/g5/$f" 'under 150 kb' 'between 100-150 kb'; done; edit "$T/g5/02-spec.md" 'under 150 kb' 'between 100 and 150 kb'; reseal g5
check "a hyphen in a range is no sign" "passes spec $T/g5"
echo "  -- 5 a test: pointer names a whole test"
TN='keeps the saved light theme when the toggle is flipped'
fresh ok k1; printf "// we deleted the '%s' test\nit('works', () => {});\n" "$TN" > "$T/k1/root/src/theme.test.ts"
check "a test name only in a comment does not resolve" "fails_only TG5 result $T/k1 --root $T/k1/root && says 'no test named'"
fresh ok k2; edit "$T/k2/06-result.md" "test:$TN" 'test:keeps the saved light theme'
check "the start of a longer test name does not resolve" "fails_only TG5 result $T/k2 --root $T/k2/root && says 'no test named'"
fresh ok k3; printf 'test.only("%s", () => {});\n' "$TN" > "$T/k3/root/src/theme.test.ts"
check "a double-quoted test.only name resolves" "passes result $T/k3 --root $T/k3/root"
echo "  -- 6 a | in a pointer"
ptr p1 'src/header.ts:2|4'
check "an unescaped | in the pointer cell fails TG4, not a quiet pass" "fails_only TG4 result $T/p1 --root $T/p1/root && says 'cells'"
ptr p2 'src/a\|b.md:1'; printf 'one\n' > "$T/p2/root/src/a|b.md"
check "an escaped \\| is part of the pointer" "passes result $T/p2 --root $T/p2/root"
echo "  -- 7 a hard link inside the root to a file outside it"
ptr h1 'src/hard.md:1'; ln "$T/out/secret.md" "$T/h1/root/src/hard.md"
check "a hard link to a file outside the root fails TG5" "fails_only TG5 result $T/h1 --root $T/h1/root && says 'hard link'"
ptr h2 'src/header-hard.ts:2'; ln "$T/h2/root/src/header.ts" "$T/h2/root/src/header-hard.ts"
check "a hard link between two files inside the root is fine" "passes result $T/h2 --root $T/h2/root"
fresh ok h3; rm "$T/h3/root/src/theme.test.ts"; printf "it('%s', () => {});\n" "$TN" > "$T/out/hard.test.ts"; ln "$T/out/hard.test.ts" "$T/h3/root/src/theme.test.ts"
check "a test: pointer is not satisfied by a test file hard-linked from outside" "fails_only TG5 result $T/h3 --root $T/h3/root && says 'no test named'"
echo; echo "passed $pass · failed $fail"; [ $fail -eq 0 ]
