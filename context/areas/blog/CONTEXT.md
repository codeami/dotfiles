# Room: blog

Posts that teach one idea simply, for engineers new to agentic AI.
Every draft is reviewed in Lavish (Kun Chen's lavish-axi).

## Process
1. Start from the notes in `../../../second-brain/nodes/` the task names.
2. Read the Lavish playbooks first: `npx -y lavish-axi playbook explanation`
   and `npx -y lavish-axi playbook diagram`.
3. Write the draft as one HTML page: `drafts/<slug>.html`. One idea per
   section; open with an everyday analogy, then the real thing.
4. Figures are hand-drawn inline SVG (one concept per figure, an `id` and a
   `<title>` on every part so I can comment on it). Mermaid only if I ask
   for an editable whiteboard.
5. Check light, dark and phone width before handing over.
6. Open it for me: `npx -y lavish-axi drafts/<slug>.html`, then wait for my
   comments with `npx -y lavish-axi poll drafts/<slug>.html`. Mark what you
   changed in each round (Lavish revision markers).
7. Every claim that can be checked gets a "Test:" line or a source link.
8. Never publish. `lavish-axi export` makes a standalone copy when I'm ready.

## Good looks like
Short paragraphs, concrete examples, honest caveats, credits at the end.
Use `voice.md` for tone. `template.md` is the section outline.
