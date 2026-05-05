from __future__ import annotations
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

@dataclass
class MediaExecInfo:
    target: str
    exists: bool
    format: str
    action: str
    reason: str

def inspect_media_executable(media_a: Optional[Path], target: str) -> MediaExecInfo:
    up = target.upper()
    if not media_a or not (up.startswith("A:\\") or up.startswith("A:/")):
        return MediaExecInfo(target, False, "unknown", "not executed", "target is not on simulated A:")
    rel = target[3:].replace("\\", "/")
    path = media_a / rel
    if not path.exists():
        return MediaExecInfo(target, False, "missing", "not executed", "file not found")
    data = path.read_bytes()[:2]
    fmt = "MZ EXE" if data == b"MZ" else ("COM/flat" if up.endswith(".COM") else "unknown/flat")
    return MediaExecInfo(target, True, fmt, "classified only", "VISENV does not execute media binaries yet")
