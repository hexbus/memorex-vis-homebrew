# Memorex VIS Homebrew

Developer documentation, tools, and an experimental VISENV runtime scaffold for creating homebrew software for the **Memorex / Tandy Video Information System**, a 1992 CD-ROM-based multimedia computer/player.

This project focuses on understanding the VIS boot process, title authorization flow, ROM-resident runtime, DOS title launch path, and early homebrew workflows.

## What this repo provides

```text
docs/       Human-readable technical documentation
tools/      Keygen, CONTROL.TAT, ROM extraction, and DOS compatibility tools
visenv/     Python VIS runtime model and service stubs
examples/   DOS and VISENV homebrew examples
asm/        ROM notes and annotated assembly references
maps/       CSV maps for hardware, runtime modules, and extracted structures
data_tables/reference data extracted or reconstructed from ROM analysis
```

## Current status

This is a **developer preview**, not a finished product.  I highly encourage Open Source community partitipation, as this will be as far as I can bring this repo on my own.
(I feel that VISENV itself is a promising tool, and can eventually be extended into a DOS utility to replace the proprietary VIS developer cards, but I need the community's help to get there.)

What is working today:

- REGISTER.EXE-style key generation with validation against the known sample vector.
- ROMWINTOC B: runtime file extraction from a user-supplied VIS BIOS ROM.
- CONTROL.TAT inspection and TLAUNCH state modeling.
- VISENV boot/title-launch scaffold.
- DOS compatibility triage tools.
- GBIOS, video, hand-controller, audio, CyberCard, REDIR, and MINWIN service stubs.
- Hardware reference notes from an opened unit.

Not finished yet:

- Full hardware emulation. (VISENV is a promising launcher foundation)
- Full production CONTROL.TAT validator parity.
- Full Modular Windows execution.
- Complete GBIOS service contract mapping.
- Byte-complete annotated disassembly for every ROM module.
- Hardware validation of every documented video/input/audio behavior.

## Quick start

Validate the key generator:

```bash
python3 tools/keygen/validate_keygen.py
```

Inspect a CONTROL.TAT:

```bash
python3 tools/controltat/controltat_report.py examples/first-homebrew/media_a/CONTROL.TAT
```

Run VISENV against the included sample media folder:

```bash
python3 visenv/src/visenv.py --media-a examples/first-homebrew/media_a
```

Classify a DOS program for likely VIS compatibility risks:

```bash
python3 tools/dos/dos_program_classifier.py path/to/PROGRAM.EXE
```

Extract VIS ROM regions and ROMWINTOC files from a user-supplied 1 MiB BIOS image:

```bash
python3 tools/extract/extract_all.py VIS_BIOS_1MB.bin out/vis-rom --wrappers
```

## Documentation path

Start here:

1. [Project overview](docs/overview.md)
2. [Getting started with VIS homebrew](docs/getting-started/first-homebrew-title.md)
3. [VIS boot process](docs/architecture/boot-process.md)
4. [CONTROL.TAT and TLAUNCH](docs/architecture/control-tat-and-tlaunch.md)
5. [DOS homebrew guide](docs/getting-started/dos-homebrew.md)
6. [VISENV guide](docs/getting-started/visenv-guide.md)
7. [Roadmap to 1.0](docs/roadmap.md)

## See also

[TJBChris' Memorex VIS Repo](https://github.com/TJBChris/memorex_vis)

## Legal

This repository does **not** include BIOS ROMs, Microsoft SDK files, commercial VIS titles, or proprietary source drops.

VIS ROM information (you just join these together):

```
p513bk0b.bin	
MD5:	ebf432d3b09f694db1c62018eb2ab471

p513bk1b.bin	
MD5:	758f8fec271fbf526bb22b36e88f154b
```
