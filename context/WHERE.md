# WHERE — what lives where, what it does, how, and when

The map (`home/AGENTS.md`) tells agents where to go. This file tells *you*.
Status: **live** = works today · **rebuild** = works after you merge the map and run `./rebuild.sh` · **todo** = not set up yet.

## 1. The big picture

```
~/github/codeami/dotfiles/          ONE git repo: machine setup + agent context
│
├── home.nix  ──(./rebuild.sh)──►   creates every link below in ~
│
├── home/AGENTS.md  ◄─────────────  ~/.claude/CLAUDE.md        (Claude Code)
│   the map                         ~/.codex/AGENTS.md         (Codex)
│                                   ~/.config/opencode/AGENTS.md (OpenCode)
│                                   ~/.gemini/GEMINI.md        (Gemini CLI)
│                                   ~/.agents/AGENTS.md        (backpass target)
│
├── context/  ◄───────────────────  ~/context        rooms · inbox · tests
└── second-brain/                   notes (its own map)

tools write their own logs  ──►  ~/.claude/projects/  ~/.codex/sessions/  …
backpass reads those logs   ──►  proposes edits to home/AGENTS.md  ──►  you approve
```

## 2. Inside dotfiles (`~/github/codeami/dotfiles/`)

| Path | What it is | Who reads / writes it | When | Status |
|------|-----------|------------------------|------|--------|
| `home.nix` | The link table: which file in the repo appears where in `~` | You edit; home-manager reads it | Only when you add or move a link | live |
| `bootstrap.sh` | Sets up a fresh Mac from this repo | You run it once | New machine | live |
| `rebuild.sh` | Re-applies `home.nix` (creates/updates links, packages) | You run it | After any `home.nix` change | live |
| `home/AGENTS.md` | **The map.** Who you are, house rules, routing table, tools, naming, end-of-session rule, canary | Every agent reads it at session start (through the links). You edit it. `backpass apply` writes approved edits. Claude in Cowork can't read it (protected) | Read: every session. Written: rarely, on purpose | live (new version after merge) |
| `home/CLAUDE.md` | Contains only `@AGENTS.md`. Not linked anywhere; a pointer for anyone opening `home/` as a project | Nobody, in practice | — | harmless |
| `home/.claude/settings.json` | Claude Code settings: permissions, hooks | Claude Code at start; you edit; protected from Claude | When adding a hook (e.g. end-of-session) | live · hook **todo** |
| `home/.pi/agent/*` | Pi themes, extensions, models, settings | Pi | Pi changes | live |
| `home/.config/{wezterm,nvim,herdr}` | Terminal, editor, agent-window settings | Those apps | Rarely | live |
| `context/` | Everything the map routes to → linked to `~/context` | See section 3 | — | rebuild |
| `second-brain/` | Notes: `raw/` sources (gitignored), `inbox/` captures, `nodes/` one-idea notes, `output/` review pages and frames, `stages/` the ICM lifecycle | You and agents on "research and learning notes" | Whenever you learn something worth keeping | live |
| `docs/` | Factory notes (`kun-factory-features.md`, `dsh-kun-factory-map.md`) | You | Reference | uncommitted |
| `.backpassrc.json` | backpass settings for *this repo's* own rules (project scope) | backpass | When backpass runs here | uncommitted |
| `scratch/` | Experiments, incl. a second DeepSeek Harness copy | You | — | uncommitted · can go |

## 3. Inside `~/context` (= `dotfiles/context/`)

| Path | What it is | Who reads / writes it | When | Status |
|------|-----------|------------------------|------|--------|
| `README.md` | How each tool loads the map, wiring steps, the session loop | You | Setup, troubleshooting | live |
| `WHERE.md` | This file | You | When you've lost track of something | live |
| `AGENTS.proposed.md` | The new map, waiting to be merged into `home/AGENTS.md` | You (VS Code diff) | Once; delete after merging | temporary |
| `areas/blog/CONTEXT.md` | How a blog post is made here | Agent, when the route says "blog" | Every blog task | live |
| `areas/blog/voice.md` | Your tone rules (kept short, grows from feedback) | Agent on blog tasks; you edit | Every blog task | live |
| `areas/blog/template.md` | Section layout for posts | Agent on blog tasks | New post | live |
| `areas/blog/drafts/` | Drafts + `img/` frames | Agent writes, you edit | During writing | live |
| `areas/factory/CONTEXT.md` | How coding work goes through FirstMate and Kun's tools | Agent on factory tasks | Every factory task | live |
| `areas/cert-prep/CONTEXT.md`, `notes/` | Cert topics mapped to things you've built; one note per topic | Agent on cert tasks | Study sessions | live |
| `inbox/_template.md` | Shape of an end-of-session note | Agent | At "end of session" | live |
| `inbox/sessions/` | One note per session: goals, constraints, decisions, where the AI went its own way, files read | Agent writes; you skim; backpass sees them inside the session logs | Written at "end of session"; skimmed each morning | rebuild |
| `tests/run.sh` | 32 structure checks (blog sections 1–3), no tokens | You | After editing the map, a room, or `home.nix` | live |
| `tests/e2e-probe.sh` | Asks each installed agent for the canary from an empty folder | You (costs a few tokens) | After `./rebuild.sh`, or when an agent seems to ignore the map | rebuild |

## 4. Links in `~` (made by `./rebuild.sh`, never edit them directly)

| Link | Points to | Read by | Status |
|------|-----------|---------|--------|
| `~/.claude/CLAUDE.md` | `home/AGENTS.md` | Claude Code (CLI, Desktop "Code" tab), FirstMate crew on Claude | live |
| `~/.codex/AGENTS.md` | `home/AGENTS.md` | Codex, FirstMate crew on Codex | live |
| `~/.config/opencode/AGENTS.md` | `home/AGENTS.md` | OpenCode | live |
| `~/.gemini/GEMINI.md` | `home/AGENTS.md` | Gemini CLI | rebuild |
| `~/.agents/AGENTS.md` | `home/AGENTS.md` | backpass (first file it edits in user scope) | rebuild |
| `~/context` | `dotfiles/context` | You, agents (room paths) | rebuild |
| `~/.claude/settings.json`, `~/.pi/agent/*`, `~/.config/{wezterm,nvim,herdr}` | matching files in `home/` | those apps | live |

Pi's global instructions file isn't linked yet — check Pi's docs for its path, then add one line to `home.nix`. **todo**

## 5. Written by tools, outside the repo (don't edit)

| Path | What | Used by |
|------|------|---------|
| `~/.claude/projects/<folder>/<id>.jsonl` | Claude Code session logs | backpass |
| `~/.codex/sessions/YYYY/MM/DD/*.jsonl` | Codex session logs | backpass |
| `~/.local/share/opencode/opencode.db` | OpenCode sessions | backpass |
| Pi, Grok, Cursor, Hermes stores | their session logs | backpass |
| `~/.config/backpass/user/` | backpass evidence and remembered rejections for your global rules | backpass |
| `~/.treehouse/` | Pool of reusable git worktrees | treehouse, FirstMate |
| `~/.lavish-axi/` | Lavish review state | lavish-axi (also backpass apply) |

## 6. Projects and other folders

| Path | What | Context it adds |
|------|------|-----------------|
| `~/github/firstmate/` | FirstMate itself: `AGENTS.md` = the first mate's job description; `state/` runtime | Its own `AGENTS.md` (supervisor role) on top of the map |
| `~/github/firstmate/data/captain-shared.md` | **Who you are now, current priorities, how to work with you** — quoted and dated. Private (gitignored) | FirstMate writes (inspect-then-update); the map routes other tools here read-only |
| `~/github/firstmate/data/captain.md` | Home-domain preferences, hardware facts | FirstMate writes |
| `~/github/firstmate/data/learnings.md` | Curated operational facts, with decay markers | FirstMate writes via `/stow` |
| `~/github/firstmate/data/backlog.md` | The work queue; task-scoped notes live with each item | FirstMate (`tasks-axi`) |
| `~/github/firstmate/data/<id>/report.md` | Scout findings | crewmate (scout) |
| `~/github/firstmate/projects/<repo>/` | Each project (one clone per repo) | `<repo>/AGENTS.md` (build, test, repo rules) + `CLAUDE.md` containing `@AGENTS.md` |
| `~/ai-agents-memory-frameworks/` | Research on memory systems (`memory-frameworks/`), `icm-architect`, `higher-order-thinking` (has `yt_transcript.py`) | Own `AGENTS.md`; not routed from the map yet |
| `~/dsh/` | DeepSeek Harness | Own `AGENTS.md` per folder |
| Claude Project "Enhance workflows…" (claude.ai) | `claude/icm-shared-context-design.md` | Cloud only; chat sessions there can't see your disk |

## 7. When things happen

```
new machine       clone dotfiles → ./bootstrap.sh → links appear → tests/run.sh
change home.nix   ./rebuild.sh → tests/run.sh → tests/e2e-probe.sh
session start     tool opens its link → home/AGENTS.md → route → areas/<room>/CONTEXT.md
                  (in a project: + <repo>/AGENTS.md)
during            say feedback as rules ("too formal — keep my tone")
"end of session"  FirstMate: /stow → data/{captain,captain-shared,learnings}.md
                  elsewhere: agent writes ~/context/inbox/sessions/<date>-<tool>-<slug>.md (git-ignored)
                  (the tool's own log is already on disk)
night             backpass --scope user   reads logs → proposals, writes nothing   [todo: schedule]
morning           backpass apply → cards in Lavish → approved edits land in home/AGENTS.md
                  → git diff → commit;  skim inbox/sessions/ for one-offs
weekly            prune drafts; check map is still ≤ 120 lines (tests/run.sh)
```

## 8. Not set up yet

- Schedule backpass nightly (launchd on the Mac), or run it by hand each morning.
- End-of-session hook in `home/.claude/settings.json`, so Claude Code writes the inbox note without being asked.
- Pi's global instructions link.
- `context-icm` MCP server for chat apps (load / save context).
- Decide on the uncommitted dotfiles items (`docs/`, `evals/`, `paper/`, `contrib/`, `scratch/`, `.backpassrc.json`).
