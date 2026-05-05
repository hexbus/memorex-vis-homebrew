from __future__ import annotations
from dataclasses import dataclass, asdict
from typing import List, Dict, Any

@dataclass
class ControllerEvent:
    tick: int
    button: str
    state: str

class HandControllerStub:
    def __init__(self) -> None:
        self.events: List[ControllerEvent] = []
        self.tick = 0

    def load_script(self, events: List[Dict[str, Any]]) -> None:
        self.events = [ControllerEvent(int(e["tick"]), str(e["button"]), str(e["state"])) for e in events]

    def poll(self) -> Dict[str, Any]:
        active = [asdict(e) for e in self.events if e.tick == self.tick]
        self.tick += 1
        return {"tick": self.tick - 1, "events": active, "status": "no-event" if not active else "event"}
