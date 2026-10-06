# Capture: Kun's agent engineering workflow (L8)

Source: Kun Chen, "Agent Engineering Workflow" full walkthrough (YouTube, 44:32), transcript + chapter list provided 2026-09-22
Captured by: DSH agent
Note: speech-to-text artifacts cleaned (cloud→Claude, Western→WezTerm, Nuvem→Neovim, guitar work tree→git worktree).

## Chapters (timestamp anchors)

- 00:00 How to watch this video
- 02:10 Why I work in the terminal
- 03:49 WezTerm and my lua config
- 05:09 What is tmux
- 07:18 Neovim as editor
- 09:21 Agent harnesses
- 11:24 My global memory file
- 14:50 Project level memory file
- 16:12 Using skills
- 18:40 How skills may hurt your agent
- 20:27 Voice input
- 22:12 The importance of agent ergonomics
- 24:25 Planning with interactive artifacts
- 28:29 Validating code changes
- 33:12 Long running tasks
- 36:20 Parallel worktrees and agents
- 40:23 First mate
- 44:26 The captain's mindset

## Signal (the claims worth keeping)

1. Terminal-first keeps hands on the keyboard (flow) and works everywhere, even a phone.
2. Keep the workflow agent-agnostic: the harness landscape changes too fast to lock in.
3. Global memory is minimal (27 lines) because it is loaded into every session's system prompt.
4. Project memory is collective learning: correct the agent, then ask it to store the learning.
5. Skills use progressive disclosure: a tiny description is loaded; the body only on demand.
6. Popular skills are not good skills; require rigorous evals before installing.
7. Models underestimate their own coding speed, so they bias toward cheap, low-quality solutions.
8. Start bug fixes by reproducing the bug end-to-end, not with unit tests.
9. Tool ergonomics dominate agent cost/quality: AXI beats MCP (3x tokens, 2x latency on GitHub).
10. Don't review diffs by hand — run no-mistakes, apply judgment at the PR sized by risk.
11. Long-running loops need precise caps (token / iteration / stop condition).
12. Manual git worktrees become debt; a worktree pool (treehouse) reuses idle ones.
13. The endgame is a first mate — one agent managing the crew.
14. Plan against interactive HTML artifacts (Lavish), not a wall of text.
15. Once orchestration absorbs the work, the bottleneck shifts to direction (the treasure map).
