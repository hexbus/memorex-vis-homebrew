# VIS ROM extraction

This tool extracts known regions from a user-supplied 1 MiB VIS BIOS image.

```bash
python3 tools/extract/extract_vis_rom.py VIS_BIOS_1MB.bin out/vis-rom --wrappers
```

It does not include or download a BIOS image.

The generated MZ wrappers are analysis-only. They are not recovered original EXE files.
