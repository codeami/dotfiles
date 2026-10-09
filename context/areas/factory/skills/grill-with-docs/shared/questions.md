# Intent questions: one ordered set to find true intent

`/grill-with-docs` asks from this set. `taste-check ask` uses the same ids to say which are still open.
Ask only what the ask has not already answered. A round is at most 5 questions.

## Rules (each from a named source)

- R1 Look up before you ask. Facts come from files, code, history, the web; only decisions are his. (Matt Pocock `grilling`; HumanLayer `create_plan`: "Only ask questions that you genuinely cannot answer through code investigation.")
- R2 Before asking, read his past approved intents and decisions for what he already showed. (Kun `vision`: "Evidence over vibes.")
- R3 Every question carries a recommended answer, worded so "yes" accepts it. (Matt `grilling`.)
- R4 Replace a question whose answer you can predict. For a fork, give the case for each side. (Kun `vision`: "No softball hypotheticals.")
- R5 A question that depends on an open one waits for the next round. (Matt: the frontier.)
- R6 His words, not yours, go on the I line. What you add is an assumption. (Kun: "never fold in a principle they did not state".)
- R7 Nothing is approved while a `blocking:` question is open. (HumanLayer: "No Open Questions in Final Plan".)

## The set (in this order)

Why and for whom
- Q1 [purpose] This exists so that ___. What happens if it does not exist? (Kun: "exists so that"; HumanLayer: "Ask why")
- Q2 [audience] Who is it for, what do they know already, and what do they do right after? (Matt `to-questionnaire`: recipient's role and expertise; Jake `setup`: who is it for; Jake `build`: who else touches it)
- Q3 [one-job] It owns exactly one thing. What? (Kun: "owns exactly one thing"; ICM: one stage, one job)

What done looks like
- Q4 [done] How will you know it works? What would you check in one minute? (Jake `build`: what does done look like; Jake `setup`: what the human always checks; Matt `to-spec`: test external behaviour)
- Q5 [example] Show one example that is right and one that is wrong. (Jake `setup`: two right, one wrong; Substrate: an example of the goal)
- Q6 [flow] Walk me through one use, start to finish. Where do you stop and check? (Jake `build`)

Edges
- Q7 [non-goal] What is it not? Name things a sensible person would add that you do not want. (Kun: non-goals named concretely; tempting-but-off-mission features)
- Q8 [constraint] Which limits never bend (money, time, privacy, tools, platform)? If two collide, which gives way first? (Jake `setup`: hard constraints; Travel Agent `constraints.md`: yield order)
- Q9 [collision] When A and B pull apart (simple or capable, safe or fast, cheap or good), which wins here? (Kun: principle collisions, both sides steelmanned)
- Q10 [growth] Next month someone asks for ___, the natural next step. Yes, later or no? (Kun: slippery slopes, scope expansions)

Words and stakes
- Q11 [term] You said "___". Do you mean A or B? (Matt `domain-modeling`: challenge against the glossary, sharpen fuzzy words)
- Q12 [case] Take this case: ___. What should happen? (Matt `domain-modeling`: concrete scenarios; Kun: fault-line hypotheticals)
- Q13 [undo] Which choice here would cost most to undo? Why this way and not the other? (Matt ADR gates: hard to reverse, surprising, a real trade-off)
- Q14 [assume] What am I assuming that you have not said? What should I verify, not trust? (Substrate: assumptions; HumanLayer: "Note assumptions that need verification"; Matt: nothing left silently assumed)

Close
- Q15 [readback] Here is what I heard, in your words: I1..In. What is missing, wrong or too strong? (Matt: confirm a shared understanding before acting; HumanLayer: "aligns best with your vision"; chain: only he approves)
