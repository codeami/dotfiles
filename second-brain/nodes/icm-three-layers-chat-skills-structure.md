---
tags: [agentic-stack, context, icm]
links: [icm-layer-ladder, icm-every-workflow-comes-from-dialogue, kun-chen-agent-policy]
source: Jake Van Clief, "You're Automating The Wrong Layer" (YouTube 956DPSPX4wg, 2026-05-21), 01:30–07:00
---

# ICM: three layers of working with AI — chat, skills, structure

Claim: Working with AI matures through three layers, and most people automate at the wrong one: Layer 1 is chat and copy-paste, Layer 2 is refined prompts in a fixed order (skills), Layer 3 is folders and markdown that one agent navigates, triggering pieces only when needed.

Evidence: "Layer one is where you're just chatting with a chatbot… these skills are actually the layer 2… layer three… you're taking multiple skills, multiple prompts… and actually linking them together." Reported effect: 20–40% token reduction.

Elaboration:
- L1: low effort, weak impact; improvement requires ever-longer conversations and saved prompts.
- L2: someone else ran the L1 loop and froze the prompt order — that is what an Anthropic skill is.
- L3: skills are split so only the needed part loads; scripts (Python) added for determinism; folders replace LangChain/Semantic Kernel-style injection. One good harness per model, then let the model navigate structure.

Why it matters here: Ashish's `~/context/` ladder is L3. The design mistake to avoid is building orchestration code (L2 automation of L1) when a folder tier plus the existing Claude Code harness already does it.
