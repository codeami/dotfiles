---
fixture: true
tags: [workflow]
links: [validate-dont-review]
source: FIXTURE ONLY - seeded contradiction test, not a real node
---

# FIXTURE - Long-running loops need caps (seeded contradiction)

FIXTURE: a copy of nodes/long-running-loops.md with a seeded disagreement. The real node is untouched. Never promote this file into nodes/.

Claim: Overnight loops wait 60 seconds between iterations (newer position; the 30-second figure is superseded).

Positions:
- 2026-03-01, fixture source A: loops wait a 30-second cooldown between iterations (superseded by 2026-06-01, fixture source B)
- 2026-06-01, fixture source B: loops wait a 60-second cooldown between iterations

Evidence: "give it an objective and it will keep going until it meets some stop condition... I can set a token cap or iteration cap or stop condition more precisely."
