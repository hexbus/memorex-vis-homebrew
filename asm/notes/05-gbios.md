# 05 Gbios

This note explains the module role in plain English. The corresponding annotated assembly file is in `asm/annotated/`.

## Source status

Production ROM disassembly remains the source of truth. These notes are engineering explanations aligned to known ROM ranges and behavior.

## Notes

- GBIOS / VIS BIOS Extensions
- ROM range:        0xE1660-0xE8ACF
- Entry model:      E166:0000
- VIS-specific role:Low-level VIS service layer.
- Confidence:       high for role/sequence, medium for exact unlabelled routine names
- Summary:
- GBIOS is the module most relevant to future low-level homebrew. It installs VISBIOS services and exposes the system, hand-controller, memory-card, audio, mixer, synth, timer, and probably video integration families.
- Stub contract:
- VISENV should model externally visible behavior first. Raw ROM execution
- should use original bytes unchanged and keep adaptation in the loader/shim.
- Installed services
- - INT 15h VISBIOS service dispatcher.
- - INT 2Fh Modular Windows/runtime integration.
- - Known service families include AX=7100h system and AX=7101h hand-control.
- Data tables
- - GBIOS contains a General MIDI-style 128-instrument table near 0xE803E.
- - This supports the audio/synth service interpretation.
- Hardware stubs
- - Gryphon video placeholder.
- - AdLib Gold-like audio placeholder.
- - CyberCard/Save-It placeholder.
- - Hand-controller placeholder.
- TODO for future source-quality reconstruction:
- - Insert exact byte offsets and instructions from the production ROM listing.
- - Preserve these English comments next to the corresponding code.
- - Mark uncertain labels as `suspected_` rather than overclaiming.
