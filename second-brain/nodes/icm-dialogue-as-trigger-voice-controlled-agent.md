---
tags: [agentic-stack, icm, voice, meetings]
links: [icm-every-workflow-comes-from-dialogue, kun-chen-agent-policy]
source: Jake Van Clief, "You're Automating The Wrong Layer" (YouTube 956DPSPX4wg, 2026-05-21), 18:45–26:00
---

# ICM: dialogue as the trigger — voice-controlled Claude Code in a meeting

Claim: Once context lives in folders, a conversation itself can drive the agent: several people on a call controlled one local Claude Code by voice, and the next step is keyword-triggered workflows so meetings produce actions, not notes.

Evidence: Live call (Jake, David McDermott, Kay Kumar): Kay's voice drove Jake's local Claude Code inside the Ethics Engine repo (psychometric testing of LLMs). The agent listed the 10 scales, proposed missing ones, added the Short Dark Triad (SD3, Jones & Paulhus), updated CLAUDE.md (10 → 12 instruments), and proposed a front-end subscale display. Cost: about $1.20 for roughly an hour, ElevenLabs voice via API (moving to Vox, open source).

Elaboration:
- Someone else's agent + their local context becomes usable through dialogue, without sharing the files.
- Open problems: interruption handling; keyword triggers; sharing ICMs across a 30,000-person community.
- Positioned as one open-source piece of a larger project.

Why it matters here: this is phase 4 of the shared-context design — hooks fired by dialogue rather than by session start/stop. Also a cheap demo pattern for Ashish's mobile → FirstMate remote-control goal: voice in, agent on the desktop.
