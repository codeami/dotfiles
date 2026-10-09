# 01-intent: turn the captain's words into an approved intent

One job: write down what was asked, in his words, and nothing else.

## Inputs
| Source | File | Section | Why |
|---|---|---|---|
| Working (this run) | his messages, plus any note he points to | all | the only source of intent |
| Reference | `~/github/firstmate/AGENTS.md` | "## 11. Crewmate briefs" | only his ask and stated boundaries become the brief's intent |
| Reference | `~/github/firstmate/bin/fm-dod-lib.sh` | (file header) | the `--intent` provenance rule |

Do NOT load: project code, the backlog, other runs' files.

## Process
1. Restate the ask in one sentence. Ask in rounds of up to five questions, each with your recommended answer, worded so "yes" accepts it.
2. Repeat rounds until no open question could change the build. Scouts: restate and proceed.
3. Write `01-intent.md`: "## Captain's words" as `I1..In` (his words, or marked `context:`), then "## Open questions and assumptions".

## Outputs
- `01-intent.md` in `data/<task-id>/`

## Human gate
Ships: yes. Read I1..In, edit in place, write `approved: <date>` at the top. 02 does not start before that line exists. Check: every I line is his words or marked `context:`; assumptions are never under "Captain's words".
