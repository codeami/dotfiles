# Golden questions

`questions.tsv`: 21 fixed questions with known evidence nodes, built from the real nodes.
Columns: `id, category, question, evidence (comma-separated node slugs; empty = no answer in the store), store`.

Categories: `single` (8), `two-source` (5), `paraphrase` (4, wording avoids the node's own words), `no-answer` (3), `contradiction` (1).

`store` is `real`, or `fixture:<name>` for a seeded test copy under `fixtures/<name>/nodes/`.
`fixtures/contradiction/nodes/long-running-loops.md` is marked `fixture: true`: a copy of a real node with a 30 s vs 60 s disagreement. It is laid over the real nodes for that one question only. Real nodes are never edited to fake a contradiction.

Run: `python3 scripts/golden.py` (no model, no network). It ranks nodes by IDF-weighted keyword overlap (tags, slug, claim and body count differently) and prints Recall@5, Hit@5 and the abstain rate per category.

What the runner cannot do: it does not answer, cite or say which source superseded which. For the contradiction question it only checks that the right node is retrieved and that its `Positions:` are well formed (newest position current, older ones marked superseded). A fresh session reading that node must still produce "60, cites both, B superseded A".

The abstain threshold (6.0) was picked after looking at the scores of these same questions, so the no-answer number is optimistic.
