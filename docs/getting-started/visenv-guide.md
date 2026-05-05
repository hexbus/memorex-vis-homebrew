# VISENV Guide

VISENV is a Python scaffold that models the VIS boot and title-launch path.

It is not a CPU emulator. It provides enough structure to reason about the VIS runtime and homebrew package layout.

## Current VISENV capabilities

```text
ROM EXEC resolver model
fake INT 21h open/read/EXEC behavior
CONTROL.TAT parsing
TLAUNCH state modeling
MINWIN handoff diagnostics
GBIOS system/input/video stubs
audio and CyberCard stubs
REDIR and ROMWINTOC models
```

## Run VISENV

```bash
python3 visenv/src/visenv.py --media-a examples/first-homebrew/media_a
```

## Current limitation

VISENV does not execute original ROM modules or DOS binaries. It models the title-launch environment and reports what would happen next.
