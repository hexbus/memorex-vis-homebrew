#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from vis_register_keygen import generate_key

def main() -> int:
    ap = argparse.ArgumentParser(description="Validate VIS keygen against REGISTER.EXE vectors")
    ap.add_argument("--vectors", type=Path, default=Path(__file__).with_name("test_vectors.json"))
    args = ap.parse_args()
    data = json.loads(args.vectors.read_text(encoding="utf-8"))
    failures = 0
    for i, v in enumerate(data.get("vectors", []), 1):
        got = generate_key(int(v["vendor"]), int(v["product"]), v["class"])
        if got != v["key"]:
            failures += 1
            print(f"not ok {i}: vendor={v['vendor']} product={v['product']} class={v['class']} expected={v['key']} got={got}")
        else:
            print(f"ok {i}: vendor={v['vendor']} product={v['product']} class={v['class']} key={got}")
    return 1 if failures else 0

if __name__ == "__main__":
    raise SystemExit(main())
