#!/usr/bin/env python3
from __future__ import annotations
import argparse
from pathlib import Path
import sys
import json

sys.path.insert(0, str(Path(__file__).resolve().parent))
from visenv_core import VisEnv

def main() -> int:
    ap = argparse.ArgumentParser(description="VISENV staged prototype")
    ap.add_argument("--media-a", type=Path, default=None)
    ap.add_argument("--rom-b", type=Path, default=None)
    ap.add_argument("--json-trace", type=Path, default=None)
    ap.add_argument("--json-services", type=Path, default=None)
    ap.add_argument("--json-control-tat", type=Path, default=None)
    args = ap.parse_args()

    env = VisEnv(media_a=args.media_a, rom_b=args.rom_b)
    env.boot()
    env.trace.print()

    print("\nVirtual services:")
    for k, handlers in env.services.to_dict().items():
        print(f"  {k}: {', '.join(h['owner'] for h in handlers)}")

    if args.json_trace:
        args.json_trace.parent.mkdir(parents=True, exist_ok=True)
        env.trace.write_json(str(args.json_trace))
    if args.json_services:
        args.json_services.parent.mkdir(parents=True, exist_ok=True)
        env.services.write_json(str(args.json_services))
    if args.json_control_tat and env.control_tat_info:
        args.json_control_tat.parent.mkdir(parents=True, exist_ok=True)
        args.json_control_tat.write_text(json.dumps(env.control_tat_info.to_dict(), indent=2), encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
