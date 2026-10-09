"""Mutation run on the checker itself: break bin/plain-check one way at a time; tests/plain.sh must go red.

    python3 -I tests/mutate-plain.py

A mutation the tests do not notice means a test is missing. Works on a temporary copy of bin/; changes nothing.
"""
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

CTX = Path(__file__).resolve().parent.parent
MUTATIONS = [
    ("R1 limit 25 becomes 26", "MAX_WORDS, MAX_STEP, MAX_SENTENCES, SOFT_PER_100 = 25,", "MAX_WORDS, MAX_STEP, MAX_SENTENCES, SOFT_PER_100 = 26,"),
    ("R1 limit 25 becomes 24", "MAX_WORDS, MAX_STEP, MAX_SENTENCES, SOFT_PER_100 = 25,", "MAX_WORDS, MAX_STEP, MAX_SENTENCES, SOFT_PER_100 = 24,"),
    ("R1 uses >= for the word limit", "if n > MAX_WORDS:", "if n >= MAX_WORDS:"),
    ("R1 step limit 20 becomes 21", "25, 20, 6, 2", "25, 21, 6, 2"),
    ("R1 step limit 20 becomes 19", "25, 20, 6, 2", "25, 19, 6, 2"),
    ("R1 never checks steps", 'elif kind == "step" and n > MAX_STEP:', "elif False:"),
    ("R1 makes a long step soft", 'f"sentence has {n} words (maximum {MAX_WORDS})", True)', 'f"sentence has {n} words (maximum {MAX_WORDS})", False)'),
    ("R1 makes a long step hard", 'f"step has {n} words (maximum {MAX_STEP})", False)', 'f"step has {n} words (maximum {MAX_STEP})", True)'),
    ("R2 never sees a semicolon", 'for m in re.finditer(";", s):', 'for m in re.finditer("zzzz", s):'),
    ("R2 reports a semicolon as soft", '"semicolon: split into two sentences", True)', '"semicolon: split into two sentences", False)'),
    ("R3 limit 6 becomes 7", "25, 20, 6, 2", "25, 20, 7, 2"),
    ("R3 limit 6 becomes 5", "25, 20, 6, 2", "25, 20, 5, 2"),
    ("R3 applies to every block", 'if kind == "para" and len(sents)', "if len(sents)"),
    ("R3 never fires", 'if kind == "para" and len(sents) > MAX_SENTENCES:', "if False:"),
    ("R4 never fires", "for rx, plain in PLAIN:", "for rx, plain in []:"),
    ("R4 is soft", 'f"\'{m.group(0)}\': use \'{plain}\'", True)', 'f"\'{m.group(0)}\': use \'{plain}\'", False)'),
    ("R4 forgets 'prior to'", '(stems("prior to"), "before"), ', ""),
    ("R4 forgets 'in order to'", '(stems("in order to"), "to"),', ""),
    ("R4 flags 'approximately' (approved in the official FAQ)", '(stems("regarding"), "about")]', '(stems("regarding"), "about"), (stems("approximately"), "about")]'),
    ("R4 flags 'around' (approved in the official FAQ)", '(stems("regarding"), "about")]', '(stems("regarding"), "about"), (stems("around"), "about")]'),
    ("R5 never fires", "for m in PASSIVE.finditer(s):", "for m in []:"),
    ("R5 forgets 'be' (modal plus be)", r'(?:is|are|was|were|be|been|being)\s+(?:not', r'(?:is|are|was|were|been|being)\s+(?:not'),
    ("R5 forgets irregular participles", r'(?:\w{3,}ed|" + PARTICIPLES + r")\b', r'(?:\w{3,}ed)\b'),
    ("R5 is hard", ': name who acts", False)', ': name who acts", True)'),
    ("R6 never fires", "for m in PROGRESSIVE.finditer(s):", "for m in []:"),
    ("R6 ignores the not-ing list", "if m.group(1).lower() not in NOT_ING:", "if True:"),
    ("R6 forgets 'were'", r"(?:is|are|was|were|am)\s+(?:not\s+)?(\w+ing)", r"(?:is|are|was|am)\s+(?:not\s+)?(\w+ing)"),
    ("R7 never fires", "for m in PHRASAL.finditer(s):", "for m in []:"),
    ("R7 forgets 'wrap up'", r'r"wrap(?:s|ped|ping)? up", ', ""),
    ("R8 never fires", "if len(seen) > 1:", "if False:"),
    ("R8 fires on a single word", "if len(seen) > 1:", "if len(seen) > 0:"),
    ("R8 reports every member", "found.append((seen[order[1]]", "[found.append((seen[o], 'R8', 'x', False)) for o in order]; found.append((seen[order[1]]"),
    ("R8 drops the show/display group", '("show", "display"), ', ""),
    ("R9 never fires", "for m in re.finditer(ABBREV, s.replace", "for m in re.finditer('zzzz', s.replace"),
    ("R9 forgets etc.", "i\\.e\\.|etc\\.|et al", "i\\.e\\.|et al"),
    ("the sentence split ignores abbreviations", "text = re.sub(ABBREV, lambda", "text = re.sub('zzzz', lambda"),
    ("masking: double quotes are not masked", r'(r"\"[^\"\n]*\"|“[^”\n]*”", " "),', r'(r"zzzz", " "),'),
    ("masking: inline code is not masked", '(r"`[^`\\n]*`", " CODE "),', '(r"zzzz", " CODE "),'),
    ("masking: code counts as zero words", '(r"`[^`\\n]*`", " CODE "),', '(r"`[^`\\n]*`", " "),'),
    ("masking: URLs are not masked", '(r"https?://\\S+", " "),', '(r"zzzz", " "),'),
    ("masking: grade tags are not masked", '(r"\\[(?:S|3P|J|\\?)\\]", " "),', '(r"zzzz", " "),'),
    ("masking: paths are not masked", '(r"(?<![\\w/])(?:~|\\.{1,2})?/[\\w.\\-~]+(?:/[\\w.\\-~]*)*", " "),', '(r"zzzz", " "),'),
    ("masking: quote lines are not masked", 'if off or s.startswith(("<!-- ste:", "> ", ">")):', 'if off or s.startswith(("<!-- ste:",)):'),
    ("masking: table rows are not masked", 's.startswith("|") or ', ""),
    ("masking: fences are not masked", "        elif fence:\n", "        elif False:\n"),
    ("masking: a fence never closes", "fence = None if s.startswith(fence) else fence", "fence = fence"),
    ("masking: ste:off is ignored", 'if "<!-- ste:off -->" in s:\n            off = True', 'if "<!-- ste:off -->" in s:\n            off = False'),
    ("masking: ste:on never resumes", 'elif "<!-- ste:on -->" in s:\n            off = False', 'elif "<!-- ste:on -->" in s:\n            off = True'),
    ("lines: a wrapped sentence reports its first line", "at = lambda m: line_at(off + m.start())", "at = lambda m: ln"),
    ("lines: every finding is on the first line of its block", "return [n for o, n in starts if o <= off][-1]", "return starts[0][1]"),
    ("pass test: soft limit 2 becomes 3 per 100", "25, 20, 6, 2", "25, 20, 6, 3"),
    ("pass test: soft limit 2 becomes 1 per 100", "25, 20, 6, 2", "25, 20, 6, 1"),
    ("pass test: soft findings never fail", "good = hard == 0 and soft * 100 <= SOFT_PER_100 * words", "good = hard == 0"),
    ("pass test: hard findings never fail", "good = hard == 0 and soft * 100 <= SOFT_PER_100 * words", "good = soft * 100 <= SOFT_PER_100 * words"),
    ("pass test: strict less-than for soft", "soft * 100 <= SOFT_PER_100 * words", "soft * 100 < SOFT_PER_100 * words"),
    ("guard: the blog guard never fires", "if blog_path(path) and not force:", "if False:"),
    ("guard: --force is ignored", 'force = "--force" in argv', "force = False"),
    ("guard: the match is a substring (areas/blogger)", 'any(a == "areas" and b == "blog" for a, b in zip(parts, parts[1:]))', 'any("blog" in b for b in parts)'),
    ("guard: symlinks are not resolved", "os.path.realpath(path)", "os.path.abspath(path)"),
    ("guard: a refusal exits 0", "            status = 2\n            continue\n        try:", "            continue\n        try:"),
    ("guard: an unreadable file exits 0", '            print(f"plain-check: cannot read {path}: {e}", file=sys.stderr)\n            status = 2', '            print(f"plain-check: cannot read {path}: {e}", file=sys.stderr)\n            status = 0'),
    ("guard: no arguments exits 0", '        print("usage: plain-check [--force] FILE...", file=sys.stderr)\n        return 2', '        print("usage: plain-check [--force] FILE...", file=sys.stderr)\n        return 0'),
    ("exit: a failing file does not set the status", "if not good and status == 0:", "if False:"),
    ("exit: a later failure hides a refusal", "if not good and status == 0:", "if not good:"),
]


def suite(bin_dir: Path) -> int:
    env = dict(os.environ, PLAIN_CHECK=str(bin_dir / "plain-check"))
    return subprocess.run(["bash", str(CTX / "tests" / "plain.sh")], capture_output=True, text=True, env=env).returncode


def main() -> int:
    if suite(CTX / "bin") != 0:
        print("BROKEN  the unmutated suite is not green, so no mutation result would mean anything")
        return 2
    survived = []
    for name, old, new in MUTATIONS:
        with tempfile.TemporaryDirectory() as t:
            bin_dir = Path(t) / "bin"
            shutil.copytree(CTX / "bin", bin_dir)
            src = (bin_dir / "plain-check").read_text()
            if src.count(old) < 1:
                print(f"BROKEN  {name}: mutation target not found")
                return 2
            (bin_dir / "plain-check").write_text(src.replace(old, new, 1))
            killed = suite(bin_dir) != 0
        print(f"{'killed  ' if killed else 'SURVIVED'} {name}")
        if not killed:
            survived.append(name)
    total = len(MUTATIONS)
    print(f"\n{total - len(survived)} of {total} mutations killed ({100 * (total - len(survived)) // total}%); survived: {survived or 'none'}")
    return 1 if survived else 0


if __name__ == "__main__":
    sys.exit(main())
