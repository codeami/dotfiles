# Conventions (Layer 3)

## Note format (Layer 4)

Every note in nodes/ is:

- a filename slug: lowercase, hyphens (e.g. icm-layer-ladder.md)
- front matter: tags, links, source
- a one-line claim (the atomic idea)
- verbatim evidence (quotes from the source)
- elaboration (optional)

## Links

- Use [[slug]] to link notes. Backlinks are implied.
- Every note links to at least one other note or a tag.
- shared/index.md is the single entry point; every note appears there.

## Naming

- stages are numbered 01..05, one job each.
- node filenames are the idea, not the author or date.

## Contradictions

When a new source disagrees with a node, do not overwrite the node. Add both positions under a `Positions:` heading, each as `- YYYY-MM-DD, <source>: <claim>`, and mark the older one `(superseded by YYYY-MM-DD, <source>)`. The current claim line states the newer position and names the older one. An answer from this store cites both sources and says which superseded which. If dates tie or are unknown, mark the node `unresolved` and keep both positions; a human decides. Log the change (see Log).

## Log

`log.md` records one line per operation, oldest first, append-only:

`YYYY-MM-DD | op | target | note`

`op` is one of `add`, `update`, `supersede`, `remove`, `check`, `rule`. `target` is a node slug or a path. `note` is one short phrase with the reason or source. Never edit or delete earlier lines; correct a mistake with a new line.

## Checks

`scripts/check_links.py` reports `links:` entries that point at no node and nodes nothing links to (read-only; exit 0 when clean). `scripts/golden.py` scores retrieval on `golden/questions.tsv` (see `golden/README.md`).
