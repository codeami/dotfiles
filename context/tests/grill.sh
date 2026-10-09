#!/usr/bin/env bash
# Tests for the /grill-with-docs skill (areas/factory/skills/grill-with-docs). No network, no tokens, no model.
# K1 frontmatter and size · K2 contract and reads · K3 one-way dependency · K4 dogfood run against taste-check.
# Fixtures: tests/fixtures/grill (README.md lists what each folder breaks).
set -u
CTX="$(cd "$(dirname "$0")/.." && pwd)"; cd "$CTX"
SK=areas/factory/skills/grill-with-docs; FX=tests/fixtures/grill; TC="$CTX/bin/taste-check"
pass=0; fail=0
ok(){ printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
bad(){ printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
check(){ if eval "$2"; then ok "$1"; else bad "$1"; fi; }
front(){ awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{print}' "$SK/SKILL.md"; }
field(){ front | sed -n "s/^$1: *//p"; }
size(){ wc -c < "$1" | tr -d ' '; }

echo "K1  frontmatter and size caps"
check "SKILL.md opens with a frontmatter block" "[ \"\$(head -1 $SK/SKILL.md)\" = '---' ] && [ -n \"\$(front)\" ]"
check "name is grill-with-docs, matching its folder" "[ \"\$(field name)\" = grill-with-docs ]"
check "the skill is user-invoked only (costs nothing while idle)" "[ \"\$(field disable-model-invocation)\" = true ]"
check "description is at most 25 tokens by bytes/4" "d=\$(field description); [ -n \"\$d\" ] && [ \$(( \${#d} / 4 )) -le 25 ] && [ \$(printf %s \"\$d\" | wc -c) -le 100 ]"
check "frontmatter has only name, description, disable-model-invocation" "[ \"\$(front | grep -c '^[a-z-]*:')\" -eq 3 ]"
check "SKILL.md is at most 4200 bytes" "[ \$(size $SK/SKILL.md) -le 4200 ]"
check "shared/questions.md is at most 4200 bytes" "[ \$(size $SK/shared/questions.md) -le 4200 ]"
check "shared/docs-rule.md is at most 3000 bytes" "[ \$(size $SK/shared/docs-rule.md) -le 3000 ]"
check "the whole skill folder is at most 11000 bytes" "[ \$(cat $SK/SKILL.md $SK/shared/*.md | wc -c) -le 11000 ]"

echo "K2  contract, reads, and the question set"
for h in '## Reads' '## Process' '## Output' '## Human gate' '## Never'; do check "SKILL.md has '$h'" "grep -q '^$h' $SK/SKILL.md"; done
check "every file the Reads table and the steps name exists" \
  "refs=\$(grep -o '\`[^\`]*\`' $SK/SKILL.md | tr -d '\`' | awk '{print \$1}' | grep -E '^(shared|bin)/[A-Za-z0-9._-]+\$' | sort -u); [ -n \"\$refs\" ] && miss=; for f in \$refs; do [ -e \"\$f\" ] || [ -e \"$SK/\$f\" ] || miss=1; done; [ -z \"\$miss\" ]"
check "the skill names both shared files" "grep -q 'shared/questions.md' $SK/SKILL.md && grep -q 'shared/docs-rule.md' $SK/SKILL.md"
check "questions.md holds the 15 questions Q1..Q15, in order" "[ \"\$(grep -o '^- Q[0-9]* ' $SK/shared/questions.md | tr -d '\n -')\" = Q1Q2Q3Q4Q5Q6Q7Q8Q9Q10Q11Q12Q13Q14Q15 ]"
check "every question has a tag and a source in brackets and parentheses" "[ \"\$(grep -c '^- Q[0-9]* \[[a-z-]*\] .*(.*)\$' $SK/shared/questions.md)\" -eq 15 ]"
check "docs-rule.md lists K1 to K5 and S1 to S4" "[ \"\$(grep -o '^- K[0-9] ' $SK/shared/docs-rule.md | wc -l | tr -d ' ')\" -eq 5 ] && [ \"\$(grep -o '^- S[0-9] ' $SK/shared/docs-rule.md | wc -l | tr -d ' ')\" -eq 4 ]"
check "a round is at most five questions, in the skill and in the contract" "grep -q 'at most 5 questions' $SK/SKILL.md && grep -q 'rounds of up to five questions' areas/factory/01-intent/CONTEXT.md"
check "the contract no longer asks for one question at a time" "! grep -q 'Ask the one question' areas/factory/01-intent/CONTEXT.md"
check "the skill states the science-claim parallel in one sentence" "grep -q 'the claim is the line, the evidence is his verbatim words, the source is where he said it, the check is his approval' $SK/SKILL.md"
check "the skill never writes into a project" "grep -q 'never writes into a project' $SK/SKILL.md && grep -q 'proposals' $SK/SKILL.md"
check "the skill forbids writing approved: itself" "grep -q 'Write .approved:. yourself' $SK/SKILL.md"

echo "K3  one-way dependency: the skill stands alone"
check "the skill folder never mentions Firstmate" "! grep -riq firstmate $SK"
check "the skill folder points at no absolute or home path" "! grep -Eq '(^|[ \`(])(/Users/|~/|/home/)' $SK/SKILL.md $SK/shared/*.md"
check "the skill calls no other skill" "! grep -Eiq 'skill tool|call the skill|invoke the .* skill|/taste-grill' $SK/SKILL.md $SK/shared/*.md"
check "nothing under bin/ names the skill (the checker does not depend on it)" "! grep -rq 'grill-with-docs' bin"
check "no private detail in the skill or fixtures" "! grep -rEiq 'salary|mortgage|employer|passport|\\bssn\\b|\\bloan\\b' $SK $FX"

echo "K4  dogfood: a finished run that taste-check accepts, and bad runs it rejects"
run(){ OUT=$("$TC" "$@" 2>&1); RC=$?; }
check "ok: intent passes (verbatim I lines, sealed approval)" "run intent $FX/ok; [ \$RC -eq 0 ]"
check "ok: the interview transcript passes, complete, with known facts" "run transcript $FX/ok/transcript.md --known $FX/ok/known-facts.txt --complete; [ \$RC -eq 0 ]"
check "ok: every round holds at most five questions, each recommended" "run transcript $FX/ok/transcript.md --complete; ! printf '%s\n' \"\$OUT\" | grep -q '^FAIL TR[12]'"
check "ok: the candidate files are proposals that hold no code or paths (K1 purity)" "! grep -Eq '\`|/|\\(\\)' $FX/ok/glossary-candidates.md"
check "ok: the approved line is on top of 01-intent.md" "head -1 $FX/ok/01-intent.md | grep -Eq '^approved: [0-9-]{10} captain [0-9a-f]{12} via '"
check "bad-unsaid-line: intent exits 1 with TG1" "run intent $FX/bad-unsaid-line; [ \$RC -eq 1 ] && printf '%s\n' \"\$OUT\" | grep -q '^FAIL TG1'"
check "bad-no-recommendation: transcript exits 1 with TR1" "run transcript $FX/bad-no-recommendation/transcript.md --known $FX/ok/known-facts.txt --complete; [ \$RC -eq 1 ] && printf '%s\n' \"\$OUT\" | grep -q '^FAIL TR1'"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
cp -R $FX/ok "$T/run"; sed -i.bak '1d' "$T/run/01-intent.md"
check "ok without its approved line fails TG2 (nothing sealed by the skill itself)" "run intent $T/run; [ \$RC -eq 1 ] && printf '%s\n' \"\$OUT\" | grep -q '^FAIL TG2'"
check "seal writes the approved line only when asked, and the run then passes" "run seal $T/run --who captain --source 'chat' --today 2026-10-09; [ \$RC -eq 0 ]; run intent $T/run; [ \$RC -eq 0 ]"
echo; echo "passed $pass · failed $fail"; [ $fail -eq 0 ]
