from __future__ import annotations
from dataclasses import dataclass, asdict
from typing import Dict, Any

@dataclass
class VideoMode:
    mode: int
    description: str
    status: str
    notes: str

class VideoStub:
    """VIS video service placeholder.

    This is not VGA emulation. It records conservative mode support assumptions
    for homebrew triage.
    """
    def __init__(self) -> None:
        self.modes = {
            0x13: VideoMode(0x13, "320x200x256 style graphics", "test-first", "common DOS graphics target; verify on hardware"),
            0x0D: VideoMode(0x0D, "320x200x16 EGA-style graphics", "test-first", "safer than text UI"),
            0x0E: VideoMode(0x0E, "640x200x16 EGA-style graphics", "test-first", "verify TV readability"),
            0x03: VideoMode(0x03, "80x25 text", "risky", "VIS TV output/text assumptions are risky"),
        }
        self.current_mode = None

    def set_mode(self, mode: int) -> Dict[str, Any]:
        info = self.modes.get(mode, VideoMode(mode, f"unknown mode {mode:02X}h", "unknown", "not in VISENV registry"))
        self.current_mode = mode
        return asdict(info)

    def list_modes(self):
        return [asdict(v) for v in self.modes.values()]
