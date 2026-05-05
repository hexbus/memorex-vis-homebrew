; Annotated listing reference: 03-command-dispatcher
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; COMMAND Dispatcher
; ==================
;
; ROM range:        0xDC3C0-0xDC45F
; Entry model:      DC3C:0000
; VIS-specific role:Custom fixed startup dispatcher, not DOS COMMAND.COM.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   COMMAND is the smallest and clearest VIS-specific module. It is not a command shell. It is a startup script encoded as ROM-resident code that launches the runtime modules in order.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Startup sequence
; ---------------------------------------------------------------------------
; - EXEC `mscdex`
; - EXEC `gbios`
; - EXEC `redir`
; - EXEC `roma`
; - EXEC `romb`
; - Loop EXEC `tlaunch`.


; ---------------------------------------------------------------------------
; Why this matters
; ---------------------------------------------------------------------------
; - This is where the VIS runtime stack is assembled.
; - TLAUNCH is deliberately run after media, VISBIOS, redirector, and external-ROM probe services are installed.
; - MINWIN is present as an export but is not run here; TLAUNCH invokes it later after CONTROL.TAT validation.


; ---------------------------------------------------------------------------
; VISENV implication
; ---------------------------------------------------------------------------
; - This is the first module VISENV can model completely.
; - It should remain deterministic and fixed-sequence.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
