#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys

ROOT = Path(__file__).resolve().parents[2] / "visenv" / "src"
sys.path.insert(0, str(ROOT))
from control_tat import parse_control_tat

def main() -> int:
    ap = argparse.ArgumentParser(description="Minimal VIS CONTROL.TAT parser")
    ap.add_argument("path", type=Path)
    ap.add_argument("--json", type=Path, default=None)
    args = ap.parse_args()
    info = parse_control_tat(args.path)
    print(json.dumps(info.to_dict(), indent=2))
    if args.json:
        args.json.write_text(json.dumps(info.to_dict(), indent=2), encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
