# Agent policy

One file, three agents: `home.nix` links this as `~/.claude/CLAUDE.md`,
`~/.codex/AGENTS.md` and `~/.config/opencode/AGENTS.md`. Edit it here and all
three change.

Started fresh on 2026-09-19, replacing the policy inherited from the upstream
repo (archived at `~/archive/2026-09-19-agent-cleanup/upstream/home-AGENTS.md`).

## Working rules

- Verify before claiming. Run the command or read the file instead of assuming,
  and say how a result was checked rather than that it "should work".
- Prefer the smallest change that solves the problem, in the style of the code
  around it.
- Do not silently revert a deliberate decision a repository documents - its
  AGENTS.md, or a comment explaining why a setting is the way it is.
- Ask before anything destructive or hard to undo: deleting data, rewriting
  history, force-pushing, uninstalling packages, wiping caches.
- Never commit secrets, credentials or machine-local state.
- Report what changed, what was verified, and what is still open. Do not hide
  a gap behind a tidy summary.

Keep this file short. A long policy gets skimmed.
