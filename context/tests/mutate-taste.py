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
    ("TG1 accepts any I line", 'not text.lower().startswith("context:") and text not in words', 'False'),
    ("TG1 checks context lines too", 'not text.lower().startswith("context:") and', ''),
    ("TG1 allows an intent with no I lines", 'if not lines:\n        out("FAIL", "TG1"', 'if False:\n        out("FAIL", "TG1"'),
    ("TG2 ignores the hash", 'elif m.group(3) != words_hash(lines):', 'elif False:'),
    ("TG2 ignores a missing approval", 'out("FAIL", "TG2", "no \'approved:\' line', 'out("WARN", "TG2", "no \'approved:\' line'),
    ("TG2 ignores a malformed approval", 'out("FAIL", "TG2", f"approved line is {why}', 'out("WARN", "TG2", f"approved line is {why}'),
    ("TG2 ignores a blocking question", 'for q in blocking_questions(intent):', 'for q in []:'),
    ("TG2 treats a date-only approval as a failure", 'out("WARN", "TG2", "approved line has a date only', 'out("FAIL", "TG2", "approved line has a date only'),
    ("seal ignores a blocking question", 'if blocking_questions(text):', 'if False:'),
    ("seal writes a wrong hash", 'line = f"approved: {today} {who} {words_hash(intent_lines(text))}', 'line = f"approved: {today} {who} 000000000000'),
    ("seal keeps the old approved line", 'if not ln.startswith("approved:")]', 'if True]'),
    ("seal writes the line at the bottom", 'f.write("\\n".join([line] + body) + "\\n")', 'f.write("\\n".join(body + [line]) + "\\n")'),
    ("seal forgets the source", ' via {source.strip()}"', '"'),
    ("TG3 never checks numbers", 'toks = [("number", n) for n in sorted(numbers(low))]', 'toks = []'),
    ("TG3 never checks quoted labels", 'toks += [("quoted", q) for rx in QUOTES for q in re.findall(rx, low)]', 'pass'),
    ("TG3 never checks negations", '("negation", NEG), ', ''),
    ("TG3 never checks only-words", '("only", ONLY), ', ''),
    ("TG3 never checks bounds", '("bound", BOUND))', ')'),
    ("TG3 reads criteria that do not cite the I", 'if re.search(r"\\b" + iid + r"\\b", cite)]', 'if True]'),
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
    ("TG5 accepts a line past the end", 'if end > len(body):', 'if False:'),
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
    ("TR4 allows no read-back", 'if complete and not (re.search(r"\\bI\\d+\\b", last) and re.search(r"shared understanding[^?]*\\?", last, re.I)):', 'if False:'),
    ("TR4 demands a read-back of an unfinished session", 'if complete and not (', 'if not ('),
    ("TR4 accepts a statement in place of a question", 're.search(r"shared understanding[^?]*\\?", last, re.I)', 're.search(r"shared understanding", last, re.I)'),
    ("TR4 accepts a question with no I lines read back", 're.search(r"\\bI\\d+\\b", last) and ', ''),
    ("TR5 allows an untagged question", 'if not tag or tag.group(1) not in SET_LABELS:', 'if False:'),
    ("a FAIL still exits 0", "return 1 if fails else 0", "return 0"),
    ("the summary never counts problems", "fails = sum(1 for k, _, _ in bag if k == \"FAIL\")", "fails = 0"),
    # 1 evidence pointers stay in the root
    ("TG5 accepts a pointer that leaves the root", 'if not inside(f, root):', 'if False:'),
    ("TG5 accepts an absolute pointer", 'if Path(m.group(1)).is_absolute():', 'if False:'),
    ("TG5 does not resolve symlinks in a pointer", 'f = (root / m.group(1)).resolve()', 'f = root / m.group(1)'),
    ("TG5 trusts a test file that is a symlink out of the root", 'and f.is_file() and inside(f.resolve(), root) and', 'and f.is_file() and'),
    # 2 seal
    ("seal follows a symlinked 01-intent.md", 'if p.is_symlink():', 'if False:'),
    ("seal writes in place instead of by rename", 'os.replace(tmp, p)', 'p.write_text(Path(tmp).read_text()); os.unlink(tmp)'),
    ("seal writes a shorter hash", 'hexdigest()[:12]', 'hexdigest()[:8]'),
    # 3 TG3 whole tokens, one criterion at a time
    ("TG3 matches numbers as substrings", 'return val in numbers(low)', 'return val in low'),
    ("TG3 matches quoted words as substrings", 'return re.search(r"(?<!\\w)" + re.escape(val) + r"(?!\\w)", low) is not None', 'return val in low'),
    ("TG3 joins the criteria that cite one I", 'if not any(carried(tok, t) for t in covering):', 'if not carried(tok, " ".join(covering)):'),
    # 4 quote kinds
    ("TG3 ignores single-quoted words", """r"(?<!\\w)'([^'\\n]+)'(?!\\w)", """, ''),
    ("TG3 takes an apostrophe for a quote", """r"(?<!\\w)'([^'\\n]+)'(?!\\w)\"""", """r"'([^'\\n]+)'\""""),
    ("TG3 tells curly quotes from straight ones", r"""return s.lower().translate(str.maketrans("’‘“”", "''\"\""))""", "return s.lower()"),
    # 5 duplicates
    ("TG1 lets a duplicate I id through", 'for iid in duplicates([i for i, _ in intent_pairs(text)]):', 'for iid in []:'),
    ("seal seals a duplicate I id", 'if twice:', 'if False:'),
    ("TG4 lets a duplicate result row through", 'for iid in twice:', 'for iid in []:'),
    # 6 approved line
    ("TG2 accepts a sealed approval with no via source", r'\s+([0-9a-f]{12})\s+via\s+(\S.*?))?', r'\s+([0-9a-f]{12})(?:\s+via\s+(\S.*?))?)?'),
    ("TG2 accepts a date that is not on the calendar", 'elif not is_date(m.group(1)):', 'elif False:'),
    ("seal accepts a date that is not on the calendar", 'if not is_date(today):', 'if False:'),
    ("seal accepts an empty source", 'if not val.strip() or LINE_BREAKS', 'if LINE_BREAKS'),
    ("seal accepts a who with a space", 'if re.search(r"\\s", who):', 'if False:'),
    # 7 newlines
    ("seal accepts a newline in --who or --source", 'or LINE_BREAKS.search(val):', ':'),
    ("seal accepts a Unicode line separator", '\\x85\\u2028\\u2029', ''),
    # 8 line pointers
    ("TG5 accepts line 0", 'if start < 1:', 'if False:'),
    ("TG5 accepts a range that ends before it starts", 'if end < start:', 'if False:'),
    # 9 bad bytes
    ("malformed UTF-8 is not a clean IO failure", 'except UnicodeDecodeError as e:', 'except ZeroDivisionError as e:'),
    # 10 TG1 compares the exact line
    ("TG1 forgives a case change", 'text not in words', 'text.lower() not in words.lower()'),
    ("TG1 forgives a full stop the words lack", 'text not in words', 'text.rstrip(".") not in words'),
    ("TG1 forgives trailing whitespace", 'text not in words', 'text.strip() not in words'),
    ("TG1 forgives doubled inner whitespace", 'text not in words', 're.sub(r"\\s+", " ", text) not in re.sub(r"\\s+", " ", words)'),
    # 12 header
    ("the header drops the seal caveat", 'detects accidental change, not deliberate edits', 'is a hash'),
    ("a missing file crashes instead of failing cleanly", 'except OSError as e:', 'except ZeroDivisionError as e:'),
    # 13 third round
    ("seal follows a symlinked run folder", 'if run.is_symlink():', 'if False:'),
    ("spec does not re-check the seal", 'tampered(intent, bag)\n    crits', 'crits'),
    ("result does not re-check the seal", 'tampered(intent, bag)\n    lines', 'lines'),
    ("an empty I line vanishes from the parse", r'[ \t]*(.*)$", ln) for ln in section(text, "Captain")', r'[ \t]*(\S.*)$", ln) for ln in section(text, "Captain")'),
    ("TG1 lets an empty I line through", 'for iid in empty_ids(text):', 'for iid in []:'),
    ("seal seals an empty I line", 'if empty_ids(text):', 'if False:'),
    ("TG3 drops the sign of a number", r'(?:(?<![\w.])[+-])?', ''),
    ("TG3 reads the hyphen of a range as a sign", r'(?:(?<![\w.])[+-])?', r'(?:[+-])?'),
    ("TG5 matches a test name as a substring", 'return re.search(r"\\b(?:it|test|describe)', 'return name in text or re.search(r"\\b(?:it|test|describe)'),
    ("TG5 accepts the start of a longer test name", ' + re.escape(name) + r"\\1", text)', ' + re.escape(name), text)'),
    ("TG4 lets a row with extra cells through", 'if len(cells) > 3:', 'if False:'),
    ("a \\| in a cell splits the row", r're.split(r"(?<!\\)\|"', r're.split(r"\|"'),
    ("TG5 accepts a hard link to a file outside the root", 'if linked_outside(f, root):', 'if False:'),
    ("a test: pointer trusts a hard link from outside", 'and not linked_outside(f.resolve(), root))', ')'),
    ("a hard link inside the root is taken for one that leaves it", 'return st.st_nlink > here', 'return st.st_nlink > 1'),
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
