---
tags: [method]
links: [agent-ergonomics]
source: Kun Chen, "Agent Engineering Workflow" (agent harnesses)
---

# Keep the workflow agent-agnostic

Claim: Keep the workflow harness-agnostic; the model and agent landscape changes too fast to lock into one.

Evidence: "I have been very strict about making my workflow agent agnostic because the landscape is changing very, very fast. Who knows which model or agent will be the best performing one next month?"

Elaboration:
- Kun runs four harnesses (Claude Code, Codex CLI, Pi, OpenCode) through one shared memory and skills setup.
- The workflow, not the harness, is the moat; memory files and skills port across agents.
- This is the correct frame for our DSH-centric stack: DSH is the current choice, not a lock-in.
