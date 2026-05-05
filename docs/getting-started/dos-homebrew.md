# DOS Homebrew Guide

Simple DOS programs are a practical early homebrew target because the VIS has a 286-class PC-compatible foundation. The safest programs avoid direct PC hardware assumptions.

## VIS-safe baseline

Prefer:

```text
INT 10h for simple graphics mode set
INT 16h for keyboard polling
INT 21h for DOS file/read/exit behavior
simple real-mode COM/EXE binaries
graphics-mode UI
```

Avoid:

```text
INT 9h keyboard hooks
keyboard ports 60h/64h
normal 80x25 text-mode dependency
Sound Blaster-only audio
VGA register tricks
hard-coded C: paths
protected-mode extenders
```

## Static compatibility scan

Run:

```bash
python3 tools/dos/dos_program_classifier.py PROGRAM.EXE
```

Batch scan a folder:

```bash
python3 tools/dos/batch_classify.py dos-folder --json out/batch.json
python3 tools/dos/compatibility_report.py out/batch.json out/report.md
```

## Recommended first test

Create a tiny real-mode program that:

1. Sets a simple graphics mode.
2. Draws a visible pattern.
3. Polls input with INT 16h.
4. Exits cleanly.

See:

```text
examples/dos-safe-template/
examples/dos-mode13-demo/
examples/dos-int16-input-demo/
examples/dos-launch-smoke-test/
```
