# Docs rule: code explains itself; docs hold what code cannot

One home for this rule. `/grill-with-docs` reads it before it writes anything.

Names, types, tests and why-comments carry what code does and why it is shaped so.
A doc earns its place only if it holds something code cannot hold.

## Keep: five kinds (a doc sentence must name its kind)

- K1 Words. Glossary entries: the project's own terms, one or two sentences, with `_Avoid_`
  synonyms. No file names, function names, code or how-it-works.
- K2 Decisions. A record that passes all three gates: hard to reverse, surprising without
  context, a real trade-off. Or a constraint from outside the repo.
- K3 Intent. The captain's words (`I1..In`) and acceptance criteria (`A1..An`), or a README's
  statement of what the product must do for whom. What and for whom, never how.
- K4 Outside facts. A claim about the world (browser support, a licence, a price) with its
  source and the date it was read.
- K5 Pointers. Where things are and how to run them, when a reader cannot find that by looking.

## Cut: four smells

- S1 Restates code. Delete the sentence: if a reader can get it back from the code, tests or
  git history, it is a copy.
- S2 Drifts. Change the code and the sentence turns false without anyone being told (a value,
  a path, a name, a list of steps). A doc that is a cache of code, and not generated, is cut.
- S3 Answers file. Interview answers or transcripts committed beside what they shaped.
- S4 Plan kept as description. A build brief that outlives the build and now reads as docs.

## The test: three questions, in order

1. Kind. Is the sentence K1 to K5? No: cut it, or say which kind it is.
2. Recover. Delete it. Can a reader get the same fact from code, tests or history? Yes: cut (S1).
3. Drift. Change the code. Does the sentence turn false unnoticed? Yes, and it is not generated:
   cut, or generate it (S2). A K3 sentence stays true when code changes; a test fails instead.

Keep only when the answers are: a kind, not recoverable, does not drift.

## What a script can decide, and what it cannot

- Script (no model): a doc names a path or identifier the repo no longer has (S2); a doc line
  copies a code constant's value, or has gone stale against it (S1/S2); a glossary entry holds
  code, a path or a call (K1 purity); a doc has no recognisable kind by location.
- Judgement (model or human): whether a sentence is recoverable (question 2), and whether
  a decision passes the three gates.
