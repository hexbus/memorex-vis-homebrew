#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import argparse, json, sys

ROOT = Path(__file__).resolve().parents[2] / "visenv" / "src"
sys.path.insert(0, str(ROOT))
from control_tat import parse_control_tat
from tlaunch_model import model_tlaunch

def main() -> int:
    ap = argparse.ArgumentParser(description="Write a human-readable CONTROL.TAT / TLAUNCH report")
    ap.add_argument("control_tat", type=Path)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()

    info = parse_control_tat(args.control_tat)
    model = model_tlaunch(args.control_tat)

    print("CONTROL.TAT report")
    print("==================")
    print(f"Present: {info.present}")
    print(f"Size: {info.size}")
    print(f"+0x98 registration payload: {info.has_registration_payload}")
    if info.registration_payload_hex:
        print(f"  {info.registration_payload_hex}")
    print(f"+0xB0 MAKETAT marker area: {info.has_maketat_marker_area}")
    if info.maketat_marker_preview:
        print(f"  {info.maketat_marker_preview}")
    print(f"Observed +0xD8 version-gate bytes: {info.version_gate_bytes_hex}")
    print(f"Authorized statement present: {info.has_authorized_statement}")
    if info.possible_startup_commands:
        print("Possible startup commands:")
        for s in info.possible_startup_commands:
            print(f"  - {s}")
    print()
    print("TLAUNCH model")
    print("=============")
    print(f"Launch kind: {model.launch_kind}")
    print(f"Launch target: {model.launch_target}")
    print("States:")
    for s in model.states:
        print(f"  - {s}")
    if model.warnings:
        print("Warnings:")
        for w in model.warnings:
            print(f"  - {w}")

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps({"control_tat": info.to_dict(), "tlaunch": asdict_safe(model)}, indent=2), encoding="utf-8")
    return 0

def asdict_safe(model):
    return {
        "states": model.states,
        "control_tat": model.control_tat,
        "launch_kind": model.launch_kind,
        "launch_target": model.launch_target,
        "warnings": model.warnings,
    }

if __name__ == "__main__":
    raise SystemExit(main())
