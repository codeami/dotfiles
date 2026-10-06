---
tags: [icm, prompting]
links: [icm-storage-is-not-active-context, icm-spec-is-the-leverage-point]
source: Clief Notes Foundation 1.3 "How to Structure Any Prompt", 2.3 (raw/jvc-course)
---

# ICM: a prompt has five typed slots; the folder holds the stable ones

Claim: Any request decomposes into role, task, context, constraints and output format; the stable slots (identity, project context, standing constraints) live in files, and the prompt supplies only what changes per task.

Evidence: 1.3 lists the five parts and ends: "Ongoing work: keep stable context in maintained files and state the current task in the prompt." 2.3 reframes the same five as Mad Libs blanks: "typed slots that shape what the model generates." 3.2: "Your context files handle identity and project context. Your prompts handle task, constraints, and output format."

Elaboration:
- Constraints double as review criteria ("keep unconfirmed dates conditional, do not invent owners") — write them so you can check the output against them.
- A role guides emphasis but "a job title does not supply the facts."
- Break large work at a review point: directions → agreed brief → first deliverable → review → next.

Why it matters here: this is the contract between `areas/<x>/CONTEXT.md` (stable slots) and what a FirstMate launch brief or a chat prompt must still carry (task, output location, review). It is also the exam-style "prompt structure" answer.
