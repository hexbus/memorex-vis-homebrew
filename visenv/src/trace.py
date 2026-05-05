from __future__ import annotations
from dataclasses import dataclass, asdict
from typing import Any, Dict, List
import json

@dataclass
class Event:
    index: int
    category: str
    message: str
    data: Dict[str, Any]

class Trace:
    def __init__(self) -> None:
        self.events: List[Event] = []

    def add(self, category: str, message: str, **data: Any) -> None:
        self.events.append(Event(len(self.events), category, message, data))

    def print(self) -> None:
        for e in self.events:
            details = ""
            if e.data:
                details = " " + " ".join(f"{k}={v!r}" for k,v in e.data.items())
            print(f"[{e.index:03d}] {e.category}: {e.message}{details}")

    def write_json(self, path: str) -> None:
        with open(path, "w", encoding="utf-8") as f:
            json.dump([asdict(e) for e in self.events], f, indent=2)
