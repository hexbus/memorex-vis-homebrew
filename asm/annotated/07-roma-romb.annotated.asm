; Annotated listing reference: 07-roma-romb
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; ROMA / ROMB External ROM Probes
; ===============================
;
; ROM range:        ROMA C000 probe; ROMB C400 probe
; Entry model:      C000:0000 / C400:0000 if present
; VIS-specific role:Small probes for external ROM windows.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   ROMA and ROMB are small but useful for early raw-module experimentation. They probe external ROM address windows for an `ER` signature and transfer if present.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; ROMA
; ---------------------------------------------------------------------------
; - Probes C000:0000.
; - Expected signature appears to be `ER`.
; - Likely related to external ROM, development card, cartridge, or expansion boot support.


; ---------------------------------------------------------------------------
; ROMB
; ---------------------------------------------------------------------------
; - Probes C400:0000.
; - Expected signature appears to be `ER`.
; - Likely second external ROM window.


; ---------------------------------------------------------------------------
; VISENV implication
; ---------------------------------------------------------------------------
; - These are the safest first raw-module-loader experiments.
; - A stub can simply report signature present/absent.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
