; Annotated listing reference: 06-redir
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; REDIR Runtime Config / Redirector
; =================================
;
; ROM range:        0xE8AD0-0xE987F
; Entry model:      E8AD:0000
; VIS-specific role:Runtime redirector and embedded configuration provider.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   REDIR is not just a random blob containing SYSTEM.INI text. It participates in runtime configuration and redirector behavior, and it depends on services established by GBIOS.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Installed services
; ---------------------------------------------------------------------------
; - INT 6Fh redirector/config provider behavior.
; - INT 15h dependency/call-through to GBIOS.
; - INT 2Fh runtime multiplex integration.


; ---------------------------------------------------------------------------
; Embedded config
; ---------------------------------------------------------------------------
; - Contains default SYSTEM.INI-style configuration.
; - Includes shell and driver entries consistent with Modular Windows runtime expectations.


; ---------------------------------------------------------------------------
; VISENV implication
; ---------------------------------------------------------------------------
; - VISENV can initially serve a default SYSTEM.INI through this stub.
; - Later passes should model actual REDIR request formats.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
