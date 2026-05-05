; Annotated listing reference: 02-rom-exec-resolver
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; ROM EXEC Resolver
; =================
;
; ROM range:        around 0xD9FEC-0xDA162
; Entry model:      called by INT 21h AH=4Bh path
; VIS-specific role:Custom resolver maps bare executable names to D8800 ROM exports.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   This is the heart of the VIS boot model. A normal DOS `EXEC` loads a disk file. The VIS boot core extends the behavior: path-qualified names are treated as media files, while bare names are searched in ROM export tables.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Classification
; ---------------------------------------------------------------------------
; - Bare names such as `gbios` or `tlaunch` are ROM export launches.
; - Path-qualified names such as `A:\SCREEN.EXE` are media executable launches.
; - `A:\FRANKS_UNLIKELY.EXE` is a fake/probe executable used by TLAUNCH.


; ---------------------------------------------------------------------------
; Export scan
; ---------------------------------------------------------------------------
; - The resolver scans the D8800 export table.
; - Case-insensitive matching appears likely from the observed name handling.
; - On match, it builds the transfer context for the module entry.


; ---------------------------------------------------------------------------
; Stub contract
; ---------------------------------------------------------------------------
; - VISENV must reproduce this classification exactly enough for homebrew testing.
; - The resolver should not modify raw ROM segments; it should route calls to stubs or loaders.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
