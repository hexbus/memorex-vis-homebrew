; Annotated listing reference: 01-d8960-boot-core
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; D8960 Boot Core and EXEC COMMAND
; ================================
;
; ROM range:        0xD8960-0xDC3BF
; Entry model:      D896:0000
; VIS-specific role:ROM DOS-like substrate starts here after D8800 handoff.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   The boot core creates enough DOS-like process and interrupt behavior to use `INT 21h AH=4Bh` against the bare name `COMMAND`. This is the bridge between the option-ROM boot takeover and the fixed COMMAND dispatcher.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Resident setup
; ---------------------------------------------------------------------------
; - Sets up DOS-like vectors/state used by later modules.
; - Contains command-interpreter and CONFIG-style strings, but this is not a normal disk DOS boot.
; - Earlier analysis found vector setup consistent with INT 20h/21h/22h/27h style process behavior.


; ---------------------------------------------------------------------------
; EXEC COMMAND
; ---------------------------------------------------------------------------
; - The boot core issues `INT 21h AH=4Bh` with DS:DX pointing at `COMMAND`.
; - This proves COMMAND itself is launched through the custom ROM EXEC path.
; - The target is not COMMAND.COM on disk; it resolves through the D8800 export table.


; ---------------------------------------------------------------------------
; VISENV implication
; ---------------------------------------------------------------------------
; - VISENV must model EXEC before it can model COMMAND startup.
; - A direct attempt to run COMMAND as a standalone EXE skips this substrate.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
