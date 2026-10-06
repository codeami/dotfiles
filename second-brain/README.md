# Second Brain

A structured, interpretable **context layer** that you and your agents both read and write.
Not a notes app. Built on ICM (Interpretable Context Methodology / Model Workspace Protocol,
arXiv:2603.16021).

- Humans write here (plain Markdown, any editor).
- Agents read/write here (DSH loads AGENTS.md, loads skills, walks the stages).
- backpass trains AGENTS.md + skills from session transcripts ("dialogue crystallizes into skills").
- no-mistakes gates every change before it lands.

## Start here

1. Read CONTEXT.md (the map + the layer ladder).
2. Answer setup/questionnaire.md once ("what pain are we solving?").
3. Walk one note through the lifecycle: stages/01-capture → 02-distill → 03-connect → 04-retrieve → 05-review.

## Structure (the layer ladder)

- AGENTS.md ......... Layer 0: "where am I" — always loaded
- CONTEXT.md ........ Layer 1: "where do I go" — the map
- stages/ ........... Layer 2: numbered lifecycle contracts (one job each)
- _config/ .......... Layer 3: principles + conventions (the factory)
- skills/ ........... Layer 3: crystallized procedures (progressive disclosure)
- shared/index.md ... Layer 3: the node graph
- nodes/ ............ Layer 4: distilled atomic notes
- inbox/ ............ Layer 4: raw captures awaiting distillation
