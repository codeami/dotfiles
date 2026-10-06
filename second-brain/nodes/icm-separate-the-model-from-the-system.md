---
tags: [icm, architecture, mcp, cert-prep]
links: [icm-value-ladder-which-layer-am-i-on, kun-chen-agent-policy, icm-map-rooms-tools]
source: Clief Notes Foundation 2.5 "OpenClaw: Orchestration and AI", 2.7 "From Nazi Psychology to AI Auditing" (raw/jvc-course); Ethics Engine paper arXiv:2510.11742
---

# ICM: separate the model from the system (60/30/10)

Claim: Trace one request through input → routing/orchestration → tools → model → human review; most of an "AI agent" is ordinary software (async queues, retries, APIs, parsing, scoring) and the model is one replaceable step. Design with the 60/30/10 heuristic — repeatable code, explicit rules, model judgment — and test it by asking which steps would still exist if the model changed.

Evidence: 2.5's four parts (model, tools, routing and orchestration, channels/interface); "describing it as 'zero AI' confuses a product with the model it uses." 2.7 takes the Ethics Engine apart: "the first thing you find is not a model. It is a traffic controller." MCP is the USB/HTTP/LSP move — host, client, server; "a model can propose a tool and its arguments; the host application applies its controls." 60/30/10 is "a design heuristic… not a measured ratio."

Elaboration:
- Three questions: what survives a model change; where does data go (self-hosting one part ≠ local); what can a person verify and what happens when a tool fails.
- "Agent" means: distinguish steps the software selects, the model proposes, and a person reviews.
- Parsing failures must not silently become evidence; keep model version, prompts, sampling and scoring rules with any result.

Why it matters here: the FirstMate stack is the 60 (worktrees, watchers, no-mistakes gate), AGENTS.md rules are the 30, the crewmate's model call is the 10 — which is why Claude Code, Codex and Pi are interchangeable crewmates. Also the cleanest MCP host/client/server explanation for the architect cert.
