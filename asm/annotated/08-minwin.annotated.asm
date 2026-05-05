; Annotated listing reference: 08-minwin
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; MINWIN Modular Windows Starter
; ==============================
;
; ROM range:        0xE1580-0xE165F
; Entry model:      E158:0000
; VIS-specific role:Bridge from TLAUNCH to Modular Windows.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   MINWIN is not launched by COMMAND. It is invoked after TLAUNCH has validated CONTROL.TAT and decided to start a Modular Windows title. The observed handoff points into the F4000 ROMWINTOC loader area.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Role
; ---------------------------------------------------------------------------
; - Processes the `minwin b:` style command.
; - Bridges from VIS title authorization to Modular Windows runtime startup.
; - Uses the ROMWINTOC B: runtime environment.


; ---------------------------------------------------------------------------
; VISENV implication
; ---------------------------------------------------------------------------
; - Initially log the F4000 handoff.
; - Later model B: file lookup, SYSTEM.INI selection, and shell= startup.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
