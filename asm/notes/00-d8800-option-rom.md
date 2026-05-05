# 00 D8800 Option Rom

This note explains the module role in plain English. The corresponding annotated assembly file is in `asm/annotated/`.

## Source status

Production ROM disassembly remains the source of truth. These notes are engineering explanations aligned to known ROM ranges and behavior.

## Notes

- D8800 VIS Option ROM and Export Table
- ROM range:        0xD8800-0xD895F
- Entry model:      D880:0000
- VIS-specific role:PC BIOS option-ROM scan enters the VIS runtime root.
- Confidence:       high for role/sequence, medium for exact unlabelled routine names
- Summary:
- This module begins with the normal PC option-ROM marker `55 AA`, but the behavior after discovery is VIS-specific. The option ROM exposes a named export table and installs/customizes the boot handoff so the system does not boot a normal floppy/hard disk DOS. It enters the VIS ROM DOS-like substrate at D8960.
- Stub contract:
- VISENV should model externally visible behavior first. Raw ROM execution
- should use original bytes unchanged and keep adaptation in the loader/shim.
- Header
- - 55 AA size byte marks a BIOS option ROM.
- - The Phoenix BIOS can discover this through normal option-ROM scanning.
- - The VIS-specific part is what the ROM does after discovery: it becomes the operating-system bootstrap root.
- Export table
- - Names include COMMAND, MSCDEX, MINWIN, GBIOS, REDIR, TLAUNCH, ROMA, ROMB.
- - Each entry is a name plus a transfer stub, not an MZ/COM file.
- - The ROM EXEC resolver later scans these entries when it sees bare EXEC names.
- Boot customization
- - Normal PC behavior would eventually invoke INT 19h to boot disk media.
- - VIS behavior redirects that boot path into the ROM-resident D8960 boot core.
- - This is why the VIS can boot without a normal disk drive.
- TODO for future source-quality reconstruction:
- - Insert exact byte offsets and instructions from the production ROM listing.
- - Preserve these English comments next to the corresponding code.
- - Mark uncertain labels as `suspected_` rather than overclaiming.
