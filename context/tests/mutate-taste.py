"""Mutation run on the checker itself: break bin/taste-check one way at a time; tests/taste.sh must go red.

    python3 -I tests/mutate-taste.py

A mutation the tests do not notice means a test is missing. Works on a temporary copy of bin/; changes nothing.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

CTX = Path(__file__).resolve().parent.parent
MUTATIONS = [
    ("TG1 accepts any I line", 'not text.lower().startswith("context:") and norm(text).lower().rstrip(".") not in said', 'False'),
    ("TG1 checks context lines too", 'not text.lower().startswith("context:") and', ''),
    ("TG1 allows an intent with no I lines", 'if not lines:\n        out("FAIL", "TG1"', 'if False:\n        out("FAIL", "TG1"'),
    ("TG2 ignores the hash", 'elif m.group(3) != words_hash(lines):', 'elif False:'),
    ("TG2 ignores a missing approval", 'out("FAIL", "TG2", "no \'approved:\' line', 'out("WARN", "TG2", "no \'approved:\' line'),
    ("TG2 ignores a malformed approval", 'out("FAIL", "TG2", f"approved line is malformed', 'out("WARN", "TG2", f"approved line is malformed'),
    ("TG2 ignores a blocking question", 'for q in blocking_questions(intent):', 'for q in []:'),
    ("TG2 treats a date-only approval as a failure", 'out("WARN", "TG2", "approved line has a date only', 'out("FAIL", "TG2", "approved line has a date only'),
    ("seal ignores a blocking question", 'if blocking_questions(text):', 'if False:'),
    ("seal writes a wrong hash", 'line = f"approved: {today} {who} {words_hash(intent_lines(text))}', 'line = f"approved: {today} {who} 000000000000'),
    ("seal keeps the old approved line", 'if not ln.startswith("approved:")]', 'if True]'),
    ("seal writes the line at the bottom", 'p.write_text("\\n".join([line] + body) + "\\n")', 'p.write_text("\\n".join(body + [line]) + "\\n")'),
    ("seal forgets the source", ' via {source}"', '"'),
    ("TG3 never checks numbers", 'if kind in ("number", "quoted"):', 'if kind in ("quoted",):'),
    ("TG3 never checks quoted labels", 'toks += [("quoted", q.lower()) for q in pair if q]', 'pass'),
    ("TG3 never checks negations", '("negation", NEG), ', ''),
    ("TG3 never checks only-words", '("only", ONLY), ', ''),
    ("TG3 never checks bounds", '("bound", BOUND))', ')'),
    ("TG3 reads criteria that do not cite the I", 'if re.search(r"\\b" + iid + r"\\b", cite))', 'if True)'),
    ("spec skips chain-check", 'return emit(chain_check(a.run) + check_spec(intent, spec))', 'return emit(check_spec(intent, spec))'),
    ("spec drops chain-check failures", 'if ln.startswith("FAIL"):', 'if False:'),
    ("spec drops chain-check ask lines", 'elif ln.startswith("ask:"):', 'elif False:'),
    ("spec passes when chain-check is missing", 'if not CHAIN_CHECK.is_file():', 'if False:'),
    ("TG4 allows a missing row", 'if iid not in rows:', 'if False:'),
    ("TG4 allows an invented row", 'if iid not in lines:', 'if False:'),
    ("TG4 allows any outcome", 'if outcome not in OUTCOMES:', 'if False:'),
    ("TG5 accepts delivered with no evidence", 'if ptr in ("", "-"):', 'if False:'),
    ("TG5 accepts a pointer that does not resolve", 'elif why:', 'elif False:'),
    ("TG5 treats an unreachable URL as a failure", 'out("WARN", "TG5", f"{iid} evidence', 'out("FAIL", "TG5", f"{iid} evidence'),
    ("TG5 skips evidence for changed rows", 'elif outcome in ("delivered", "changed"):', 'elif outcome in ("delivered",):'),
    ("TG5 accepts a missing file", 'if not f.is_file():\n        return f"{m.group(1)} does not exist', 'if False:\n        return f"{m.group(1)} does not exist'),
    ("TG5 accepts a line past the end", 'if m.group(2) and int(m.group(3) or m.group(2)) > len(body):', 'if False:'),
    ("TG5 accepts a missing heading", 'if m.group(4) and not any(', 'if False and not any('),
    ("TG5 accepts a test nobody wrote", 'return "" if hit else', 'return "" if True else'),
    ("TG6 allows no Unrequested section", 'if not any(ln.strip() for ln in section(result, "Unrequested")):', 'if False:'),
    ("result ignores --root", 'a.root or a.run', 'a.run'),
    ("ask sees a purpose in everything", '"q1": ("purpose", r"\\bso that', '"q1": ("purpose", r".|\\bso that'),
    ("TR1 allows a question with no recommendation", 'if "Recommended:" not in q:', 'if False:'),
    ("TR1 allows no rounds", 'if not rounds:', 'if False:'),
    ("TR2 allows any round size", 'if len(qs) > 5:', 'if False:'),
    ("TR2 caps at four", 'if len(qs) > 5:', 'if len(qs) > 4:'),
    ("TR3 allows a known fact to be asked", 'if fact.strip() and fact.strip().lower() in q.split("Recommended:")[0].lower():', 'if False:'),
    ("TR4 allows no read-back", 'if complete and (not agent or "shared understanding" not in agent[-1].lower()):', 'if False:'),
    ("TR4 demands a read-back of an unfinished session", 'if complete and (not agent', 'if (not agent'),
    ("TR5 allows an untagged question", 'if not tag or tag.group(1) not in SET_LABELS:', 'if False:'),
    ("a FAIL still exits 0", "return 1 if fails else 0", "return 0"),
    ("the summary never counts problems", "fails = sum(1 for k, _, _ in bag if k == \"FAIL\")", "fails = 0"),
    ("a missing file crashes instead of failing cleanly", 'except OSError as e:', 'except ZeroDivisionError as e:'),
]


def detector_mutations() -> list:
    """For each detector in SLOTS, replace its whole pattern with one that never matches."""
    src = (CTX / "bin" / "taste-check").read_text()
    return [(f"ask never sees {label} ({q})", m.group(0), f'"{q}": ("{label}", r"zzzz"),')
            for m in re.finditer(r'"(q\d+)": \("([\w-]+)", r".*"\),', src) for q, label in [m.groups()]]


def suite(bin_dir: Path) -> int:
    env = dict(os.environ, TASTE_CHECK=str(bin_dir / "taste-check"))
    return subprocess.run(["bash", str(CTX / "tests" / "taste.sh")], capture_output=True, text=True, env=env).returncode


def main() -> int:
    if suite(CTX / "bin") != 0:
        print("BROKEN  the unmutated suite is not green, so no mutation result would mean anything")
        return 2
    survived = []
    total = len(MUTATIONS) + len(detector_mutations())
    for name, old, new in MUTATIONS + detector_mutations():
        with tempfile.TemporaryDirectory() as t:
            bin_dir = Path(t) / "bin"
            shutil.copytree(CTX / "bin", bin_dir)  # chain-check travels with the copy
            src = (bin_dir / "taste-check").read_text()
            if src.count(old) < 1:
                print(f"BROKEN  {name}: mutation target not found")
                return 2
            (bin_dir / "taste-check").write_text(src.replace(old, new, 1))
            if (bin_dir / "taste-check").read_text() == src:
                print(f"BROKEN  {name}: mutation changed nothing")
                return 2
            killed = suite(bin_dir) != 0
        print(f"{'killed  ' if killed else 'SURVIVED'} {name}")
        if not killed:
            survived.append(name)
    print(f"\n{total - len(survived)} of {total} mutations killed; survived: {survived or 'none'}")
    return 1 if survived else 0


if __name__ == "__main__":
    sys.exit(main())
