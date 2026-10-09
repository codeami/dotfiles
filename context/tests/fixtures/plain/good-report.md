`--intent` may carry only your words. Firstmate-authored constraints are specification, not captain intent (`bin/fm-dod-lib.sh:275`). So "spec versus diff" cannot work if you put A1..An into `--intent`. It does not need to.

`no-mistakes` already gives `--intent` to its review step. The step uses it to tell a deliberate decision from a mistake (SKILL.md:121-137). It also parks a finding that challenges your deliberate intent as an `ask-user` call for you (SKILL.md:180). The skill does not say if the review also flags work that nobody asked for, or an intent line that stays undelivered [?].

So the chain improves the input to that reviewer: verbatim, approved intent. It adds a short "asked versus delivered" read at 06. It adds no second reviewer. AGENTS.md section 7 says the same: do not stack manual reviews. [S]
