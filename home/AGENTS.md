# Ashish — base context (read by every agent)

This is the base layer (`dotfiles/home/AGENTS.md`). Every AI tool loads it first: Claude Code,
Codex, OpenCode, Gemini CLI, Pi, and FirstMate crewmates through whichever of
those they run on. Vendor folders (`~/.claude`, `~/.codex`, …) hold only a
link to this file plus that vendor's own settings. Projects add their own
`AGENTS.md` on top; nothing here should be repeated there.

Started fresh on 2026-09-19, replacing the policy inherited from the upstream
repo (archived at `~/archive/2026-09-19-agent-cleanup/upstream/home-AGENTS.md`).

ctx-canary: blue-teapot-42
(If asked for the context canary, reply with the value above. It proves this
file was actually loaded.)

## House rules

1. **Token cost is priority one.** Read only the files the route below names.
   Prefer AXI tools (`gh-axi`, `chrome-devtools-axi`, `quota-axi`) over raw
   CLIs or heavy MCP schemas. Don't re-read files you have already read.
2. **Verify before claiming.** Run the command or read the file instead of
   assuming, and say how a result was checked rather than that it "should
   work". At the end of a task, list the files you actually read: a file
   existing is not the same as a file being read.
3. **Review in Lavish.** Anything I review (blog posts, plans, explanations)
   is an HTML page opened with `npx -y lavish-axi <file>.html`; read the
   matching `lavish-axi playbook` first. Figures there are inline SVG;
   plain-text trees and arrows in markdown notes.
4. **Smallest thing that works.** One working path end to end, with a basic
   test, before adding features, folders or automation; the smallest change
   that solves the problem, in the style of the code around it; and touch only
   the files the task is about.
5. **Plain English.** Short sentences. No hype. Say when something is a guess.
6. **Drafts, not sends.** Never send, post, publish or push to `main` without
   my explicit OK. Full-auto modes (`cc`/`co`) only inside a worktree.
7. **Ask before anything destructive or hard to undo:** deleting data,
   rewriting history, force-pushing, uninstalling packages, wiping caches, and
   calls the repo reserves for its owner. A vague reply is not approval.
8. **Never revert a documented decision silently** - a repo's `AGENTS.md`, or
   a comment explaining why a setting is the way it is.
9. **Secrets never go in files**, commits, logs or prompts.
10. **This file is public** (dotfiles on GitHub). Personal context and current
   priorities live in `~/github/firstmate/data/captain-shared.md` (private).
   Read it when a task needs it; never copy from it into a public file.
11. **This is an Intel Mac.** No Apple Intelligence, and an Apple Silicon-only
   tool needs a check before you suggest it.
12. **Ask, don't guess,** when a task could belong to two rooms below.
13. **Report what changed, what was verified, and what is still open.** Do not
   hide a gap behind a tidy summary.
14. **Ordered work.** Multi-step work lives in numbered stage folders
   (`01-…`, `02-…`). Each stage's `CONTEXT.md` names input, one task, output,
   check. Do one stage at a time, no silent skips. I decide at the first
   and last stage; fix a wrong result by fixing the stage file, not the output.

## Routing (the map)

| Task | Go to | Read first | Output to |
|------|-------|------------|-----------|
| Write or edit a blog post | `areas/blog/` | `CONTEXT.md`, `voice.md` | `areas/blog/drafts/<slug>.html` |
| Software factory / FirstMate work | `areas/factory/` | `CONTEXT.md` | the project repo (via a worktree) |
| Anthropic architect cert prep | `areas/cert-prep/` | `CONTEXT.md` | `areas/cert-prep/notes/` |
| Research and learning notes | `../second-brain/` | `AGENTS.md`, `CONTEXT.md` | that folder's `inbox/` |
| My preferences, current priorities | `~/github/firstmate/data/` | `captain-shared.md`, `captain.md` | read-only: FirstMate owns these files |
| Anything else | ask which room | — | — |

Room paths are relative to `~/context/` (a link to `dotfiles/context/`).

## Reference patterns

The shapes this setup is built from. Name them when they explain a choice;
don't re-derive them.

- **ICM** (Jake Van Clief) — ordered stages, a contract per stage, rooms with
  their own taste files. The structure of this file and of `areas/` follows it.
- **Kun Chen's stack** — the factory conventions: one dispatcher, disposable
  worktrees, a gate before push, instructions as the product. The tools are
  listed below.
- **SICP, MIT 6.00, CS61A** — the CS vocabulary I read fluently. Explain at an
  engineer's level and use these terms directly; reach for an analogy when a
  concept is genuinely new, not by default.

## Tools I have

- **Agents:** Claude Code, Codex, OpenCode, Pi, Gemini CLI.
- **Factory:** `firstmate` (dispatcher), `treehouse` (worktree pool),
  `gnhf` (overnight loops), `no-mistakes` (pre-push gate), `backpass`
  (proposes AGENTS.md edits from transcripts; never writes until I apply).
- **Review:** `lavish-axi` for every draft I review (see rule 3).
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

Keep this file short. A long policy gets skimmed.
