---
thing: deepwiki
kind: service
level-modes: [product, tech]
links: [ai-news-radar]
---

# DeepWiki

Tags: [S] source-backed, [M] model-drafted, [C] captain's voice. Unknown stays `unknown`.

## PRODUCT

- who: [S] Run by Cognition (makers of Devin), for anyone reading code.
- what: [S] AI-written wiki pages and answers for a GitHub repo.
- when: [S] Live now. The scout tested its MCP server on 2026-10-12.
- where: [S] Online, plus an MCP server for agents.
- why: [C] (captain: why do you want this one?)
- how: [S] Ask a question about a public repo, free and with no login.

## TECH

- who: [S] Cognition (docs.devin.ai and the Cognition blog). The self-hosted clone deepwiki-open is a different project.
- what: [S] Generates wiki pages for a repo and answers questions grounded in it. The scout says it is not authoritative. Read the source before you edit or quote.
- when: [S] MCP server page and live `tools/list` checked 2026-10-12 by deepwiki-howto-v1. Start date unknown.
- where: [S] `https://mcp.deepwiki.com/mcp` (Streamable HTTP). Public repos only.
- why: [C] (captain: write your own reason here)
- how: [S] Three tools: `read_wiki_structure`, `read_wiki_contents` and `ask_wiki_question` (the docs say `ask_question`). Claude Code setup: `claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp`. Not run by me.

### Facts
- licence: unknown (hosted service, no repo checked)
- last activity: unknown
- stars: unknown
- rating (7-factor rubric, data/repo-quality-factors-scout/report.md): not yet scored. Factors 1 to 3 do not fit a hosted service.
- checked: 2026-10-13, data/deepwiki-howto-v1/report.md and data/repo-discovery-priorart-scout/report.md

### Links
- feeds: unknown
- needs: unknown
- pairs-with: ai-news-radar (its README is mainly Chinese, and repo-discovery-priorart-scout suggests routing Chinese READMEs to DeepWiki, an unbuilt idea)
