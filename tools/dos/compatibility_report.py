#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys

def main() -> int:
    ap = argparse.ArgumentParser(description="Create a Markdown report from batch_classify JSON")
    ap.add_argument("batch_json", type=Path)
    ap.add_argument("out_md", type=Path)
    args = ap.parse_args()

    results = json.loads(args.batch_json.read_text(encoding="utf-8"))
    lines = ["# VIS DOS Compatibility Report", ""]
    lines.append("| Risk | Format | File | Finding count |")
    lines.append("|---|---|---|---|")
    for r in results:
        lines.append(f"| {r['risk_rating']} | {r['format']} | `{r['path']}` | {len(r['findings'])} |")
    lines.append("")
    for r in results:
        lines.append(f"## {r['path']}")
        lines.append("")
        lines.append(f"- Format: {r['format']}")
        lines.append(f"- Risk: {r['risk_rating']}")
        for f in r["findings"]:
            lines.append(f"  - **{f['risk']}**: {f['detail']} x{f['count']}")
        if r.get("interesting_strings"):
            lines.append("- Interesting strings:")
            for s in r["interesting_strings"][:10]:
                lines.append(f"  - `{s}`")
        lines.append("")
    args.out_md.parent.mkdir(parents=True, exist_ok=True)
    args.out_md.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {args.out_md}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
