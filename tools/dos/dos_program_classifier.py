#!/usr/bin/env python3
"""Static DOS program risk classifier for VIS homebrew triage.

This does not emulate or disassemble fully. It scans for byte patterns and
strings that often indicate compatibility risks on the VIS.
"""

from __future__ import annotations

from pathlib import Path
import argparse, json, re
from dataclasses import dataclass, asdict
from typing import List, Dict, Any


INT_NAMES = {
    0x09: "keyboard IRQ / INT 9h",
    0x10: "BIOS video INT 10h",
    0x13: "BIOS disk INT 13h",
    0x15: "BIOS/VISBIOS INT 15h",
    0x16: "BIOS keyboard INT 16h",
    0x1A: "BIOS time INT 1Ah",
    0x21: "DOS INT 21h",
    0x2F: "multiplex INT 2Fh",
}

PORTS = {
    0x3C0: "VGA attribute controller",
    0x3C4: "VGA sequencer",
    0x3CE: "VGA graphics controller",
    0x3D4: "CGA/VGA CRT controller",
    0x388: "AdLib/OPL",
    0x220: "Sound Blaster common base",
    0x40: "PIT timer",
    0x60: "keyboard data port",
    0x64: "keyboard controller command/status",
}

VIDEO_MEMORY_PATTERNS = {
    b"\x00\xb8": "B800 text/CGA segment immediate little-endian",
    b"\x00\xa0": "A000 VGA graphics segment immediate little-endian",
    b"\x00\xb0": "B000 mono/CGA-ish segment immediate little-endian",
}


@dataclass
class Finding:
    category: str
    detail: str
    risk: str
    count: int


def count_ints(data: bytes) -> Dict[int, int]:
    counts: Dict[int, int] = {}
    for i in range(len(data) - 1):
        if data[i] == 0xCD:
            counts[data[i+1]] = counts.get(data[i+1], 0) + 1
    return counts


def count_port_immediates(data: bytes) -> Dict[int, int]:
    """Look for common immediate port patterns, not full disassembly."""
    counts: Dict[int, int] = {}
    for port in PORTS:
        lo = port & 0xFF
        hi = (port >> 8) & 0xFF
        # mov dx, imm16 = BA lo hi
        pat = bytes([0xBA, lo, hi])
        c = data.count(pat)
        # direct in/out imm8 for low ports only
        if port <= 0xFF:
            c += data.count(bytes([0xE4, lo])) + data.count(bytes([0xE6, lo]))
        if c:
            counts[port] = c
    return counts


def classify(path: Path) -> Dict[str, Any]:
    data = path.read_bytes()
    fmt = "MZ EXE" if data[:2] == b"MZ" else "COM/flat or unknown"
    findings: List[Finding] = []

    for intno, count in sorted(count_ints(data).items()):
        if intno in INT_NAMES:
            risk = "info"
            if intno == 0x09:
                risk = "high"
            elif intno in (0x10, 0x16, 0x21):
                risk = "medium"
            elif intno in (0x13,):
                risk = "high"
            findings.append(Finding("interrupt", f"INT {intno:02X}h - {INT_NAMES[intno]}", risk, count))

    for port, count in sorted(count_port_immediates(data).items()):
        desc = PORTS[port]
        risk = "medium"
        if port in (0x60, 0x64, 0x220):
            risk = "high"
        findings.append(Finding("port", f"port {port:03X}h - {desc}", risk, count))

    for pat, desc in VIDEO_MEMORY_PATTERNS.items():
        c = data.count(pat)
        if c:
            findings.append(Finding("memory", desc, "medium", c))

    strings = re.findall(rb"[ -~]{4,}", data)
    interesting_strings = []
    for s in strings[:500]:
        t = s.decode("ascii", errors="replace")
        up = t.upper()
        if any(x in up for x in ["SOUNDBLASTER", "BLASTER", "ADLIB", "VGA", "CGA", "EGA", "B800", "A000"]):
            interesting_strings.append(t)

    risk_score = 0
    for f in findings:
        risk_score += {"info": 1, "medium": 3, "high": 7}.get(f.risk, 1) * f.count

    if risk_score >= 20:
        rating = "high risk"
    elif risk_score >= 8:
        rating = "medium risk"
    else:
        rating = "low/unknown risk"

    return {
        "path": str(path),
        "size": len(data),
        "format": fmt,
        "risk_rating": rating,
        "findings": [asdict(f) for f in findings],
        "interesting_strings": interesting_strings[:50],
        "notes": [
            "This is a heuristic static scan, not a compatibility guarantee.",
            "INT 9h hooks, direct keyboard ports, and direct VGA/Sound Blaster hardware are risky on VIS.",
        ],
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Classify DOS binary compatibility risk for VIS")
    ap.add_argument("binary", type=Path)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()

    result = classify(args.binary)
    text = json.dumps(result, indent=2)
    print(text)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
