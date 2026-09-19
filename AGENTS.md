# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "zap"` in `configuration.nix` is intentional. It forces the good habit of declaring every Homebrew package in the Nix config instead of installing things ad-hoc, which keeps the machine reproducible. Do not soften it to `uninstall` or `none`. Users are warned about its effect in README.md; this note is for anyone tempted to change the setting itself.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- This machine is an Intel Mac, where Homebrew's macOS bottles are thin. Before adding anything to `brews`, check that a bottle exists for this platform: Intel tags are the bare codenames (`sonoma`, `tahoe`), `arm64_*` is Apple Silicon, `x86_64_linux` is Linux. A formula with no Intel bottle makes `brew bundle` fail on every switch - `gh`, `ffmpeg`, `node` and `herdr` are current examples. README's "Intel Macs" section has the check.
- `flake.lock` pins Nixpkgs 26.05 because that is the last release supporting `x86_64-darwin`. Do not bump it without deciding what this hardware does afterwards.
- The `startHerdr` activation hook in `home.nix` is load-bearing: launchd leaves the agent's first spawn pending when it is bootstrapped from outside the Aqua session, so without the kickstart `herdr server` is down after every rebuild.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
