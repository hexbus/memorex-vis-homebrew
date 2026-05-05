#!/usr/bin/env python3
"""Extract VIS ROMWINTOC B: runtime files from a 1 MiB VIS BIOS image."""

from __future__ import annotations
from pathlib import Path
import argparse, csv

TABLE_BASE = 0xF4034
ENTRY_SIZE = 26
ENTRY_COUNT = 29
POINTER_BIAS = 0x300000
PAYLOAD_END = 0xD8800

def read_cstr(blob: bytes) -> str:
    return blob.split(b"\0", 1)[0].decode("ascii", errors="replace")

def parse_entries(rom: bytes):
    entries = []
    for i in range(ENTRY_COUNT):
        off = TABLE_BASE + i * ENTRY_SIZE
        short = read_cstr(rom[off:off+9])
        long = read_cstr(rom[off+9:off+22])
        ptr = int.from_bytes(rom[off+22:off+26], "little")
        file_off = ptr - POINTER_BIAS
        if i < ENTRY_COUNT - 1:
            next_ptr = int.from_bytes(rom[TABLE_BASE+(i+1)*ENTRY_SIZE+22:TABLE_BASE+(i+1)*ENTRY_SIZE+26], "little")
            end = next_ptr - POINTER_BIAS
        else:
            end = PAYLOAD_END
        entries.append({
            "index": i,
            "table_offset": off,
            "short_name": short,
            "file_name": long,
            "rom_pointer": ptr,
            "file_offset": file_off,
            "end_offset_exclusive": end,
            "size_bytes": end - file_off,
        })
    return entries

def safe_name(index: int, file_name: str) -> str:
    return f"{index:02d}_{file_name.replace('.', '_').replace('/', '_').replace('\\\\', '_')}.bin"

def main() -> int:
    ap = argparse.ArgumentParser(description="Extract VIS ROMWINTOC B: files")
    ap.add_argument("rom", type=Path)
    ap.add_argument("out", type=Path)
    args = ap.parse_args()
    rom = args.rom.read_bytes()
    if len(rom) != 0x100000:
        raise SystemExit(f"Expected 1 MiB ROM, got {len(rom)} bytes")
    args.out.mkdir(parents=True, exist_ok=True)
    files_dir = args.out / "romwintoc_b_drive"
    files_dir.mkdir(exist_ok=True)
    entries = parse_entries(rom)
    with (args.out / "romwintoc_file_table.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["index","table_offset","short_name","file_name","rom_pointer","file_offset","end_offset_exclusive","size_bytes","output_file"])
        w.writeheader()
        for e in entries:
            start, end = e["file_offset"], e["end_offset_exclusive"]
            if not (0 <= start < end <= len(rom)):
                raise SystemExit(f"Invalid ROMWINTOC range for {e['file_name']}: {start:#x}-{end:#x}")
            name = safe_name(e["index"], e["file_name"])
            (files_dir / name).write_bytes(rom[start:end])
            row = dict(e)
            row["table_offset"] = f"0x{e['table_offset']:05X}"
            row["rom_pointer"] = f"0x{e['rom_pointer']:08X}"
            row["file_offset"] = f"0x{e['file_offset']:05X}"
            row["end_offset_exclusive"] = f"0x{e['end_offset_exclusive']:05X}"
            row["output_file"] = f"romwintoc_b_drive/{name}"
            w.writerow(row)
    print(f"Extracted {len(entries)} ROMWINTOC B: files to {files_dir}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
