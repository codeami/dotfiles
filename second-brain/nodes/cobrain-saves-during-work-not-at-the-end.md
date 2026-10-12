---
tags: [memory, context, icm]
links: [icm-every-workflow-comes-from-dialogue, cobrain-start-session-loads-a-unit]
source: Cobrain "Tools for your AI" guide (https://cobrain.space/guides/tools, read 2026-10-12); openbot issue #1687 (https://github.com/nightly-labs/openbot/issues/1687)
---

# Cobrain: write tools are small, so saving can happen mid-work

Claim: Cobrain gives the AI small write tools (append, patch) that keep the prior version, which makes saving during work cheap. Whether Cobrain tells the AI to save mid-work or at the end is not confirmed. Treat "save during work" as a guess.

Evidence: The tools guide says of `append_file`: "This is what the AI should use to add something, rather than rewriting." `patch_file` replaces one exact text and refuses if it is missing or appears more than once. The site says "Every save keeps the one before it." The guide gives no rule on when to save. A sample prompt in the openbot issue, "Save a note in Cobrain with what we did today and what is left", points the other way (end of session).

Elaboration:
- The "save during work" rule in [[icm-every-workflow-comes-from-dialogue]] is this store's own reading, not a quoted Cobrain rule.
- Pairs with [[cobrain-start-session-loads-a-unit]].
