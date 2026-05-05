#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys
ROOT = Path(__file__).resolve().parents[2] / "visenv" / "src"
sys.path.insert(0, str(ROOT))
from control_tat import parse_control_tat

def main() -> int:
    ap = argparse.ArgumentParser(description="Compare two CONTROL.TAT files at known runtime-relevant offsets")
    ap.add_argument("left", type=Path)
    ap.add_argument("right", type=Path)
    args = ap.parse_args()
    a = parse_control_tat(args.left)
    b = parse_control_tat(args.right)
    fields = ["size","registration_payload_hex","maketat_marker_preview","version_gate_bytes_hex","has_authorized_statement","possible_startup_commands"]
    print(f"Comparing {args.left} and {args.right}")
    for f in fields:
        av = getattr(a, f)
        bv = getattr(b, f)
        status = "same" if av == bv else "DIFF"
        print(f"{status:5} {f}:")
        print(f"  left : {av}")
        print(f"  right: {bv}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
