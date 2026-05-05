from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

@dataclass
class RawModuleImage:
    name: str
    path: Path
    load_segment: int
    entry_offset: int = 0

    def load_bytes(self) -> bytes:
        return self.path.read_bytes()

class RawModuleLoader:
    """Stage 45 scaffold.

    This does not execute 16-bit code. It records the intended load contract so a
    later DOSBox/MS-DOS harness or emulator can load unmodified raw ROM segments.
    """

    def describe(self, image: RawModuleImage) -> dict:
        data = image.load_bytes()
        return {
            "name": image.name,
            "path": str(image.path),
            "bytes": len(data),
            "load_segment": f"{image.load_segment:04X}",
            "entry": f"{image.load_segment:04X}:{image.entry_offset:04X}",
            "policy": "load original raw segment unchanged; adapt only in VISENV wrapper",
        }
