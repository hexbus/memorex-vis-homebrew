#!/usr/bin/env python3
"""Extract known VIS ROM regions.

This is a practical extraction entry point for the Git repo. It does not include
the VIS BIOS ROM. Supply your own legally obtained 1 MiB ROM image.

Outputs:
    option_roms/
    runtime_segments/
    maps/
    experimental_wrappers/

The ROMWINTOC file-table parser is intentionally conservative here. It writes
the known region and a starter CSV; deeper NE/module extraction can be added
once the final parser is promoted into this repo.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
import struct

SEGMENTS = [
    ("D8800_option_rom_and_exports", 0xD8800, 0xD8960),
    ("D8960_boot_core_romexec", 0xD8960, 0xDC3C0),
    ("DC3C0_command_dispatcher", 0xDC3C0, 0xDC460),
    ("DC460_mscdex_cdrom", 0xDC460, 0xE1580),
    ("E1580_minwin_starter", 0xE1580, 0xE1660),
    ("E1660_gbios_vis_extensions", 0xE1660, 0xE8AD0),
    ("E8AD0_redir_runtime_config", 0xE8AD0, 0xE9880),
    ("E9880_tlaunch_title_launcher", 0xE9880, 0xF4000),
    ("F4000_romwintoc_loader", 0xF4000, 0xF7000),
    ("F7C00_video_bios", 0xF7C00, 0xFC000),
    ("FC000_phoenix_boot_bios", 0xFC000, 0x100000),
]

EXPORTS = [
    ("COMMAND", "0xDC3C0"),
    ("MSCDEX", "0xDC460"),
    ("MINWIN", "0xE1580"),
    ("GBIOS", "0xE1660"),
    ("REDIR", "0xE8AD0"),
    ("TLAUNCH", "0xE9880"),
    ("ROMA", "external C000 probe"),
    ("ROMB", "external C400 probe"),
]


def write_mz_wrapper(path: Path, payload: bytes) -> None:
    """Write a simple analysis-only MZ wrapper.

    This wrapper is for loading in tools, not for claiming the module is a
    recovered standalone EXE.
    """
    # Minimal EXE: header 32 bytes, payload begins at load image offset 0.
    # e_cparhdr = 2 paragraphs, CS:IP = 0000:0000.
    header_paras = 2
    header_size = header_paras * 16
    image = b"\x00" * header_size + payload
    total_pages = (len(image) + 511) // 512
    last_page = len(image) % 512
    if last_page == 0:
        last_page = 512
    hdr = bytearray(header_size)
    hdr[0:2] = b"MZ"
    struct.pack_into("<H", hdr, 2, last_page)
    struct.pack_into("<H", hdr, 4, total_pages)
    struct.pack_into("<H", hdr, 6, 0)       # relocations
    struct.pack_into("<H", hdr, 8, header_paras)
    struct.pack_into("<H", hdr, 0x0E, 0)    # SS
    struct.pack_into("<H", hdr, 0x10, 0xFFFE) # SP
    struct.pack_into("<H", hdr, 0x14, 0)    # IP
    struct.pack_into("<H", hdr, 0x16, 0)    # CS
    path.write_bytes(bytes(hdr) + payload)


def main() -> int:
    ap = argparse.ArgumentParser(description="Extract known VIS ROM regions")
    ap.add_argument("rom", type=Path)
    ap.add_argument("out", type=Path)
    ap.add_argument("--wrappers", action="store_true", help="also create analysis-only MZ wrappers")
    args = ap.parse_args()

    data = args.rom.read_bytes()
    if len(data) != 0x100000:
        raise SystemExit(f"Expected 1 MiB ROM image, got {len(data)} bytes")

    args.out.mkdir(parents=True, exist_ok=True)
    seg_dir = args.out / "runtime_segments"
    seg_dir.mkdir(exist_ok=True)
    map_dir = args.out / "maps"
    map_dir.mkdir(exist_ok=True)
    wrap_dir = args.out / "experimental_wrappers"
    if args.wrappers:
        wrap_dir.mkdir(exist_ok=True)

    with (map_dir / "segments.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["name", "start", "end", "size", "filename"])
        for name, start, end in SEGMENTS:
            blob = data[start:end]
            fn = f"{name}_{start:05X}_{end:05X}.bin"
            (seg_dir / fn).write_bytes(blob)
            w.writerow([name, f"0x{start:05X}", f"0x{end:05X}", len(blob), fn])
            if args.wrappers and name not in {"F7C00_video_bios", "FC000_phoenix_boot_bios"}:
                write_mz_wrapper(wrap_dir / fn.replace(".bin", "_analysis.EXE"), blob)

    with (map_dir / "d8800_exports.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["export", "target"])
        w.writerows(EXPORTS)

    print(f"Wrote extraction output to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
