---
tags: [memory, context, icm]
links: [icm-storage-is-not-active-context, progressive-disclosure]
source: Cobrain "Tools for your AI" guide (https://cobrain.space/guides/tools, read 2026-10-12)
---

# Cobrain: start_session loads one unit as a briefing

Claim: Cobrain's `start_session` tool is a read-only briefing for one unit (a project or client), so a session begins with a bounded set of notes and not the whole store.

Evidence: The guide calls it "The briefing for a unit": rules, index card, instructions, decisions, open sub-units and the last fifteen changes. It only reads. Other read tools are `load_context`, `list_units` and `recent_changes`.

Elaboration:
- Same shape as `load_context` in the shared-context design: a named, bounded set, not "everything".
- Guess: "unit" here means a project or client folder. The guide's wording does not define it in one line.
