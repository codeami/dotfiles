---
tags: [workflow]
links: [agent-ergonomics, first-mate]
source: Kun Chen, "Full Stack App" video (browser automation)
---

# Browser automation

Claim: Let the agent drive your existing browser (with remote debugging on and per-session permission) to do click-through tasks with your credentials.

Evidence: "you can actually use Chrome DevTools Axi to control my browser window... this needs to be turned on before the agent can control your existing browser window or otherwise the agent will be running an isolated browser window which may not have your credentials."

Elaboration:
- chrome-devtools-axi drives the real signed-in browser, so Apple Store Connect steps happen unattended.
- Remote debugging must be on, and each new agent session asks permission before controlling the browser.
- This is AXI applied to a browser: agent-ergonomic, permission-gated, credentials-preserving.
