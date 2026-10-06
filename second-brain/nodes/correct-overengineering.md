---
tags: [method]
links: [right-size-the-model, validate-dont-review]
source: Kun Chen, "Full Stack App" video (E2E integration + backend review)
---

# Correct overengineering

Claim: Models tend to overengineer (extra environments, audit events, encrypted export); the human's job is to prune scope to the minimal MVP.

Evidence: "GPT models, especially the 5.6, has this tendency to overengineer... I don't think we need different environments right now. I think we just need one production environment."

Elaboration:
- Kun deletes audit events and encrypted export from the plan: "keep the initial scope minimal."
- The backend review is explicitly a hunt for overengineering; it found none ("nothing overengineered").
- Overengineering is a predictable bias, so plan for a pruning pass, not just a review pass.
- Eval: evals/mvp-scope.sh enforces this (no env tiers, no audit-events table).
