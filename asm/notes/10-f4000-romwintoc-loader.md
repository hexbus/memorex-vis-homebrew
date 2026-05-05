# 10 F4000 Romwintoc Loader

This note explains the module role in plain English. The corresponding annotated assembly file is in `asm/annotated/`.

## Source status

Production ROM disassembly remains the source of truth. These notes are engineering explanations aligned to known ROM ranges and behavior.

## Notes

- F4000 ROMWINTOC Loader
- ROM range:        0xF4000-0xF6FFF
- Entry model:      F400 region / F45F path
- VIS-specific role:ROMWINTOC table and Modular Windows loader path.
- Confidence:       high for role/sequence, medium for exact unlabelled routine names
- Summary:
- The F4000 area contains ROMWINTOC table/service logic and is reached after MINWIN. It is not the same kind of runtime option ROM as D8800; it is the bridge to the ROM-resident Modular Windows B: drive files.
- Stub contract:
- VISENV should model externally visible behavior first. Raw ROM execution
- should use original bytes unchanged and keep adaptation in the loader/shim.
- ROMWINTOC
- - Maps B: runtime files from the lower ROM payload region.
- - Extracted files include KERNEL, GDI, USER, drivers, fonts, MCI drivers, and utilities.
- - These are ROMable NE modules, not normal DOS MZ executables.
- Handoff
- - MINWIN reaches this region through a pointer path observed in earlier analysis.
- - VISENV should model B: file table awareness before attempting real Windows startup.
- TODO for future source-quality reconstruction:
- - Insert exact byte offsets and instructions from the production ROM listing.
- - Preserve these English comments next to the corresponding code.
- - Mark uncertain labels as `suspected_` rather than overclaiming.
