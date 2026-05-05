#!/usr/bin/env python3
"""Run the main VIS extraction steps into a single output folder."""

from __future__ import annotations
from pathlib import Path
import argparse, subprocess, sys

ROOT = Path(__file__).resolve().parent

def run(cmd):
    print("+", " ".join(str(x) for x in cmd))
    subprocess.check_call(cmd)

def main() -> int:
    ap = argparse.ArgumentParser(description="Run VIS ROM extraction suite")
    ap.add_argument("rom", type=Path)
    ap.add_argument("out", type=Path)
    ap.add_argument("--wrappers", action="store_true")
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    run([sys.executable, ROOT/"extract_vis_rom.py", args.rom, args.out/"regions"] + (["--wrappers"] if args.wrappers else []))
    run([sys.executable, ROOT/"extract_romwintoc.py", args.rom, args.out/"romwintoc"])
    run([sys.executable, ROOT/"extract_gbios_midi_table.py", args.out/"gbios_midi_table.csv"])
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
