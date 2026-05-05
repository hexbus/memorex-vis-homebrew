#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dos_program_classifier import classify

def main() -> int:
    ap = argparse.ArgumentParser(description="Batch classify DOS programs for VIS risk")
    ap.add_argument("folder", type=Path)
    ap.add_argument("--json", type=Path, default=None)
    args = ap.parse_args()

    exts = {".exe", ".com"}
    results = []
    for p in sorted(args.folder.rglob("*")):
        if p.is_file() and p.suffix.lower() in exts:
            results.append(classify(p))

    for r in results:
        print(f"{r['risk_rating']:18} {r['format']:18} {r['path']}")
        for f in r["findings"][:8]:
            print(f"  - {f['risk']:6} {f['detail']} x{f['count']}")

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(results, indent=2), encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
