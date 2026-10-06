---
tags: [agentic-stack, memory, icm, blog]
links: [substrate-dialogue-to-graph, icm-every-workflow-comes-from-dialogue, icm-read-draft-check-correct, kun-chen-agent-policy]
source: backpass README (github.com/kunchenguid/backpass, read 2026-10-06); Substrate frames 0543/0545 from Jake Van Clief's video
---

# backpass vs Substrate: the editor and the microscope

Claim: Both turn dialogue into better instructions, at different zoom levels. Substrate (unreleased) explains one conversation in detail: two graphs of what the user meant and what the model decided, with the gaps and repairs logged turn by turn. backpass (open source, installed) edits the rulebook across many sessions, but only when a problem repeats with quoted evidence, and only through human review.

## Side by side

| | backpass | Substrate |
|---|---|---|
| Status | open source, local | unreleased research tool (Kay Kumar, Edinburgh) |
| Input | raw transcripts read from disk: Claude, Codex, Pi, OpenCode, Grok, Cursor, Hermes | one pasted conversation |
| Span | many sessions (default last 30 days, ≤100 transcripts, recency-weighted) | one conversation, turn by turn |
| Looks for | gaps (missing rules) and harm (rules that hurt) | divergences (unilateral addition, scope drift) and grounding acts (acceptance, repair) |
| Evidence | verbatim quotes from ≥2 distinct sessions; quoteless items discarded; harm evidence weighted highest | each node links to the turn that produced it, with a confidence score |
| Output | ADD / REMOVE / REWRITE / EXTRACT→SKILL / MOVE edits to AGENTS.md + skills, under a 5,000-token always-loaded budget | G_user + G_model graphs and a divergence/grounding event log |
| Writes | only on `backpass apply`, card by card in lavish-axi; rejections remembered | nothing shown |
| Models | cheap analysis ladder + strong synthesis ladder via acpx | an LLM extractor (claude-opus-4-7 in the demo) |
| Pre-processing | deterministic: tool calls collapsed to one line, secrets redacted, 96–99% compression | not shown |

## What each misses

- backpass needs a repeat: a one-off but costly mistake never becomes a rule.
- backpass works from quotes, not an explicit model of intent: a divergence the user never voiced is invisible to it.
- Substrate is per-conversation and (as shown) produces no rules: finding the gap is not fixing the rulebook.

## How they combine in this setup

1. The end-of-session summary (`inbox/_template.md`) is a Substrate-lite pass written inside the session; its "where the AI went its own way" section becomes quotable text in the transcript that backpass already reads.
2. backpass turns repeats into proposed edits; the morning review approves them.
3. One-offs: skim the inbox notes in the morning and add important single-occurrence rules by hand.

## Gotchas

- backpass user scope writes to the first existing of `~/.agents/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`. `~/.claude/CLAUDE.md` links to `dotfiles/home/AGENTS.md`, so edits land in the map; if `~/.agents/AGENTS.md` ever exists unlinked, backpass edits that instead. Link it to the map in `home.nix`.
- Name collisions in search: "G-Substrate" (arXiv 2601.22384) is an unrelated graph-learning framework; the "Epistemic Graph Ledger" is a single Medium post. Neither describes Kay's tool.

## Blog analogy

Substrate is the microscope: it shows exactly why one conversation went wrong. backpass is the editor: it waits until the same mistake shows up twice, then marks up the rulebook and asks you to sign off.
