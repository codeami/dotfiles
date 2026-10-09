# Plain STE (80%): reference for stages 06 and 08

This is our own short rule. It is not ASD-STE100 and does not claim to follow it.
Every limit below is third-party (copied from public tools and summaries) until the
captain has read the official standard. Read by section: stages load "The rule" only.

## The rule

Plain STE (80%). One reading must be possible. Applies to agent-written explanations, reports, boards and learning notes.

1. One idea per sentence. Maximum 25 words. Steps: maximum 20 words, one action, command form.
2. Active voice. Name who acts. Use the passive only when the actor is unknown.
3. Simple tenses. Avoid `is running` and `has run` unless the result matters now.
4. One word for one thing. Do not swap synonyms (`check`, then `verify`).
5. Plain words: `use`, `start`, `stop`, `before`, `to`. Not `utilize`, `commence`, `prior to`, `in order to`, `ensure`.
6. No semicolons. No phrasal verbs (`spin up`). No stack of more than 3 nouns.
7. Paragraph: 6 sentences at most, main point first. Use a list for 3 or more items.
8. Keep every fact, number, name, grade tag and hedge. `may` stays `may`.

Never apply to: the captain's published words, quoted text, code, commands, names, legal or terms text, comments that explain why.

Check: `plain-check <file>`. It checks form only. It does not check facts.

## 80% table

`plain-check` tests R1 to R9. Pass: 0 hard findings, and at most 2 soft findings per 100 words after masking. The "80%" is a label, not a measurement. Limits are third-party.

| ID | Rule | Limit | Strength |
|---|---|---|---|
| R1 | Sentence length | 25 words; in a numbered step 20 | hard at 25, soft at 20 in steps |
| R2 | Semicolon | 0 | hard |
| R3 | Paragraph length | 6 sentences | hard |
| R4 | Plain-word list (about 30 pairs) | 0 listed words | hard |
| R5 | Passive voice | `be` or modal + `be` + participle | soft |
| R6 | Progressive tense | `is/are/was/were` + `-ing` | soft |
| R7 | Phrasal-verb tricks (short list) | 0 | soft |
| R8 | One word, one meaning (synonym groups) | 1 per group per file | soft |
| R9 | Latin abbreviations (`e.g.`, `i.e.`, `etc.`) | 0 | soft |

Relaxed, not checked: the approved-word dictionary (needs the official copy), contractions, `-ing` forms other than the progressive, the 3-noun limit, safety-text format, articles, one instruction per sentence.

Word counting: a code span counts as one word. A masked span counts as zero.

## Carve-outs

The checker masks these before it counts anything: fenced code, inline code, `>` quote lines, text in `"..."` or `“...”`, URLs, paths, `[S]`/`[3P]`/`[J]`/`[?]` tags, table rows, and anything between `<!-- ste:off -->` and `<!-- ste:on -->`.

It refuses files under `areas/blog/` (the captain's voice) unless run with `--force`.
Not in scope: worker briefs, status lines, `AGENTS.md` files, decision records.
