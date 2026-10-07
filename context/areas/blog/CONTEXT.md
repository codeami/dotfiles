# Room: blog

Posts that teach one idea simply, for engineers new to agentic AI.
Every draft is reviewed in Lavish (Kun Chen's lavish-axi).

## Stages (do them in order)
The work moves through numbered folders: `01-idea` → `02-research` → `03-outline` →
`04-draft` → `05-review` → `06-publish`. Each has a `CONTEXT.md` with input, task,
output, check. I decide at 01 and 05; the middle runs on its own. If a result is wrong,
fix the stage file (or `voice.md`), not just the output.

## Process (detail for stage 04–05)
1. Start from the notes in `../../../second-brain/nodes/` the task names.
2. Read the Lavish playbooks first: `npx -y lavish-axi playbook explanation`
   and `npx -y lavish-axi playbook diagram`.
3. Write the draft as one HTML page: `drafts/<slug>.html`. One idea per
   section; open with an everyday analogy, then the real thing.
4. Figures are hand-drawn inline SVG (one concept per figure, an `id` and a
   `<title>` on every part so I can comment on it). Mermaid only if I ask
   for an editable whiteboard.
5. Check light, dark and phone width before handing over.
6. Open it for me with `~/context/bin/blog open <slug>` (or the board with
   `~/context/bin/blog`), then wait for my comments with
   `lavish-axi poll drafts/<slug>.html`. In FirstMate, the first mate arms its
   own Lavish watcher instead, so my comments wake it. Mark what you changed
   in each round (Lavish revision markers).
7. Every claim that can be checked gets a "Test:" line or a source link.
8. Never publish. `lavish-axi export` makes a standalone copy when I'm ready.

## Good looks like
Short paragraphs, concrete examples, honest caveats, credits at the end.
Use `voice.md` for tone. `template.md` is the section outline.
