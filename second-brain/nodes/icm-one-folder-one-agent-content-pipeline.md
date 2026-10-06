---
tags: [agentic-stack, content-engine, icm]
links: [icm-three-layers-chat-skills-structure, icm-every-workflow-comes-from-dialogue]
source: Jake Van Clief, "You're Automating The Wrong Layer" (YouTube 956DPSPX4wg, 2026-05-21), 13:30–18:45
---

# ICM: a whole content pipeline from one folder and one agent

Claim: A research → script → voice → animation pipeline runs from a single folder with one agent and two or three prompts, because every reusable process (voice and tone, script pillars, audio workflow, animation placeholders) is a markdown file the agent finds by navigating the folder, not by re-injection.

Evidence: NLP Logix engagement — three product videos. CLAUDE.md gives the folder map; `voice-and-tone.md` answers "what is my voice and tone" in one prompt. Agent built research folders per product (angle, hooks, outlines), wrote scripts in his voice, generated ElevenLabs audio from his trained voice, then built animation from pre-made placeholder assets. "This entire workflow is probably four or five startups… and it's all in folders and markdown files with one agent."

Elaboration:
- A fresh session can pick up mid-pipeline to save tokens; the state is in the structure, not the context window.
- "One prompt is thousands of prompts" — same as `print("hello world")` executing thousands of lines of Python.
- Output is structured and editable at scale, not one-shot generation.

Why it matters here: direct template for Ashish's YouTube content engine and for the FirstMate market-research agent — give each an `areas/<project>/` folder with voice, pillars and asset placeholders instead of a bespoke agent.
