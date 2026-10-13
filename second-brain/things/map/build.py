#!/usr/bin/env python3
"""Build second-brain/things/map/data.json from the thing cards and stubs.json.

Also rewrites the inline copy of the data in index.html, so the page opens
by double-click with no server. Standard library only. Output is deterministic.

Usage: build.py [--out DATA_JSON] [--html INDEX_HTML]
"""
import argparse
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
THINGS = HERE.parent
SLOTS = ["who", "what", "when", "where", "why", "how"]
SOURCE = {"S": "source-backed", "M": "model-drafted", "C": "captain"}
SLOT_RE = re.compile(r"^- (\w+): (?:\[([SMC])\] ?)?(.*)$")
MARKER = re.compile(r'(<script id="map-data" type="application/json">)(.*?)(</script>)', re.S)


def front_matter(text):
    head = text.split("---", 2)[1]
    out = {}
    for line in head.strip().splitlines():
        key, _, value = line.partition(":")
        out[key.strip()] = value.strip()
    return out


def block(text, name):
    """Lines of '## NAME' up to the next '## ' heading."""
    lines, on = [], False
    for line in text.splitlines():
        if line == "## " + name:
            on = True
        elif line.startswith("## "):
            on = False
        elif on:
            lines.append(line)
    return lines


def slots(lines):
    out = {}
    for line in lines:
        m = SLOT_RE.match(line)
        if m and m.group(1) in SLOTS:
            tag = m.group(2)
            out[m.group(1)] = {"text": m.group(3).strip(),
                               "source": SOURCE.get(tag, "unknown")}
    return out


def links_section(text):
    """Lines under '### Links' as {label: text}."""
    out, on = {}, False
    for line in text.splitlines():
        if line.startswith("### "):
            on = line == "### Links"
        elif on and line.startswith("- ") and ":" in line:
            label, _, value = line[2:].partition(":")
            out[label.strip()] = value.strip()
    return out


def read_card(path):
    text = path.read_text(encoding="utf-8")
    fm = front_matter(text)
    links = [s.strip() for s in fm.get("links", "").strip("[]").split(",") if s.strip()]
    facts = {}
    for line in text.splitlines():
        m = re.match(r"^- (licence|last activity|stars): (.*)$", line)
        if m:
            facts[m.group(1)] = m.group(2).strip()
    name = next((l[2:].strip() for l in text.splitlines() if l.startswith("# ")), fm["thing"])
    return {
        "id": fm["thing"], "name": name, "kind": fm.get("kind", "unknown"),
        "stub": False, "url": "unknown",
        "product": slots(block(text, "PRODUCT")),
        "tech": slots(block(text, "TECH")),
        "facts": facts, "_links": links, "_section": links_section(text),
    }


def short(text, limit=140):
    text = re.sub(r"\s+", " ", text).strip()
    return text if len(text) <= limit else text[: limit - 1].rstrip() + "…"


def build_edges(cards):
    ids = {c["id"] for c in cards}
    pairs = {}
    for c in cards:
        targets = list(c["_links"])
        for value in c["_section"].values():
            targets += [i for i in ids if i != c["id"] and re.search(r"\b" + re.escape(i) + r"\b", value)]
        for t in targets:
            if t == c["id"]:
                continue
            why = ""
            for label, value in c["_section"].items():
                m = re.search(r"\b" + re.escape(t) + r"\b(?: \(([^)]*)\))?", value)
                if m:
                    why = "%s %s %s" % (c["id"], label, t) + (": " + m.group(1) if m.group(1) else "")
                    break
            key = tuple(sorted((c["id"], t)))
            if key not in pairs or (why and not pairs[key]):
                pairs[key] = why or "listed in links: of the %s card" % c["id"]
    return [{"source": "card", "from": a, "to": b, "votes": 0, "why": short(w)}
            for (a, b), w in sorted(pairs.items())]


def stub_node(s):
    return {"id": s["id"], "name": s["name"], "kind": s["kind"], "stub": True,
            "url": s["url"], "note": "card not written yet", "line": s["line"],
            "facts": {"licence": s["licence"], "last activity": s["last_push"], "stars": s["stars"]}}


def build():
    cards = [read_card(p) for p in sorted(THINGS.glob("*.md")) if p.name != "_template.md"]
    stubs = json.loads((HERE / "stubs.json").read_text(encoding="utf-8"))
    edges = build_edges(cards)
    nodes = [{k: v for k, v in c.items() if not k.startswith("_")} for c in cards]
    nodes += [stub_node(s) for s in stubs]
    nodes.sort(key=lambda n: n["id"])
    return {"nodes": nodes, "edges": edges}


def dump(data):
    return json.dumps(data, indent=1, sort_keys=True, ensure_ascii=False) + "\n"


def inline(data):
    # '</' would end the script block early; '\/' is the same string in JSON.
    return json.dumps(data, sort_keys=True, ensure_ascii=True, separators=(",", ":")).replace("</", "<\\/")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(HERE / "data.json"))
    ap.add_argument("--html", default=str(HERE / "index.html"))
    args = ap.parse_args()
    data = build()
    Path(args.out).write_text(dump(data), encoding="utf-8")
    html_path = Path(args.html)
    if html_path.exists():
        html = html_path.read_text(encoding="utf-8")
        if not MARKER.search(html):
            raise SystemExit("index.html has no map-data script block")
        html = MARKER.sub(lambda m: m.group(1) + inline(data) + m.group(3), html, count=1)
        html_path.write_text(html, encoding="utf-8")
    print("nodes: %d, edges: %d" % (len(data["nodes"]), len(data["edges"])))


if __name__ == "__main__":
    main()
