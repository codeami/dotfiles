Fixtures for tests/plain.sh. Each `bad-*` file breaks one rule; `ok-*` and `good-*` must pass; `gap-*` are known gaps (no finding in v1).

- words-24/25/26: one sentence of that many words. 25 passes R1, 26 is hard.
- step-20/21: a numbered step of that many words. 20 passes, 21 is a soft R1.
- good-report, good-steps: plain texts, exit 0.
- bad-r2 .. bad-r9: one rule each (bad-r3 has 7 sentences).
- ok-six-sentences, ok-approx-around, ok-r6-nothing, ok-r8-same-word, ok-active: near misses that must not fire.
- gap-articles, gap-two-actions: dropped articles and two actions in one step. The checker does not test these in v1.
