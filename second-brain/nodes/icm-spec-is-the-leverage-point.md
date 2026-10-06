---
tags: [icm, content-engine, production]
links: [icm-prompt-has-five-typed-slots, icm-one-folder-one-agent-content-pipeline, icm-map-rooms-tools]
source: Clief Notes Foundation 2.6 "Video as Code" (raw/jvc-course)
---

# ICM: the spec is the leverage point, and constraints make output better

Claim: In any agent-built deliverable the hard work is the spec — a markdown brief precise enough that the agent executes instead of guessing — backed by a style guide (decisions that never change) and a component registry (pieces that already work). Constraints follow an inverted U: too few gives the blank-canvas problem, the right boundary raises quality.

Evidence: "The hard work is not the AI. It is not the code. It is the spec." Ogilvy: "Give me the freedom of a tight brief." Green Eggs and Ham (50 words), Jaws (no working shark). Pipeline: spec → style guide + component registry → Claude builds one scene at a time as React → Remotion renders frames → CapCut edit. "This animation pipeline is the folder architecture applied to a specific production workflow."

Elaboration:
- Claude composes from the registry; it does not invent — separation of concerns.
- "Under an hour" is the animation only; voiceover, cuts and footage still take time, spent on the parts you want to control.
- GarageBand / Canva pattern: execution democratised, floor rises, messy period first.

Why it matters here: the YouTube content engine needs `areas/content/` with voice.md, script pillars, a style guide and an asset registry before any crewmate is pointed at it; the spec is the launch brief.
