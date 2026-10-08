# 02-spec: turn approved intent into numbered acceptance criteria

One job: say what "done" means, line by line, tied to his words.

## Inputs
| Source | File | Section | Why |
|---|---|---|---|
| Working (this run) | `data/<task-id>/01-intent.md` (needs `approved:`) | "## Captain's words" | the only source of requirements |
| Reference | `~/github/firstmate/AGENTS.md` | "### Intake and authority" | delivery mode and yolo come from the registry, not the spec |
| Reference | `~/github/firstmate/AGENTS.md` | "## 11. Crewmate briefs" | keep the spec narrow: no generalisation he did not ask for |
| Reference | the project's `AGENTS.md` and README | all | build and test rules |

## Process
1. For each I line, write the smallest criterion that proves it: `A2 (I1, I3): ...`.
2. A criterion with no source says `A4 (derived: <why>): ...`.
3. Under "## Out of scope", list what you were tempted to add, citing the I it stretches. Do not add it.

## Outputs
- `02-spec.md` in `data/<task-id>/` (pasted into the brief's Firstmate spec)

## Human gate
Conditional. Check: run `~/context/bin/chain-check data/<task-id>`. Every A cites an I or says `derived:`; every I is covered or listed under Out of scope or Open. Ask him only if it prints a derived or uncovered line.
