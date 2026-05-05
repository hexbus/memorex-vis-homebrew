from __future__ import annotations
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional
import json

@dataclass
class Handler:
    interrupt: str
    owner: str
    purpose: str
    details: Dict[str, Any]

class VirtualInterruptTable:
    def __init__(self) -> None:
        self.handlers: Dict[str, List[Handler]] = {}

    def register(self, interrupt: str, owner: str, purpose: str, **details: Any) -> None:
        key = interrupt.upper()
        self.handlers.setdefault(key, []).append(Handler(key, owner.upper(), purpose, details))

    def owners(self, interrupt: str) -> List[str]:
        return [h.owner for h in self.handlers.get(interrupt.upper(), [])]

    def to_dict(self):
        return {k: [asdict(h) for h in v] for k,v in sorted(self.handlers.items())}

    def write_json(self, path: str) -> None:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2)

class FakeDos:
    def __init__(self, env: "VisEnv") -> None:
        self.env = env
        self.handles: Dict[int, bytes] = {}
        self.next_handle = 5

    def _resolve_path(self, dos_path: str) -> Optional[Path]:
        up = dos_path.upper()
        if up.startswith("A:\\") or up.startswith("A:/"):
            if not self.env.media_a:
                return None
            return self.env.media_a / dos_path[3:].replace("\\", "/")
        if up.startswith("B:\\") or up.startswith("B:/"):
            if not self.env.rom_b:
                return None
            return self.env.rom_b / dos_path[3:].replace("\\", "/")
        return None

    def int21_open(self, path: str) -> int:
        self.env.trace.add("INT21", "AH=3Dh open file", path=path)
        host = self._resolve_path(path)
        if not host or not host.exists():
            self.env.trace.add("INT21", "open failed", path=path, ax="0002h")
            return -1
        handle = self.next_handle
        self.next_handle += 1
        self.handles[handle] = host.read_bytes()
        self.env.trace.add("INT21", "open succeeded", path=path, handle=handle, size=len(self.handles[handle]))
        return handle

    def int21_read(self, handle: int, count: int, offset: int = 0) -> bytes:
        self.env.trace.add("INT21", "AH=3Fh read file", handle=handle, count=count, offset=offset)
        data = self.handles.get(handle, b"")
        chunk = data[offset:offset+count]
        self.env.trace.add("INT21", "read returned", bytes=len(chunk))
        return chunk

    def int21_exec(self, target: str, caller: str) -> None:
        self.env.trace.add("INT21", "AH=4Bh EXEC", caller=caller, target=target)
        self.env.exec(target, caller=caller)
