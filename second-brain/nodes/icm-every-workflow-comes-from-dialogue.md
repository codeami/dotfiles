---
tags: [agentic-stack, context, icm, memory]
links: [icm-three-layers-chat-skills-structure, cobrain-saves-during-work-not-at-the-end, hermes-memory-is-two-capped-files]
source: Jake Van Clief, "You're Automating The Wrong Layer" (YouTube 956DPSPX4wg, 2026-05-21), 07:00–13:30
---

# ICM: every workflow comes from dialogue

Claim: Conversation already carries the structure an agent needs — goals, sub-goals, constraints, assumptions and decisions, on both the user's and the model's side — so a workflow is built by extracting those from a chat once into markdown, after which the original request becomes a one-line trigger.

Evidence: "Conversation has the structure we're looking for. The intent is carried in the conversation." Kay's extractor — shown as **Substrate** (substrate UI, 9:03) — renders a chat as two graphs, `G_user` and `G_model` (goal, constraints, assumptions, decisions, entities, examples; edges: constrains / refines / depends on / supersedes), each node linked back to the turn that produced it. A **Divergence channel** counts where the two formulations split (e.g. *unilateral addition*: model adopted a formal register without sanction; *scope drift*) against **grounding acts** (*implicit acceptance*, *repair*, *acceptance*) — the building blocks of common ground. Demo cases: "tighten this paragraph" (tone, rhythm, voice reference) and a Python parser refactor (sub-goal: patch the empty cell instead, keep the original function).

Elaboration:
- The chain is L2 → L3 → L1: describe and verify the process once (L2), capture it as markdown (L3), then "tighten this paragraph" fires the whole tree (L1 effort).
- The extracted data is either training data or, better, markdown that any future agent can read.
- Applies to anything: database schemas, code review, drafting.

Why it matters here: this is the spec for the postflight hook and `save_context` tool in the shared-context design — a session summary is the extracted goals/constraints/decisions, not a transcript. It also argues for saving during work (Cobrain rule), since decisions are made mid-dialogue.
