from __future__ import annotations
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, Any

@dataclass
class CyberCardStatus:
    present: bool
    size_bytes: int
    backing_file: str | None

class CyberCardStub:
    """Service-backed Save-It/CyberCard storage.

    This intentionally does not pretend the card is a FAT drive.
    """
    def __init__(self, backing_file: Path | None = None, size_bytes: int = 32 * 1024) -> None:
        self.backing_file = backing_file
        self.size_bytes = size_bytes
        self.present = backing_file is not None
        if backing_file and not backing_file.exists():
            backing_file.parent.mkdir(parents=True, exist_ok=True)
            backing_file.write_bytes(b"\0" * size_bytes)

    def status(self) -> Dict[str, Any]:
        return CyberCardStatus(self.present, self.size_bytes, str(self.backing_file) if self.backing_file else None).__dict__

    def read(self, offset: int, count: int) -> bytes:
        if not self.backing_file:
            raise RuntimeError("CyberCard not present")
        data = self.backing_file.read_bytes()
        return data[offset:offset+count]

    def write(self, offset: int, payload: bytes) -> None:
        if not self.backing_file:
            raise RuntimeError("CyberCard not present")
        data = bytearray(self.backing_file.read_bytes())
        data[offset:offset+len(payload)] = payload
        self.backing_file.write_bytes(bytes(data[:self.size_bytes]))
