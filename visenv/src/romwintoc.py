from __future__ import annotations
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Optional
import csv

@dataclass
class RomWinTocEntry:
    index: int
    short_name: str
    file_name: str
    size_bytes: int
    output_file: str = ""

class RomWinTocMount:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.entries: List[RomWinTocEntry] = []
        table = root / "romwintoc_file_table.csv"
        if table.exists():
            with table.open(newline="", encoding="utf-8") as f:
                for row in csv.DictReader(f):
                    self.entries.append(RomWinTocEntry(
                        int(row["index"]),
                        row.get("short_name") or row.get("alias") or "",
                        row["file_name"],
                        int(row["size_bytes"]),
                        row.get("output_file", ""),
                    ))

    def find(self, name: str) -> Optional[RomWinTocEntry]:
        up = name.upper()
        for e in self.entries:
            if e.file_name.upper() == up or e.short_name.upper() == up:
                return e
        return None

    def summary(self):
        return [asdict(e) for e in self.entries]
