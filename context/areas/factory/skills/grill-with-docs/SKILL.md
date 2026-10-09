---
name: grill-with-docs
description: Interview me until intent is settled; log my words as I1..In, terms and decisions.
disable-model-invocation: true
---

# /grill-with-docs (stage 01-intent)

Adapted from mattpocock/skills `grilling` + `domain-modeling` (MIT), merged into one file.
Settle what the captain wants, in his words. Write intent, terms and decisions. Never write a doc that explains code.

## Reads
| Source | File | Section | Why |
|---|---|---|---|
| Working | his messages, saved verbatim to `data/<id>/01-words.txt` | all | every I line must quote them |
| Reference | `shared/questions.md` | "Rules", "The set" | the ordered questions and how to ask them |
| Reference | `shared/docs-rule.md` | "Keep", "The test" | what may be written |
| Reference | the project's `GLOSSARY.md`, if any | all | challenge his words against it |
| Reference | the project's code, read-only | only what a question needs | facts are looked up, never asked |

Do NOT load: the backlog, other runs, the project's other docs.

## Process
1. Append his words to `01-words.txt`, verbatim. Never edit it.
2. Run `bin/taste-check ask data/<id>/01-words.txt`: it lists the questions his words already answer. Ask the rest, in the order of `shared/questions.md`. Map them as a tree of decisions; the frontier is every decision whose prerequisites are settled.
3. Ask one round: a line `Round <n>`, then the frontier, at most 5 questions. Each is `Q1 [done] <title>: <body>` (the tag is the question's label in `shared/questions.md`) then `Recommended: <answer>`. Word it so "yes" accepts. Wait. One at a time if he asks.
4. Facts are yours: read code, files, the web. Never ask what you can look up. Decisions are his: never answer one for him.
5. After each round, write down what settled:
   - his answer: an `I` line in his own words (a substring of `01-words.txt`). Your reading of it goes under "Open questions and assumptions", never under "Captain's words". An I line works like a science claim: the claim is the line, the evidence is his verbatim words, the source is where he said it, the check is his approval.
   - a term he settled: a glossary entry in `glossary-candidates.md` (kind K1). Challenge a word that clashes with the glossary or is vague ("account: Customer or User?"). Test a fuzzy boundary with one concrete scenario.
   - a decision that is hard to reverse, surprising without context and a real trade-off: `decision-candidates.md` (K2). Anything else stays in the conversation.
6. When the frontier is empty, read `I1..In` back and ask "Is this a shared understanding?" Stop. Do not build. Do not approve.

## Output (in `data/<id>/`)
- `01-words.txt`, and `01-intent.md` in the format `bin/chain-check` reads: `## Captain's words` with `I1: ...`, then `## Open questions and assumptions`.
- `glossary-candidates.md`, `decision-candidates.md`: only if something settled. They are proposals. The ship that builds the project promotes them into its `GLOSSARY.md` or decisions folder inside its diff. This skill never writes into a project.

## Human gate
Ships: yes. Scouts: restate and proceed. When he says "approved", run
`bin/taste-check seal data/<id> --who captain --source "<where he said it>" --today <date>`. Only his word starts the seal.

## Never
- Write `approved:` yourself, or take silence as approval.
- Write a doc that restates code. Asked to "document the repo"? Return renames and why-comments as proposals instead.
- Commit an answers file or transcript beside the thing it shaped.
