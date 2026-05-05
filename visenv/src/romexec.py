from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Optional

@dataclass(frozen=True)
class RomExport:
    name: str
    entry: str
    role: str

class RomExecResolver:
    def __init__(self, exports: Dict[str, RomExport]) -> None:
        self.exports = {k.upper(): v for k,v in exports.items()}

    @staticmethod
    def classify(target: str) -> str:
        t = target.strip()
        u = t.upper()
        if u.endswith("FRANKS_UNLIKELY.EXE"):
            return "fake/probe executable launch"
        if u.startswith("MINWIN"):
            return "title/minwin launch after CONTROL.TAT validation"
        has_path = any(ch in t for ch in [":", "\\", "/"])
        leaf = t.replace("/", "\\").split("\\")[-1]
        has_ext = "." in leaf
        if not has_path and not has_ext:
            return "ROM export launch"
        return "real media executable launch"

    def resolve(self, target: str) -> Optional[RomExport]:
        clean = target.strip().split()[0].upper()
        clean = clean.replace(".EXE","").replace(".COM","")
        return self.exports.get(clean)
