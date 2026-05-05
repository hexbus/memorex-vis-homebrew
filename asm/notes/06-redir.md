# 06 Redir

This note explains the module role in plain English. The corresponding annotated assembly file is in `asm/annotated/`.

## Source status

Production ROM disassembly remains the source of truth. These notes are engineering explanations aligned to known ROM ranges and behavior.

## Notes

- REDIR Runtime Config / Redirector
- ROM range:        0xE8AD0-0xE987F
- Entry model:      E8AD:0000
- VIS-specific role:Runtime redirector and embedded configuration provider.
- Confidence:       high for role/sequence, medium for exact unlabelled routine names
- Summary:
- REDIR is not just a random blob containing SYSTEM.INI text. It participates in runtime configuration and redirector behavior, and it depends on services established by GBIOS.
- Stub contract:
- VISENV should model externally visible behavior first. Raw ROM execution
- should use original bytes unchanged and keep adaptation in the loader/shim.
- Installed services
- - INT 6Fh redirector/config provider behavior.
- - INT 15h dependency/call-through to GBIOS.
- - INT 2Fh runtime multiplex integration.
- Embedded config
- - Contains default SYSTEM.INI-style configuration.
- - Includes shell and driver entries consistent with Modular Windows runtime expectations.
- VISENV implication
- - VISENV can initially serve a default SYSTEM.INI through this stub.
- - Later passes should model actual REDIR request formats.
- TODO for future source-quality reconstruction:
- - Insert exact byte offsets and instructions from the production ROM listing.
- - Preserve these English comments next to the corresponding code.
- - Mark uncertain labels as `suspected_` rather than overclaiming.
