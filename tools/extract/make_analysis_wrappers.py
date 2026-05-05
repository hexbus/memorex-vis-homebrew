#!/usr/bin/env python3
"""Create analysis-only MZ wrappers for raw ROM segments.

These are not recovered original EXE files. They exist so disassemblers can
load a flat ROM segment with CS:IP approximately at 0000:0000.
"""

from __future__ import annotations
from pathlib import Path
import argparse, struct

def write_wrapper(src: Path, dst: Path) -> None:
    payload = src.read_bytes()
    header_paras = 2
    header_size = header_paras * 16
    total_len = header_size + len(payload)
    pages = (total_len + 511) // 512
    last = total_len % 512 or 512
    hdr = bytearray(header_size)
    hdr[0:2] = b"MZ"
    struct.pack_into("<H", hdr, 2, last)
    struct.pack_into("<H", hdr, 4, pages)
    struct.pack_into("<H", hdr, 8, header_paras)
    struct.pack_into("<H", hdr, 0x0E, 0)
    struct.pack_into("<H", hdr, 0x10, 0xFFFE)
    struct.pack_into("<H", hdr, 0x14, 0)
    struct.pack_into("<H", hdr, 0x16, 0)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(bytes(hdr) + payload)

def main() -> int:
    ap = argparse.ArgumentParser(description="Create analysis-only MZ wrapper")
    ap.add_argument("raw_segment", type=Path)
    ap.add_argument("out_exe", type=Path)
    args = ap.parse_args()
    write_wrapper(args.raw_segment, args.out_exe)
    print(f"Wrote {args.out_exe}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
