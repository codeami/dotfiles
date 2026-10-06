---
tags: [agentic-stack]
links: [first-mate, worktree-pooling]
source: Kun Chen, "Full Stack App" video (Herdr + Firstmate)
---

# Herdr understands agents

Claim: A session manager that understands agents (side panel, search, keybinds) beats a terminal multiplexer that only understands panes and shells.

Evidence: "the biggest benefits of herder is that it understands agents... traditional terminal multiplexers don't really understand agents. They only understand terminals and panes and shells."

Elaboration:
- Herdr shows every agent, its directory, and which harness it runs; a keybind brings up agent search.
- This matters when the crew is large — you can jump to the session you need instantly.
- tmux persists terminals; herdr persists the agent sessions themselves.
