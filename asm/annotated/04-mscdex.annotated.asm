; Annotated listing reference: 04-mscdex
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; MSCDEX / CD-ROM Service Layer
; =============================
;
; ROM range:        0xDC460-0xE157F
; Entry model:      DC46:0000
; VIS-specific role:Installs CD-ROM/media services before TLAUNCH reads A:\CONTROL.TAT.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   MSCDEX is the first runtime service launched by COMMAND. It establishes the CD-ROM/media path that TLAUNCH later depends on for `A:\CONTROL.TAT`.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Installed services
; ---------------------------------------------------------------------------
; - Hooks/participates in INT 21h file behavior.
; - Hooks/participates in INT 2Fh multiplex behavior.
; - Represents a ROM-resident CD-ROM setup instead of CONFIG.SYS/AUTOEXEC loading.


; ---------------------------------------------------------------------------
; Homebrew relevance
; ---------------------------------------------------------------------------
; - Homebrew disc layout must satisfy the A: media view that TLAUNCH sees.
; - VISENV should answer open/read requests for A: through a virtual media folder.


; ---------------------------------------------------------------------------
; Stub priority
; ---------------------------------------------------------------------------
; - Implement INT 21h open/read/EXEC first.
; - Deeper CD-ROM control calls can remain logged stubs initially.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
