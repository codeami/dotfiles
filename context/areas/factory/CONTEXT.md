# Room: software factory

Work on any repo through FirstMate and Kun Chen's tools. One task = one run through
the stages below, in order. Run files live in `data/<task-id>/` as `NN-name.md`; the
next stage starts only when the earlier output exists (and, where the gate is yes,
carries `approved: <date>`). Fix a wrong result in the stage file, not the output.

| Stage | Name | Job | Owner / contract | Gate |
|---|---|---|---|---|
| 01 | intent | his words as I1..In | `01-intent/` | yes (scouts: restate, proceed) |
| 02 | spec | acceptance criteria A1..An | `02-spec/` | conditional |
| 03 | tasks | split, pick ship or scout, write the brief | FirstMate `AGENTS.md` "### Intake and authority" | no |
| 04 | build | worktree, branch, tests | crewmate; project `AGENTS.md` | no |
| 05 | validate | `no-mistakes`: review, test, docs, lint, PR | `no-mistakes` skill | conditional |
| 06 | review | asked versus delivered | PR-ready message | yes |
| 07 | land | merge on his word | `bin/fm-pr-merge.sh` | yes |
| 08 | learn | `/stow`, backpass, end-of-session note | `/stow` | yes |

Never push `main`; loops use `gnhf` with a token cap. Each repo keeps its own
`AGENTS.md`. Check a run: `~/context/bin/chain-check data/<task-id>`.
Optional: `mattpocock/skills` (`/grill-me`, `/code-review`); pick `/code-review` or
`no-mistakes` per project, not both. Projects: see FirstMate's registry.
