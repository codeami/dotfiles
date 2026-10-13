---
thing: ai-news-radar
kind: app
level-modes: [product, tech]
links: [awesome-ai-news, pocketflow]
---

# ai-news-radar

Tags: [S] source-backed, [M] model-drafted, [C] captain's voice. Unknown stays `unknown`.

## PRODUCT

- who: [S] Built by LearnPrompt, for anyone who wants a daily AI news view.
- what: [S] A 24-hour AI news radar with a live web page.
- when: [S] Updates on a schedule, and the last push was today.
- where: [S] On GitHub, with a live site at news.learnprompt.pro.
- why: [S] Read the last 24 hours of AI news, or ask an agent for a daily brief. Source: its README.
- how: [S] GitHub Actions gather sources, then a web page shows them.

## TECH

- who: [S] LearnPrompt (GitHub org). README is mainly Chinese, with an English version (README.en.md).
- what: [S] Merges many sources into story lines and offers three styles of commentary. Also ships agent skills (`ai-radar`, `ai-news-radar`).
- when: [S] README says v0.9 gave a single-layer UI. A scheduled workflow (`update-news.yml`) refreshes the data.
- where: [S] Repo LearnPrompt/ai-news-radar. Live site news.learnprompt.pro, with a GitHub Pages mirror.
- why: [S] Use cases per README: ask an agent for a brief, or read the live page. You can also fork it. Then it runs your own radar with your own OPML sources and persona files. Services named: GitHub Actions, GitHub Pages, the news.learnprompt.pro site, and AgentMail. Sister sites: AI MAP and GoodCase. Source: github.com/LearnPrompt/ai-news-radar README.
- how: [S] Install the skill with `npx skills add LearnPrompt/ai-news-radar -s ai-radar -g`, then ask the agent for today's news. README claims no API keys needed. Not run by me.

### Facts
- licence: MIT (GitHub API)
- last activity: pushed 2026-10-13 (GitHub API)
- stars: 1773 (GitHub API)
- rating (7-factor rubric, data/repo-quality-factors-scout/report.md): not yet scored
- checked: 2026-10-13, gh api repos/LearnPrompt/ai-news-radar and its README

### Links
- feeds: unknown
- needs: GitHub Actions, per its README badges
- pairs-with: awesome-ai-news (listed there as "Most Active"), pocketflow (model-drafted idea, not verified)
