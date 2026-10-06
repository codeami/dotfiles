---
tags: [icm, context, agentic-stack]
links: [icm-layer-ladder, icm-routing-table-is-the-core-pattern, icm-layers-dont-change-labels-do]
source: Jake Van Clief, Clief Notes Foundation 0.2 "The Full Walkthrough" (raw/jvc-course/0.2); paper arXiv:2603.16021 §3
---

# ICM: map, rooms, tools — three workspace roles

Claim: A folder workspace needs exactly three kinds of file, each with one job: a Map (the entry file — `CLAUDE.md` or `AGENTS.md` — that says what the project is and routes each task), Rooms (one `CONTEXT.md` per kind of work that explains the process, the files and what good looks like), and Tools (skills, MCP servers, scripts that perform specific operations, wired only into the rooms that need them).

Evidence: "Give every part a job. Map: route the task. Room: explain the work. Tool: perform a specific operation. You should be able to explain which files one task needs." The paper's five layers (identity, workspace routing, stage instructions, reference material, run inputs/outputs) are the formal version; map/rooms/tools is the teaching model.

Elaboration:
- Not every skill in every room: the writing room references a humanizer skill, the production room a testing skill.
- The three-file minimum (`AGENTS.md`, `CONTEXT.md`, `REFERENCES.md`, plus `drafts/`) is one map, one room, one reference — enough to run a first task.
- Comes from 1972 separation of concerns, not from prompting tricks.

Why it matters here: `~/context/AGENTS.md` is the map, `areas/<name>/CONTEXT.md` are the rooms, `skills/` are the tools. The vendor overlays (`~/.claude`, `~/.codex`) hold nothing but pointers to the map and the tools that vendor can run.
