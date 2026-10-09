#!/usr/bin/env bash
# Tests for bin/plain-check (plain STE, 80%). No network, no tokens, no model.
# P1 good texts · P2 one rule each · P3 counting · P4 masks · P5 pass test · P6 output · P7 guards · P8 gaps.
# Fixtures: tests/fixtures/plain (README.md lists them).
# PLAIN_CHECK overrides the checker under test; tests/mutate-plain.py uses that to prove these tests bite.
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; cd "$CTX"
PC="${PLAIN_CHECK:-$CTX/bin/plain-check}"; FX=tests/fixtures/plain
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
bad(){ printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
run(){ OUT=$("$PC" "$@" 2>&1); RC=$?; }
ids(){ printf '%s\n' "$OUT" | awk -F'[: ]' '$2 ~ /^[0-9]+$/ && $3 ~ /^R[0-9]+$/ {print $3}' | sort -u | tr '\n' ' '; }
# fails_only ID file : exit 1 and every finding carries ID
fails_only(){ run "$2"; [ $RC -eq 1 ] && [ "$(ids)" = "$1 " ]; }
passes(){ run "$@"; [ $RC -eq 0 ]; }
clean(){ run "$@"; [ $RC -eq 0 ] && [ -z "$(ids)" ]; }
says(){ printf '%s\n' "$OUT" | grep -q -- "$1"; }
put(){ printf '%b\n' "$2" > "$T/$1"; }

echo "P1  good texts pass with no finding"
check "good-report is clean" "clean $FX/good-report.md"
check "good-steps is clean" "clean $FX/good-steps.md"
awk '/^## The rule/{t=1;next} /^## 80/{t=0} t' areas/factory/references/ste.md > "$T/rule.md"
check "the rule text itself passes" "passes $T/rule.md"
check "an active sentence is clean" "clean $FX/ok-active.md"
check "'about' and 'around' are not on the word list (they are approved)" "clean $FX/ok-approx-around.md"
check "six sentences make a legal paragraph" "clean $FX/ok-six-sentences.md"
check "'nothing' is not a progressive" "clean $FX/ok-r6-nothing.md"
check "the same word twice is not a synonym swap" "clean $FX/ok-r8-same-word.md"

echo "P2  each rule fires under its own id, and only that id"
check "R1 26 words is hard" "fails_only R1 $FX/words-26.md && says ' R1 hard.*26 words'"
check "R1 21-word step is soft" "fails_only R1 $FX/step-21.md && says ' R1 soft'"
check "R2 semicolon" "fails_only R2 $FX/bad-r2.md"
check "R3 seven sentences" "fails_only R3 $FX/bad-r3.md"
check "R4 utilize" "fails_only R4 $FX/bad-r4-utilize.md && says 'use'"
check "R4 prior to" "fails_only R4 $FX/bad-r4-prior.md"
check "R4 in order to" "fails_only R4 $FX/bad-r4-order.md"
check "R5 passive" "fails_only R5 $FX/bad-r5.md"
check "R5 modal plus be" "fails_only R5 $FX/bad-r5-modal.md"
check "R6 progressive" "fails_only R6 $FX/bad-r6.md"
check "R7 phrasal verb" "fails_only R7 $FX/bad-r7.md"
check "R8 synonym swap, named once" "fails_only R8 $FX/bad-r8.md && says \"'verify'\""
check "R9 e.g. (and the sentence does not split at it)" "fails_only R9 $FX/bad-r9.md"
put long.md "$(python3 -c "print('\\\\n\\\\n'.join(['Go.']*300))")"
for pair in 'R4|We utilize it.' 'R2|One; two.' 'R3|One. Two. Three. Four. Five. Six. Seven.'; do
  rid=${pair%%|*}; put "long-$rid.md" "$(cat $T/long.md)\n\n${pair#*|}"
  check "$rid is hard: it fails even in a long text" "run $T/long-$rid.md; [ \$RC -eq 1 ] && says ' $rid hard'"
done
put long-soft.md "$(cat $T/long.md)\n\nIt is done."
check "R5 is soft: one in a long text still passes" "run $T/long-soft.md; [ \$RC -eq 0 ] && says ' R5 soft'"
put long-r1.md "$(cat $T/long.md)\n\n$(sed 's/\.$//' $FX/words-26.md)."
check "R1 over 25 is hard in a long text" "run $T/long-r1.md; [ \$RC -eq 1 ] && says ' R1 hard'"
put long-step.md "$(cat $T/long.md)\n\n$(cat $FX/step-21.md)"
check "R1 over 20 in a step is soft: a long text still passes" "run $T/long-step.md; [ \$RC -eq 0 ] && says ' R1 soft'"
put r4all.md "We ensure it. We commence work. We initiate a run. We make use of it. Due to the fact that it works. We facilitate this. We obtain it."
check "R4 catches ensure, commence, initiate, make use of, due to the fact that, facilitate, obtain" "run $T/r4all.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R4 ') -eq 7 ]"
put r5b.md "The job is done. The report was sent. The data had been shown."
check "R5 sees irregular participles" "run $T/r5b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R5 ') -eq 3 ]"
put r6b.md "The scout was running a test. They are waiting. Both were testing it."
check "R6 sees was/are/were plus -ing" "run $T/r6b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R6 ') -eq 3 ]"
put r2b.md "One; two; three."
check "R2 reports every semicolon" "run $T/r2b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R2 ') -eq 2 ]"
put r8b.md "We start it. We launch it. We begin it."
check "R8 reports one finding per group" "run $T/r8b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R8 ') -eq 1 ]"
put r8c.md "We show it. We display it. We stop it. We halt it."
check "R8 knows the show/display and stop/halt groups" "run $T/r8c.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R8 ') -eq 2 ]"
put r7b.md "Kick off the run. Then wrap up. Dive into the log."
check "R7 sees kick off, wrap up, dive into" "run $T/r7b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R7 ') -eq 3 ]"
put r9b.md "We use a tool, i.e. the linter, etc."
check "R9 sees i.e. and etc." "run $T/r9b.md; [ \$(printf '%s\n' \"\$OUT\" | grep -c ' R9 ') -eq 2 ]"
put r3b.md "One. Two. Three. Four. Five. Six.\n\nOne. Two. Three. Four. Five. Six."
check "R3 counts per paragraph, not per file" "passes $T/r3b.md"
put r3d.md "One. Two. Three. Four. Five. Use tools, e.g. Vale."
check "R3 does not split a sentence at e.g." "run $T/r3d.md; ! says ' R3 '"
put r3c.md "- One. Two. Three. Four. Five. Six. Seven.\n"
check "R3 does not apply to a list item" "! (run $T/r3c.md; says ' R3 ')"

echo "P3  counting: 25 passes, 26 fails; code is one word; quotes are zero"
check "24 words pass" "clean $FX/words-24.md"
check "25 words pass" "clean $FX/words-25.md"
check "20-word step passes" "clean $FX/step-20.md"
put code.md "$(sed 's/\.$//' $FX/words-24.md) \`one two three four five six seven eight nine ten\`."
check "a code span counts as one word (24 + 1 = 25 passes)" "clean $T/code.md"
put codeb.md "$(sed 's/\.$//' $FX/words-25.md) \`x\`."
check "a code span still counts as one word (25 + 1 = 26 fails)" "fails_only R1 $T/codeb.md"
put quote.md "$(sed 's/\.$//' $FX/words-25.md) \"one two three four five six\"."
check "a quoted span counts as zero words" "clean $T/quote.md"
put path.md "$(sed 's/\.$//' $FX/words-25.md) ~/context/areas/x.md /tmp/a/b.sh."
check "paths count as zero words" "clean $T/path.md"
put path2.md "$(sed 's/\.$//' $FX/words-25.md) /tmp."
check "a path from the root counts as zero words" "clean $T/path2.md"
put quote2.md "$(sed 's/\.$//' $FX/words-25.md) [3P] [S] [J] [?]."
check "grade tags count as zero words" "clean $T/quote2.md"
put hard-step.md "1. $(cat $FX/words-26.md)"
check "a 26-word step is hard, not just soft" "run $T/hard-step.md; says ' R1 hard'"
check "the summary line says how many words it counted" "run $FX/words-25.md; says '25 words'"

echo "P4  masks: a violation inside a protected span gives 0 findings; the control gives one"
VIO="A; B"
for pair in 'double-quote|He said "A; B" today.' 'curly-quote|He said “A; B” today.' 'blockquote|> A; B' 'inline-code|Run `A; B` today.' \
            'fence|```\nA; B\n```' 'tilde-fence|~~~\nA; B\n~~~' 'url|See https://example.com/a;b today.' 'table|| A; B | C |' \
            'off-span|<!-- ste:off -->\nA; B\n<!-- ste:on -->' 'html-comment|<!-- A; B -->'; do
  n=${pair%%|*}; body=${pair#*|}; put "m-$n.md" "$body"
  check "mask $n hides the violation" "clean $T/m-$n.md"
done
put control.md "He said A; B today."
check "control: the same text unmasked is an R2 finding" "fails_only R2 $T/control.md"
put after-on.md "<!-- ste:off -->\nA; B\n<!-- ste:on -->\nC; D"
check "after ste:on the checker resumes (line 4)" "fails_only R2 $T/after-on.md && says 'after-on.md:4 R2'"
put no-on.md "<!-- ste:off -->\nA; B\nC; D"
check "ste:off with no ste:on runs to the end of the file" "clean $T/no-on.md"
put before-off.md "A; B\n<!-- ste:off -->\nC; D\n<!-- ste:on -->"
check "before ste:off the checker still works (line 1)" "fails_only R2 $T/before-off.md && says 'before-off.md:1 R2'"
put fence-then.md '```\nx\n```\nA; B'
check "after a closed fence the checker resumes" "fails_only R2 $T/fence-then.md"
put quote-line.md "A short line.\n> A; B\nC; D"
check "a quote line is skipped but the next line is checked (line 3)" "fails_only R2 $T/quote-line.md && says 'quote-line.md:3 R2'"
put cut.md "Use \`utilize\` or \"prior to\" here."
check "R4 words inside code and quotes are not flagged" "clean $T/cut.md"

echo "P5  pass test: soft findings at most 2 per 100 words, hard findings none"
python3 - "$T" <<'PY'
import sys
t = sys.argv[1]
body = "\n\n".join(["Go."] * 94) + "\n\n"
open(f"{t}/soft2.md", "w").write(body + " Use e.g. one. Use e.g. two.\n")      # 94 + 2*3 = 100 words, 2 soft
open(f"{t}/soft3.md", "w").write(body + " Use e.g. one. Use e.g. two. Use e.g. six.\n")  # 103 words, 3 soft
open(f"{t}/soft1short.md", "w").write("Use e.g. one.\n")                         # 3 words, 1 soft: too dense
PY
check "2 soft findings in 100 words pass (exit 0, still printed)" "run $T/soft2.md; [ \$RC -eq 0 ] && says ' R9 ' && says '2 soft'"
check "3 soft findings in 103 words fail" "run $T/soft3.md; [ \$RC -eq 1 ] && says '3 soft'"
check "1 soft finding in 3 words fails" "run $T/soft1short.md; [ \$RC -eq 1 ]"
put hard-in-long.md "$(python3 -c "print('\\\\n\\\\n'.join(['Go.']*300))") A; B"
check "one hard finding fails even in a long text" "run $T/hard-in-long.md; [ \$RC -eq 1 ] && says '1 hard'"
put empty.md ""
check "an empty file passes" "run $T/empty.md; [ \$RC -eq 0 ] && says '0 words'"

echo "P6  output: file:line rule-id message"
put lines.md "Fine.\n\nAlso fine.\nBad; line."
check "finding starts with path:line then the rule id" "run $T/lines.md; printf '%s\n' \"\$OUT\" | grep -Eq '^$T/lines.md:4 R2 '"
put wrap.md "A short start\nthat runs on; here."
check "a wrapped sentence reports the line where the problem sits" "run $T/wrap.md; says 'wrap.md:2 R2'"
put twosent.md "Fine one. Then utilize it."
check "a later sentence on the same line reports that line" "run $T/twosent.md; says 'twosent.md:1 R4'"
put list.md "Intro line.\n\n- Fine item.\n- Bad; item."
check "a list item reports its own line" "run $T/list.md; says 'list.md:4 R2'"
put numbered.md "1. Fine step.\n2. Utilize it."
check "a numbered step reports its own line" "run $T/numbered.md; says 'numbered.md:2 R4'"
put head.md "# A heading; with a mark\n\nBody."
check "a heading is checked" "fails_only R2 $T/head.md"
check "the last line is a summary with hard, soft and words" "run $FX/bad-r2.md; tail -1 <<<\"\$OUT\" | grep -Eq '1 hard, 0 soft, [0-9]+ words'"
put two1.md "Bad; one."; put two2.md "Fine one."
check "two files: both are named, the worst exit code wins" "run $T/two1.md $T/two2.md; [ \$RC -eq 1 ] && says 'two1.md:1 R2' && printf '%s\n' \"\$OUT\" | grep -Ec '^(ok|FAIL):' | grep -q 2"

echo "P7  guards: blog, read-only, bad input"
mkdir -p "$T/areas/blog/drafts" "$T/areas/blogger"; cp $FX/bad-r2.md "$T/areas/blog/drafts/p.md"; cp $FX/bad-r2.md "$T/areas/blogger/p.md"
check "a file under areas/blog/ is refused (exit 2)" "run $T/areas/blog/drafts/p.md; [ \$RC -eq 2 ] && says 'refus' && ! says ' R2 '"
check "the refusal says how to override" "run $T/areas/blog/drafts/p.md; says -- '--force'"
check "--force checks a blog file" "run --force $T/areas/blog/drafts/p.md; [ \$RC -eq 1 ] && says ' R2 '"
check "a similar folder name is not refused" "run $T/areas/blogger/p.md; [ \$RC -eq 1 ]"
cd "$T/areas/blog" && cp ../blogger/p.md ./q.md && cd "$CTX"
check "a relative path into areas/blog is refused too" "(cd $T && OUT=\$($PC areas/blog/q.md 2>&1); [ \$? -eq 2 ])"
check "the blog guard works through a symlink" "ln -s $T/areas/blog/q.md $T/link.md; run $T/link.md; [ \$RC -eq 2 ]"
put ro.md "A; B"; before=$(cksum < "$T/ro.md"); mtime=$(stat -f %m "$T/ro.md" 2>/dev/null || stat -c %Y "$T/ro.md")
chmod 444 "$T/ro.md"; run "$T/ro.md"
check "read-only: the file is unchanged, even when it is write-protected" "[ \"\$(cksum < $T/ro.md)\" = \"$before\" ] && [ \$RC -eq 1 ]"
check "a refusal is not hidden by a later failing file" "run $T/areas/blog/drafts/p.md $T/control.md; [ \$RC -eq 2 ]"
check "a missing file exits 2" "run $T/nowhere.md; [ \$RC -eq 2 ] && says 'nowhere.md'"
check "no arguments exits 2 with usage" "run; [ \$RC -eq 2 ] && printf '%s\n' \"\$OUT\" | grep -qi usage"
check "a folder is refused" "run $T; [ \$RC -eq 2 ]"
check "the checker is executable and runs on system python 3.9+" "[ -x '$CTX/bin/plain-check' ] && head -1 '$CTX/bin/plain-check' | grep -q python3"
check "standard library only (no third-party import)" "! grep -Eq '^(import|from) (requests|yaml|numpy|regex|nltk|spacy)' '$CTX/bin/plain-check'"
check "stays near 150 lines (at most 200)" "[ \$(wc -l < '$CTX/bin/plain-check') -le 200 ]"

echo "P8  known gaps in v1 stay open (documented, not hidden)"
check "dropped articles give no finding (M13)" "clean $FX/gap-articles.md"
check "two actions in one sentence give no finding (M15)" "clean $FX/gap-two-actions.md"

echo "P9  wiring: the reference file and the two Inputs rows"
check "ste.md has the three sections" "grep -q '^## The rule' areas/factory/references/ste.md && grep -q '^## 80% table' areas/factory/references/ste.md && grep -q '^## Carve-outs' areas/factory/references/ste.md"
check "The rule is about 258 tokens (bytes/4 between 230 and 290)" "n=\$(wc -c < $T/rule.md); [ \$((n/4)) -ge 230 ] && [ \$((n/4)) -le 290 ]"
check "ste.md says it is not ASD-STE100 and limits are third-party" "grep -qi 'not ASD-STE100' areas/factory/references/ste.md && grep -qi 'third-party' areas/factory/references/ste.md"
check "no file claims compliance" "! grep -rEiq '(complies|compliant|conforms) (with|to) ASD|ASD-STE100 (compliant|approved|certified)' areas/factory bin tests/plain.sh"
for s in 06-review 08-learn; do
  check "$s Inputs row points at ste.md section \"The rule\"" "awk '/^## Inputs/{t=1;next} /^## /{t=0} t' areas/factory/$s/CONTEXT.md | grep -F 'areas/factory/references/ste.md' | grep -qF '\"The rule\"'"
done
check "every heading the rows quote exists in ste.md" "grep -qFx '## The rule' areas/factory/references/ste.md"
echo; echo "passed $pass · failed $fail"; [ $fail -eq 0 ]
