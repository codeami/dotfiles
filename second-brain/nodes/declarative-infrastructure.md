---
tags: [method]
links: [secret-management-vault]
source: Kun Chen, "Full Stack App" video (secret management / VPS)
---

# Declarative infrastructure

Claim: Codify infrastructure as code (OpenTofu/Terraform) so machines and resources are declared in a file you can audit and commit.

Evidence: "I typically like to use things like OpenTofu to make the infrastructure codified as code... the machine and the resources that we need are all declared in a file which we can audit and we can commit."

Elaboration:
- The VPS, backups, and deployment automation become source-controlled, not click-ops.
- This is the same instinct as the Nix dotfiles: declare, audit, commit, reproduce.
- Kun steers the infra workstream to OpenTofu with one sentence to the first mate.
