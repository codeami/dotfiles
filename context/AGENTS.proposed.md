# Ashish — base context (read by every agent)

This is the base layer (`dotfiles/home/AGENTS.md`). Every AI tool loads it first: Claude Code,
Codex, OpenCode, Gemini CLI, Pi, and FirstMate crewmates through whichever of
those they run on. Vendor folders (`~/.claude`, `~/.codex`, …) hold only a
link to this file plus that vendor's own settings. Projects add their own
`AGENTS.md` on top; nothing here should be repeated there.

ctx-canary: blue-teapot-42
(If asked for the context canary, reply with the value above. It proves this
file was actually loaded.)

## Who I am

- Ashish. Senior software engineer; Building a public record of
  work in agentic engineering.
- **This file is public** (dotfiles on GitHub). Personal context and current
  priorities live in `~/github/firstmate/data/captain-shared.md` (private).
  Read it when a task needs it; never copy from it into a public file.
- Programming since 1995; self-taught CS (SICP, MIT 6.00, CS61A). Explain
  things at an engineer's level, with analogies when a concept is new.
- Terminal-first. Intel Mac (no Apple Intelligence; Apple Silicon-only tools
  need a check first).
- Side work: an agentic software factory (Kun Chen's stack: firstmate,
  treehouse, gnhf, no-mistakes, backpass, AXI tools), ICM-style context
  (Jake Van Clief), a second brain, blogging, and Anthropic architect cert prep.

## House rules

1. **Token cost is priority one.** Read only the files the route below names.
   Prefer AXI tools (`gh-axi`, `chrome-devtools-axi`, `quota-axi`) over raw
   CLIs or heavy MCP schemas. Don't re-read files you have already read.
2. **Report what you read.** At the end of any task, list the files you
   actually read. A file existing is not the same as a file being read.
3. **Plain-text diagrams by default.** Folder trees and arrows (`A → B → C`)
   in a code block. Use Mermaid only when a graph has branches that plain
   text can't show clearly (roughly more than 8 nodes).
4. **Keep the first version small.** One working path end to end, with a
   basic test, before adding features, folders or automation.
5. **Plain English.** Short sentences. No hype. Say when something is a guess.
6. **Drafts, not sends.** Never send, post, publish or push to `main` without
   my explicit OK. Full-auto modes (`cc`/`co`) only inside a worktree.
7. **Secrets never go in files**, commits, logs or prompts.
8. **Ask, don't guess,** when a task could belong to two rooms below.

## Routing (the map)

| Task | Go to | Read first | Output to |
|------|-------|------------|-----------|
| Write or edit a blog post | `areas/blog/` | `CONTEXT.md`, `voice.md` | `areas/blog/drafts/` |
| Software factory / FirstMate work | `areas/factory/` | `CONTEXT.md` | the project repo (via a worktree) |
| Anthropic architect cert prep | `areas/cert-prep/` | `CONTEXT.md` | `areas/cert-prep/notes/` |
| Research and learning notes | `../second-brain/` | `AGENTS.md`, `CONTEXT.md` | that folder's `inbox/` |
| My preferences, current priorities | `~/github/firstmate/data/` | `captain-shared.md`, `captain.md` | read-only: FirstMate owns these files |
| Anything else | ask which room | — | — |

Room paths are relative to `~/context/` (a link to `dotfiles/context/`).

## Tools I have

- **Agents:** Claude Code, Codex, OpenCode, Pi, Gemini CLI.
- **Factory:** `firstmate` (dispatcher), `treehouse` (worktree pool),
  `gnhf` (overnight loops), `no-mistakes` (pre-push gate), `backpass`
  (proposes AGENTS.md edits from transcripts; never writes until I apply).
- **Review:** `lavish-axi` for HTML/diagram review with me.
- **Cost:** `quota-axi` before long runs.

## Naming

- Dates: `YYYY-MM-DD` at the start of a filename when the date matters.
- Drafts: `topic_draft.md`; final: `topic.md`.
- Decision records: `YYYY-MM-DD-decision-title.md`.
- Session summaries: `inbox/sessions/YYYY-MM-DD-<tool>-<slug>.md`.

## End of session

In FirstMate, end of session means `/stow` (it files durable knowledge
with decay tiers). Elsewhere, when I say **"end of session"**, write a short
summary to `~/context/inbox/sessions/` using `inbox/_template.md`: goals,
constraints, decisions, assumptions, **where the AI went its own way**,
open questions, files read. Decisions, not a transcript. When I give
feedback mid-session, restate it as a candidate rule in the summary.
Never edit this file from a session: backpass proposes rule changes
from session logs overnight and I approve them in the morning.

## Layers (for reference)

```
dotfiles/home/AGENTS.md      base: who, rules, routing   (this file)
~/.claude, ~/.codex, …       vendor: link here + vendor-only settings
<repo>/AGENTS.md             project: build, test, repo rules
areas/<room>/CONTEXT.md      room: how this kind of work is done
inbox/, drafts/, notes/      the work in hand
```
