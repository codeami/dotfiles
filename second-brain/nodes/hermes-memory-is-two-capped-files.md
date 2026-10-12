---
tags: [memory, context, agentic-stack]
links: [global-memory-is-minimal, hermes-scans-memory-for-injection]
source: Hermes Agent docs, Persistent Memory (https://hermes-agent.nousresearch.com/docs/user-guide/features/memory, read 2026-10-12)
---

# Hermes: memory is two capped files

Claim: Hermes Agent keeps notes in two plain files with hard size caps, loaded once into the system prompt at session start.

Evidence: MEMORY.md (the agent's notes) is capped at "2,200 chars (~800 tokens)". USER.md (the user profile) is capped at "1,375 chars (~500 tokens)". Both sit in `~/.hermes/memories/` and are "injected into the system prompt as a frozen snapshot at session start." Memory "does not auto-compact": a write over the cap returns an error and does not silently drop entries.

Elaboration:
- Related: [[global-memory-is-minimal]].
- A third-party blog (mem0.ai) describes merge-at-80% behaviour. I did not find it in the official page; unconfirmed.
