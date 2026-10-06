# Capture: Kun builds a full-stack app (L8, Eddie's Wallet)

Source: Kun Chen, "L8 Principal Building a Full Stack App with Agentic Engineering" (YouTube, 285k views, 2026-07-27), transcript + chapters provided 2026-09-22
Captured by: DSH agent
Note: STT cleaned (Herder→Herdr, T-max→tmux, superbase→Supabase, atomic vault→Atomic Vault, Hner→Hetzner, cloud design→Claude design, Sonet→Sonnet).

## Chapters (timestamp anchors)

- 00:00 Intro
- 00:26 Herdr + Firstmate
- 03:40 /calm
- 05:41 Product ideation
- 11:28 Crew mates
- 13:17 Fast mode
- 16:53 Market research
- 19:06 Technical research
- 23:43 Parallelize
- 29:56 Interactive planning
- 42:29 UX prototypes
- 48:08 Compaction
- 55:36 Claude design
- 59:41 Secret management
- 01:06:11 Design system
- 01:13:52 Building the frontend
- 01:18:08 Browser automation
- 01:20:33 E2E integration
- 01:33:46 Backend architecture review
- 01:37:55 It works!

## Signal (the claims worth keeping)

1. Herdr understands agents (side panel, search, keybinds) where tmux only understands panes.
2. /calm hides tool-call noise; with capable models you only need prompt + response.
3. Kick off a project by rambling your full thinking; let the agent rationalize it into a brief.
4. Right-size the model: efficient models (Luna/Sonnet) do most work; reserve the strongest.
5. Scout in parallel: market research + technical research run simultaneously before building.
6. Compaction is an implementation detail; server-side compaction keeps long sessions coherent.
7. Gate production secrets behind an approval vault; pass tokens as env vars, never plaintext.
8. Declarative infrastructure (OpenTofu): machines and resources as auditable, committed files.
9. Design system before screens, so later components don't reinvent elements.
10. Correct overengineering: models add tiers/audit/export the MVP doesn't need; prune scope.
11. Let the agent drive your browser (chrome-devtools-axi) with remote debugging + permission.
12. The MVP gate is evidence: simulator signs in with a real account against the real backend.
