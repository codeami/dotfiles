# context — rooms, inbox and tests for the shared agent context

Part of `dotfiles`. The **map** (base context every agent loads) is
`dotfiles/home/AGENTS.md`; this folder holds everything the map routes to.
`home.nix` links it to `~/context`.

```
dotfiles/
├── home.nix              the link table
├── home/AGENTS.md        the map: who, rules, routing   (one file, every tool)
├── context/              → ~/context
│   ├── areas/<room>/     CONTEXT.md per kind of work (+ voice, templates, drafts)
│   ├── inbox/            _template.md · sessions/ (end-of-session notes)
│   └── tests/            run.sh · e2e-probe.sh
└── second-brain/         notes (its own map)
```

## How each tool loads the map

| Tool | Reads at start | Link (from `home.nix`) |
|------|----------------|------------------------|
| Claude Code (CLI, Desktop "Code" tab) | `~/.claude/CLAUDE.md` | → `home/AGENTS.md` |
| Codex | `~/.codex/AGENTS.md` | → `home/AGENTS.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` | → `home/AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` | → `home/AGENTS.md` |
| Pi | its global instructions file (check Pi docs) | add a line when known |
| FirstMate crew | whatever their harness reads (they are Claude Code / Codex / Pi) | nothing extra |
| Claude Desktop chat, claude.ai, Gemini web | no local file | paste the map into a Project, or later the `context-icm` MCP server |

Note: the Claude app's file bridge marks `home/AGENTS.md` as protected (it is
the file behind Claude's own `~/.claude/CLAUDE.md`), so Claude in Cowork can't
read or edit it. Changes to the map go through you — which is the point.

## Finish wiring (on the Mac, while FirstMate is idle)

1. Merge `AGENTS.proposed.md` into `home/AGENTS.md` (keep ≤ 120 lines), then delete the proposed file.
2. `./rebuild.sh` — creates `~/.gemini/GEMINI.md` and `~/context` (already added to `home.nix`).
3. `bash ~/context/tests/run.sh` and `bash ~/context/tests/e2e-probe.sh`.

Running sessions keep their old context; new sessions pick up the new map.

## The session loop

```
start   → tool loads the map (+ the room's CONTEXT.md)
during  → you give feedback and constraints out loud
end     → you say "end of session"; the AI writes notes to inbox/sessions/
night   → backpass reads the notes, proposes rule changes (writes nothing)
morning → you approve or reject; only approved rules go into the map
```
