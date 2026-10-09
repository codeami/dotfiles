#!/usr/bin/env python3
"""Read-only link check for second-brain nodes.

Reads nodes/*.md, parses the `links:` front matter, and reports
  - links to nodes that do not exist
  - nodes that no other node links to (orphans)
Findings print as `file:line message`. Exit 0 when clean, 1 on findings,
2 when the nodes directory is missing.

Usage: check_links.py [nodes_dir]
"""
import re
import sys
from pathlib import Path

DEFAULT_DIR = Path(__file__).resolve().parent.parent / "nodes"


def clean(item):
    return item.strip().strip("\"'").removeprefix("[[").removesuffix("]]").strip()


def parse_links(lines):
    """Return (links_line_number or 1, [(line_number, slug)]) from front matter."""
    if not lines or lines[0].strip() != "---":
        return 1, []
    found, start, in_list = [], 1, False
    for i, line in enumerate(lines[1:], start=2):
        if line.strip() == "---":
            break
        m = re.match(r"links:\s*(.*)$", line)
        if m:
            start, in_list = i, m.group(1).strip() == ""
            inline = m.group(1).strip()
            if inline.startswith("[") and "]" in inline:
                body = inline[1 : inline.rindex("]")]
                found += [(i, clean(p)) for p in body.split(",") if clean(p)]
            continue
        if in_list:
            item = re.match(r"\s+-\s*(.+)$", line)
            if item and clean(item.group(1)):
                found.append((i, clean(item.group(1))))
            elif line.strip():
                in_list = False
    return start, found


def check(nodes_dir):
    files = sorted(nodes_dir.glob("*.md"))
    names = {f.stem for f in files}
    inbound = set()
    findings = []
    for f in files:
        _, links = parse_links(f.read_text(encoding="utf-8").splitlines())
        for lineno, slug in links:
            if slug not in names:
                findings.append((f.name, lineno, f"link to missing node '{slug}'"))
            elif slug != f.stem:
                inbound.add(slug)
    for f in files:
        if f.stem not in inbound:
            findings.append((f.name, 1, "orphan: no other node links to it"))
    return sorted(findings)


def main(argv):
    nodes_dir = Path(argv[1]) if len(argv) > 1 else DEFAULT_DIR
    if not nodes_dir.is_dir():
        print(f"{nodes_dir}:0 nodes directory not found")
        return 2
    findings = check(nodes_dir)
    for name, lineno, msg in findings:
        print(f"{name}:{lineno}: {msg}")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
