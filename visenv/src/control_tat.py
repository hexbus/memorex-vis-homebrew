from __future__ import annotations
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import List, Optional, Dict, Any
import re

AUTHORIZED = b"[ ATTENTION: This is an Authorized Video Information System Title. END OF STATEMENT ]"

@dataclass
class ControlTatInfo:
    present: bool
    path: Optional[str]
    size: int
    has_registration_payload: bool
    registration_payload_hex: Optional[str]
    has_maketat_marker_area: bool
    maketat_marker_preview: Optional[str]
    has_authorized_statement: bool
    version_gate_bytes_hex: Optional[str]
    possible_startup_commands: List[str]
    printable_strings: List[str]
    warnings: List[str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

def printable_strings(data: bytes, min_len: int = 4) -> List[str]:
    pattern = rb"[ -~]{" + str(min_len).encode("ascii") + rb",}"
    return [m.group(0).decode("ascii", errors="replace") for m in re.finditer(pattern, data)]

def find_possible_commands(strings: List[str]) -> List[str]:
    out = []
    for s in strings:
        low = s.lower()
        if "minwin" in low or low.endswith(".exe") or low.endswith(".com") or ".exe " in low or ".com " in low:
            out.append(s)
    # preserve order, unique
    seen=set(); uniq=[]
    for s in out:
        if s not in seen:
            uniq.append(s); seen.add(s)
    return uniq

def parse_control_tat(path: Path) -> ControlTatInfo:
    if not path.exists():
        return ControlTatInfo(False, str(path), 0, False, None, False, None, False, None, [], [], ["CONTROL.TAT not found"])

    data = path.read_bytes()
    warnings: List[str] = []
    size = len(data)

    has_reg = size >= 0x98 + 12
    reg_hex = data[0x98:0x98+12].hex(" ") if has_reg else None
    if not has_reg:
        warnings.append("File too short for known +0x98 registration payload area")

    has_marker = size >= 0xB0 + 16
    marker_preview = None
    if has_marker:
        raw = data[0xB0:0xB0+96]
        marker_preview = "".join(chr(b) if 32 <= b < 127 else "." for b in raw).strip(".")
    else:
        warnings.append("File too short for known +0xB0 MAKETAT/version marker area")

    # Observed sampler/runtime-gate area from earlier analysis. Treat as observed, not final spec.
    version_gate = data[0xD8:0xD8+5].hex(" ") if size >= 0xD8 + 5 else None
    if version_gate is None:
        warnings.append("File too short for observed +0xD8 version-gate byte area")

    strings = printable_strings(data)
    commands = find_possible_commands(strings)
    if not commands:
        warnings.append("No obvious startup command string found by heuristic scan")

    return ControlTatInfo(
        present=True,
        path=str(path),
        size=size,
        has_registration_payload=has_reg,
        registration_payload_hex=reg_hex,
        has_maketat_marker_area=has_marker,
        maketat_marker_preview=marker_preview,
        has_authorized_statement=AUTHORIZED in data,
        version_gate_bytes_hex=version_gate,
        possible_startup_commands=commands,
        printable_strings=strings[:100],
        warnings=warnings,
    )
