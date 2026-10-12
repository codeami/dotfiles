---
tags: [memory, security, agentic-stack]
links: [icm-storage-is-not-active-context, hermes-memory-is-two-capped-files]
source: Hermes Agent docs, Persistent Memory (https://hermes-agent.nousresearch.com/docs/user-guide/features/memory, read 2026-10-12)
---

# Hermes: memory entries are scanned before they are saved

Claim: Because Hermes memory goes into the system prompt, each entry is checked for injection and exfiltration patterns before it is accepted.

Evidence: Entries are "scanned for injection and exfiltration patterns before being accepted." Content matching threat patterns, or containing invisible Unicode characters, is blocked.

Elaboration:
- Applies the point in [[icm-storage-is-not-active-context]]: text that reaches context can act as instructions, so it is screened at the write gate.
- See [[hermes-memory-is-two-capped-files]] for where these entries live.
