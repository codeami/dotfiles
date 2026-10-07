# One captain, many crews, one chart room

*How I fit Kun Chen's agent factory together with plain-file context, and how I keep the agents doing what I actually meant*

*Draft 1 · post 2 in the "everything is a file" series*

---

In the first post I argued that, in AI, everything is a file: write your goals, rules and context down once, in folders, and every tool reads the same thing. That covers what the agents *know*. It says nothing about how work actually gets *done* when several agents run at once, or how you notice when one of them quietly drifts from what you asked.

For that I use [Kun Chen](https://github.com/kunchenguid)'s open-source stack, built around a tool called [FirstMate](https://github.com/kunchenguid/firstmate). This post is about how the two halves fit together, and how I check that the agents' intent still matches mine.

## 1. Two halves: doing and knowing

| | Kun Chen's stack (doing) | Folder context, ICM-style (knowing) |
|---|---|---|
| Question it answers | Who does the work, where, and is it safe to ship? | What does every agent need to know before it starts? |
| Main pieces | FirstMate (dispatcher), treehouse (isolated copies of a repo), no-mistakes (pre-push checks), gnhf (overnight loops), AXI tools (token-cheap CLIs) | One map file (`AGENTS.md`), one folder per kind of work (`CONTEXT.md`), session notes |
| Lives in | FirstMate's own folder and each project repo | My dotfiles repo, linked into every tool |

Neither half is enough alone. Context without a crew is a well-labelled empty kitchen. A crew without shared context is a busy kitchen where every cook has a different recipe.

## 2. The ship

FirstMate leans into a nautical theme, and it's a useful picture:

```
                you (the captain)
                      │  one conversation
                      ▼
              first mate (orchestrator)
        ┌─────────────┼─────────────────┐
        ▼             ▼                 ▼
   ship crewmate   scout crewmate    secondmate
   changes code    researches        a standing team for
   → pull request  → report.md       one domain (e.g. market,
                     never a PR      product), with its own memory
```

- **You talk to one agent**, the first mate. You never juggle tabs.
- **Ships** change code. Each works in its own isolated copy of the repo, so three can run at once without stepping on each other.
- **Scouts** do research: market scans, tool comparisons, "has someone already built this?". Their output is a report file, never code. This is where the market and tech research happens. Some of my reports so far: FirstMate vs Claude's own agent features, FirstMate vs another orchestration framework, and prior art for a project before writing any code.
- **Secondmates** are longer-lived teams for one domain, each with their own memory folder. They inherit my shared preferences from the first mate.

Here's the link to the first post: every one of those roles reads the same map file at startup, through its own tool's link. Claude, Codex or Pi: same map, same rules.

## 3. Who sees how much

This is the part I find most interesting, and it's the ICM idea applied to agents instead of files.

Jake Van Clief's rule for folders is: read only what the task needs. FirstMate applies the same rule to agents. The orchestrator holds the wide view; each worker gets a narrow one.

```
first mate     the map + its own job description + your preferences
(wide)         + the work queue + the status of every crewmate
                     │
                     │  writes a launch brief
                     ▼
crewmate       the map + the project's AGENTS.md + the brief
(narrow)       + one isolated copy of one repo
```

Narrow context is cheaper and less confusing. A crewmate fixing a bug in one app doesn't need to know about your other five projects.

### Why not just use Claude's built-in subagents?

Claude Code can already spin up subagents with their own small context. FirstMate deliberately blocks that tool in its orchestrator, for a concrete reason it learned the hard way: in one recorded incident, the orchestrator ran four workers as built-in subagents instead of real crewmates. The work was invisible to the fleet view, two workers died when the main session restarted, and the work was lost.

| | Built-in subagent | FirstMate crewmate |
|---|---|---|
| Runs | inside the main session | as its own session, in its own visible window |
| If the main session restarts | it dies | it keeps going |
| Leaves a record | no | a brief, a status file, a report or a pull request |
| Can be a different model or vendor | no (same harness) | yes: Claude, Codex, Pi, others |
| Best for | quick lookups inside one task | any real piece of work |

Rule of thumb: a subagent is a quick question to a colleague at the next desk; a crewmate is a job ticket with a name on it.

### The catch: intent passes through a middleman

A crewmate's "user" isn't you. It's the first mate. Your intent reaches the crew only through the launch brief. That's the old telephone game: every hand-off is a chance for "keep it under ₹50k" to become "keep it cheap".

The good news is that the brief is a file (`data/<task>/brief.md`), so you can read exactly what was handed on. That matters for section 5.

## 4. Everything FirstMate knows is a file too

The two halves fit because both are built from plain files:

| What | File |
|---|---|
| The first mate's job description | FirstMate's `AGENTS.md` |
| A crewmate's job description | the launch brief |
| Your preferences, in your own words, dated | `data/captain.md`, `data/captain-shared.md` |
| Operational lessons | `data/learnings.md` |
| The work queue | `data/backlog.md` |
| Each crewmate's status and steering messages | small files in `state/` |
| Research results | `data/<task>/report.md` |
| Rules every agent shares | the map, `home/AGENTS.md`, linked into every tool |
| How each kind of work is done | `~/context/areas/<room>/CONTEXT.md` |

So a crash or restart costs nothing: the next session reads the files and carries on. You can grep it, diff it, and (for the public parts) keep its history in git.

One deliberate split: the map lives in a public repo, so it holds only rules. My personal preferences and priorities live in FirstMate's private `data/` folder, and the map just points to them.

## 5. Keeping the model's intent aligned with mine

This is the question underneath all of it: did the agent do what I *meant*, not just what it heard?

No single tool answers that. Four checks at four time scales do:

```
before work     the brief          read what the first mate handed on
before push     no-mistakes        review, tests, docs, lint, then a PR
end of a block  /stow              file what I said, in my words, dated
over weeks      backpass           repeated corrections → proposed rules → I approve
```

The last two are the ones people mix up, so here they are side by side, along with the missing piece:

| | `/stow` (FirstMate) | backpass (Kun Chen) | drift (idea, not built) |
|---|---|---|---|
| Question | What did the captain tell us that we must not forget? | Which rules are missing or causing harm, across all tools? | Where did the model go its own way in this conversation? |
| Reads | the current session | session logs from Claude, Codex, Pi, OpenCode and others | one conversation |
| Writes | preferences and lessons, with expiry dates | proposed edits to `AGENTS.md` files | a list of divergences |
| Evidence bar | your own words | exact quotes from at least two sessions | the quote where it diverged |
| Review | you can read the files any time | you approve each edit, card by card | morning skim |
| Status for me | works; I run it by hand | installed; not yet working for my Claude/Codex logins | queued as a design question inside FirstMate |

**Should they be one tool?** I don't think so, and FirstMate's own research agrees. They hold different kinds of thing with different authority:

- `/stow` stores **your words**. Most of it never expires: preferences don't go stale just because you haven't repeated them.
- backpass edits **rules**, and only with quoted evidence and your sign-off.
- A divergence log is **the model's mistakes**. It's evidence, not instruction.

Merge them into one store and a model's guess could end up with the authority of something you said. So they stay separate, and they meet in one place: the morning review, where I see the rule proposals and skim the notes.

The "drift" idea comes from Kay Kumar's research tool Substrate, from Jake Van Clief's video. It maps what the user meant and what the model decided as two graphs, then lists the gaps. In this setup the cheapest version is already in the end-of-session notes: one heading, "where the AI went its own way". If that turns out not to be enough, a proper extractor becomes a scout job for FirstMate rather than another tool for me to maintain.

## 6. Where Matt Pocock's skills fit

Not everyone needs a fleet. Matt Pocock's [skills](https://github.com/mattpocock/skills) take a different route to the same problem. Instead of orchestrating many agents, they give one agent better habits, packaged as skills you install into a repo: `npx skills@latest add mattpocock/skills`, then `/setup-matt-pocock-skills` once per repo (Claude Code can also install it as a plugin).

The core flow:

- `/grill-me`: the agent interviews you about your plan until every open question is resolved.
- `/to-spec`: turns a discussion into a tracked spec.
- `/implement`: builds one ticket with test-driven development and a code-review gate.
- `/tdd`, `/diagnosing-bugs`, `/code-review`, `/domain-modeling`.

[Version 1.3](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md) added three that land right on the themes of this post:

- `/implement-spec` builds a whole spec in one run. It treats the tickets as a task graph, runs implementer subagents in their own worktrees, and merges everything onto one integration branch. That's a small, single-repo cousin of what FirstMate does across projects.
- `/retro` looks back at a coding session and suggests changes to the agent's *environment* rather than the code: steering files, pointers, automated checks, coding standards. A mechanical mistake gets a deterministic check (a lint rule, a pre-commit hook, a CI job); only genuine judgement calls go into a standards file. That's the same job as backpass, from a different angle.
- `/pr` writes the pull-request description: the smallest diagram that explains the change, before/after evidence, and a "one-way or two-way door" call on how risky the merge is.

How it lines up with the rest:

| | Kun Chen's stack | ICM-style folders | Matt Pocock's skills |
|---|---|---|---|
| Main idea | many agents, isolated, checked before shipping | the right files in front of the agent | good engineering habits as reusable procedures |
| Unit of work | a crewmate with a brief | a room with a `CONTEXT.md` | a skill you call with `/name` |
| In the map / rooms / tools picture | the crew | the map and the rooms | the tools |
| Learning from sessions | backpass: many sessions, quoted evidence, proposes rule edits | end-of-session notes | `/retro`: one session, proposes environment changes, prefers automated checks |
| Protecting intent | brief, pre-push gate | explicit routing, "files read" | `/grill-me` before work, specs, tests first |

Three things to know before mixing them:

1. **The filename clash is gone.** Up to v1.2 his skills kept a project glossary in `CONTEXT.md`, the same name Jake uses for "how this kind of work is done". Version 1.3 renamed it to `GLOSSARY.md` (with `GLOSSARY-MAP.md` for repos with several areas). If you set up an older version, `git mv CONTEXT.md GLOSSARY.md`; the skills only look for the new name now.
2. **Subagents vs crewmates.** `/implement-spec` uses the agent's built-in subagents, which FirstMate deliberately blocks in its orchestrator (section 3). Run it inside a single crewmate's task, or on its own outside FirstMate, not from the first mate.
3. **Don't pay twice.** `/code-review` overlaps with no-mistakes, and `/retro` overlaps with backpass. They're complementary rather than identical (`/retro` is fast and per-session; backpass waits for repeats across tools), but pick deliberately per project.

The skill I'd try first is still `/grill-me`, because it attacks intent drift from the other end. backpass, `/retro` and the drift idea all notice afterwards where the model went its own way. Grilling makes the agent ask before it starts, which is the cheapest moment to catch a hard limit about to become a soft one.

## 7. The whole loop

```
you ─► first mate ─► brief ─► crewmates (ships, scouts, secondmates)
 ▲          │                        │
 │          │ /stow                  │ session logs on disk
 │          ▼                        ▼
 │   private memory           backpass ─► proposed rule edits
 │   (captain.md, learnings)        │
 │          ▲                        ▼
 │          │ read-only      you approve ─► home/AGENTS.md (the map)
 │          │                               │  linked into every tool
 └──────────┴────── next session reads ◄───┘
```

## 8. What's still rough (honestly)

- `/stow` only runs when I ask for it.
- backpass is installed but not yet working against my Claude and Codex logins, so the weekly rule loop is still manual.
- Divergence tracking is one heading in a note, not a tool.
- Chat apps (Claude.ai, Claude Desktop's chat) can't read any of these files, so I still paste context there.
- One leak to fix: when you tell Claude "remember this", it saves to its own private memory, which Codex and the other tools never see. Claude won't write through the link to the shared file. For anything that should apply everywhere, the shared map is the place, and it changes only through review.

## 9. The takeaway

Kun Chen's stack decides **who does the work and whether it's safe to ship**. Plain files decide **what every agent knows**. Small, separate reviews (the brief, the pre-push gate, `/stow`, backpass) keep **what the agents do** close to **what I meant**, and every one of them leaves a file I can read.

---

## Credits and further reading

These posts stand on other people's work:

- **Jake Van Clief**: the Interpretable Context Methodology (ICM). Read [the paper](https://arxiv.org/abs/2603.16021), watch ["You're Automating The Wrong Layer"](https://www.youtube.com/watch?v=956DPSPX4wg) and [his YouTube channel](https://www.youtube.com/@JEVanClief), and join the [Clief Notes community and course on Skool](https://www.skool.com/cliefnotes); the Foundation course is the place to start. Also [Eduba](https://eduba.io).
- **Kay Kumar**: Substrate, the research tool shown in Jake's video that maps what a user meant against what a model decided (not public yet).
- **Kun Chen**: [FirstMate](https://github.com/kunchenguid/firstmate), [backpass](https://github.com/kunchenguid/backpass), [no-mistakes](https://github.com/kunchenguid/no-mistakes), [gnhf](https://github.com/kunchenguid/gnhf), [treehouse](https://github.com/kunchenguid/treehouse), the [AXI](https://axi.md) principles, and the [dotfiles](https://github.com/kunchenguid/dotfiles) my setup is forked from. His [tools list](https://github.com/kunchenguid/kun/blob/main/TOOLS.md) is the best map of the whole stack.
- **Andrej Karpathy**: the [LLM Wiki idea file](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), a knowledge base an LLM keeps as plain markdown, and the push for ["context engineering" over "prompt engineering"](https://x.com/karpathy/status/1937902205765607626).
- **Matt Pocock**: [mattpocock/skills](https://github.com/mattpocock/skills), agent skills for real engineering work (see post 2).
- **The [AGENTS.md](https://agents.md) convention**: one instructions file that many coding agents read.
