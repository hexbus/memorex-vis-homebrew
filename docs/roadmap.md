# Roadmap to 1.0

The project is currently a strong developer preview. It's almost a v0.9.  I have done what I can with my knowledge.

A real 1.0 should be hardware-tested, and I am releasing this to the community so that people can branch and offer MRs and continue
to improve this guide and bring it up to where it needs to be, a full community supported VIS SDK.

## Remaining milestones

### ROM reference completion

- Add more byte-addressed annotated assembly chunks.
- Complete module notes for D8800, D8960, ROM EXEC, COMMAND, MSCDEX, GBIOS, REDIR, TLAUNCH, MINWIN, and F4000.

### CONTROL.TAT parity

- Collect more real CONTROL.TAT samples.
- Verify startup command field locations.
- Improve validator parity against production ROM behavior.

### Hardware validation

- Test a simple DOS homebrew title on real hardware.
- Verify graphics modes.
- Verify keyboard/input behavior.
- Verify CD-ROM title launch path.
- Verify audio assumptions.

### GBIOS service mapping

- Define service numbers.
- Document register inputs and outputs.
- Add callable VISENV service behavior.

### Modular Windows path

- Validate ROMWINTOC extraction against a real ROM.
- Validate MINWIN handoff diagnostics.
- Document SYSTEM.INI and `[boot] shell=` behavior.

## 1.0 definition

A "good v1.0" definition means:

```text
a developer can build a simple VIS homebrew title,
package it with CONTROL.TAT,
inspect and validate it with repo tools,
run it through VISENV diagnostics,
and test it on hardware with documented expectations.
```

I believe with the Open Source community's support, we will get there.  I'm just trying to get us started.
