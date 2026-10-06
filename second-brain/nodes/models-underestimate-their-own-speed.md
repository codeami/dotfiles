---
tags: [method]
links: [reproduce-bugs-end-to-end]
source: Kun Chen, "Agent Engineering Workflow" (global memory rule)
---

# Models underestimate their own speed

Claim: Models trained on human data overestimate development cost, so they implicitly bias toward cheap, low-quality solutions; correct that bias explicitly.

Evidence: "AI doesn't seem to know it can code much faster than humans yet... This biases the model to choose cheap solutions that are often low quality, not scalable, or hard to maintain."

Elaboration:
- Kun's rule: "When making technical decisions, don't give too much weight to development cost."
- A frontier model estimates a 3D game in weeks; asked to build it, it returns a playable version in minutes.
- The bias comes from human-derived training data, not from the model's actual capability.
