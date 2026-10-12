#!/usr/bin/env python3
"""Baseline retrieval scorer for the second-brain golden questions.

No model, no network. For each question in golden/questions.tsv it ranks the
nodes (hub notes, `type: hub`, are skipped) by keyword overlap (IDF-weighted; tags, slug and claim count more than
body text), takes the top K, and prints per-category
  Recall@K  - mean share of the expected nodes found in the top K
  Hit@K     - share of questions with at least one expected node in the top K
  abstain   - for no-answer questions: share where the top score is below the
              threshold (higher is better); for the answerable ones this runner
              also lists how many wrongly abstained.
Questions whose store is `fixture:<name>` rank over the real nodes with the
nodes in <fixtures>/<name>/nodes/ laid over them, and the fixture node's
Positions are checked: the newest-dated position is current and every older
one is marked superseded.

Usage: golden.py [--nodes DIR] [--questions TSV] [--fixtures DIR] [--k 5] [--threshold 6.0]
"""
import argparse
import csv
import math
import re
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
STOP = set(
    "a an and are as at be by do does for from how i if in is it its of on or "
    "so than that the their them then there these they this to us was what when "
    "where which who whom why will with you your can should must not no nor me my "
    "we our about into over under between each both any all more most other such".split()
)
W_TAG, W_SLUG, W_CLAIM, W_BODY = 3.0, 2.0, 2.0, 1.0


def terms(text):
    out = []
    for t in re.findall(r"[a-z0-9]+", text.lower()):
        if t in STOP:
            continue
        if len(t) > 3 and t.endswith("s") and not t.endswith("ss"):
            t = t[:-1]
        out.append(t)
    return out


def load_node(path):
    text = path.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    front, body = (parts[1], parts[2]) if text.startswith("---") and len(parts) == 3 else ("", text)
    tags = re.search(r"^tags:\s*\[(.*?)\]", front, re.M)
    claim = re.search(r"^Claim:\s*(.*)$", body, re.M)
    return {
        "hub": bool(re.search(r"^type:\s*hub\s*$", front, re.M)),
        "tags": set(terms(tags.group(1).replace(",", " "))) if tags else set(),
        "slug": set(terms(path.stem.replace("-", " "))),
        "claim": set(terms(claim.group(1))) if claim else set(),
        "body": set(terms(body)),
        "text": text,
    }


def load_dir(d):
    return {p.stem: load_node(p) for p in sorted(d.glob("*.md"))}


def rank(nodes, question):
    nodes = {slug: n for slug, n in nodes.items() if not n["hub"]}  # hubs are reading orders, not evidence
    q = set(terms(question))
    df = defaultdict(int)
    for n in nodes.values():
        for t in n["tags"] | n["slug"] | n["claim"] | n["body"]:
            df[t] += 1
    total = len(nodes)
    scored = []
    for slug, n in nodes.items():
        s = 0.0
        for t in q:
            w = max(
                W_TAG if t in n["tags"] else 0,
                W_SLUG if t in n["slug"] else 0,
                W_CLAIM if t in n["claim"] else 0,
                W_BODY if t in n["body"] else 0,
            )
            if w:
                s += w * math.log(1 + total / df[t])
        scored.append((-s, slug))
    scored.sort()
    return [(slug, -s) for s, slug in scored]


def check_supersession(text):
    """Newest-dated position must not be marked superseded; every older one must be."""
    block = re.search(r"^Positions:\s*\n((?:- .*\n?)+)", text, re.M)
    if not block:
        return False
    rows = re.findall(r"^- (\d{4}-\d{2}-\d{2}),.*$", block.group(1), re.M)
    lines = block.group(1).strip().splitlines()
    if len(lines) < 2 or len(rows) != len(lines):
        return False
    newest = max(rows)
    for date, line in zip(rows, lines):
        marked = "superseded by" in line
        if date == newest and marked:
            return False
        if date != newest and not marked:
            return False
    return True


def fmt(v):
    return "-" if v is None else f"{v:.2f}"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("--nodes", type=Path, default=HERE / "nodes")
    ap.add_argument("--questions", type=Path, default=HERE / "golden" / "questions.tsv")
    ap.add_argument("--fixtures", type=Path, default=HERE / "golden" / "fixtures")
    ap.add_argument("--k", type=int, default=5)
    ap.add_argument("--threshold", type=float, default=6.0)
    a = ap.parse_args(argv[1:])

    if not a.nodes.is_dir() or not a.questions.is_file():
        print("nodes dir or questions file not found", file=sys.stderr)
        return 2
    real = load_dir(a.nodes)
    stats = defaultdict(lambda: {"n": 0, "recall": 0.0, "hit": 0, "abstain": 0, "false_abstain": 0})
    notes = []
    with a.questions.open(encoding="utf-8", newline="") as fh:
        for row in csv.DictReader(fh, delimiter="\t"):
            store, expected = row["store"], [e for e in row["evidence"].split(",") if e]
            nodes = real
            if store.startswith("fixture:"):
                fdir = a.fixtures / store.split(":", 1)[1] / "nodes"
                if not fdir.is_dir():
                    print(f"{row['id']}: fixture dir not found: {fdir}", file=sys.stderr)
                    return 2
                nodes = {**real, **load_dir(fdir)}
                for slug in expected:
                    ok = slug in nodes and check_supersession(nodes[slug]["text"])
                    notes.append(f"{row['id']} supersession: {'ok' if ok else 'FAIL'} ({slug})")
            ranked = rank(nodes, row["question"])
            top = ranked[: a.k]
            s = stats[row["category"]]
            s["n"] += 1
            abstained = not top or top[0][1] < a.threshold
            if not expected:
                s["abstain"] += abstained
                continue
            found = [e for e in expected if e in {slug for slug, _ in top}]
            s["recall"] += len(found) / len(expected)
            s["hit"] += bool(found)
            s["false_abstain"] += abstained
            if len(found) < len(expected):
                notes.append(f"{row['id']} missed: {','.join(sorted(set(expected) - set(found)))} (top: {top[0][0] if top else '-'})")

    print(f"{'category':<14}{'n':>3}{'recall@' + str(a.k):>10}{'hit@' + str(a.k):>8}{'abstain':>9}")
    answer_n = answer_recall = answer_hit = false_ab = 0
    for cat, s in stats.items():
        if s["abstain"] or cat == "no-answer":
            print(f"{cat:<14}{s['n']:>3}{'-':>10}{'-':>8}{fmt(s['abstain'] / s['n']):>9}")
            continue
        print(f"{cat:<14}{s['n']:>3}{fmt(s['recall'] / s['n']):>10}{fmt(s['hit'] / s['n']):>8}{'-':>9}")
        answer_n += s["n"]
        answer_recall += s["recall"]
        answer_hit += s["hit"]
        false_ab += s["false_abstain"]
    if answer_n:
        print(f"{'ALL answerable':<14}{answer_n:>3}{fmt(answer_recall / answer_n):>10}{fmt(answer_hit / answer_n):>8}{'-':>9}")
        print(f"answerable questions wrongly abstained (threshold {a.threshold}): {false_ab}")
    for line in notes:
        print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
