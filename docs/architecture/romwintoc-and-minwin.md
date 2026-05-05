# ROMWINTOC and MINWIN

The VIS ROM contains a ROMWINTOC-backed runtime file set that behaves like a ROM-resident B: drive for Modular Windows.

## Extraction

```bash
python3 tools/extract/extract_romwintoc.py VIS_BIOS_1MB.bin out/romwintoc
```

The extractor currently knows the ROMWINTOC table layout and extracts 29 runtime files.

## MINWIN model

VISENV can model the `minwin b:` handoff boundary and report whether key runtime files are present:

```text
KERNEL.EXE
GDI.EXE
USER.EXE
MMSYSTEM.DLL
VGA.DRV
```

This does not boot Modular Windows yet. It diagnoses the handoff.
