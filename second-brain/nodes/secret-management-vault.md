---
tags: [workflow]
links: [correct-overengineering, declarative-infrastructure]
source: Kun Chen, "Full Stack App" video (secret management)
---

# Gate secrets behind a vault

Claim: Gate production secrets behind an approval flow (a vault), so you see every use and the token never reaches the agent as plaintext.

Evidence: "when the agent needs to access the secrets, I will see it and I can decide do I approve... the token is passed through as an environment variable... it won't be exposed as plain text."

Elaboration:
- Kun uses Atomic Vault (by Max Howell) with an approval dialogue per secret use.
- A plain .env file can be exfiltrated without you ever noticing; the vault makes each use visible.
- As more work is delegated, tight control of where secrets go becomes load-bearing.
