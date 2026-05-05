; Annotated listing reference: 09-tlaunch
; ---------------------------------------------------------------------------
; IMPORTANT:
;   This file is a ROM-addressed annotated deep-dive reference, not a
;   byte-perfect reconstructed source file. Exact instruction bytes should be
;   verified against the production ROM and promoted here chunk by chunk.
;
;   The goal is to keep engineering comments adjacent to the ROM behavior so
;   developers can correlate notes with offsets, stubs, and VISENV behavior.
; ---------------------------------------------------------------------------

; TLAUNCH Title Launcher
; ======================
;
; ROM range:        0xE9880-0xF3FFF
; Entry model:      E988:0000
; VIS-specific role:Media loop, CONTROL.TAT validator path, and title handoff.
; Confidence:       high for role/sequence, medium for exact unlabelled routine names
;
; Summary:
;   TLAUNCH is the visible gatekeeper. It waits for disc/cartridge media, opens `A:\CONTROL.TAT`, validates title data, and launches either a DOS executable or `minwin b:` for Modular Windows titles.
;
; Stub contract:
;   VISENV should model externally visible behavior first. Raw ROM execution
;   should use original bytes unchanged and keep adaptation in the loader/shim.
;

; ---------------------------------------------------------------------------
; Media loop
; ---------------------------------------------------------------------------
; - Displays/uses the Insert disc or cartridge state.
; - Attempts to open A:\CONTROL.TAT via DOS file services.
; - Distinguishes waiting state from invalid-disc state.


; ---------------------------------------------------------------------------
; Validation
; ---------------------------------------------------------------------------
; - Known registration payload area at CONTROL.TAT +0x98.
; - Known MAKETAT/version marker area around +0xB0.
; - Production validator anchor around 0xEC290.


; ---------------------------------------------------------------------------
; EXEC categories
; ---------------------------------------------------------------------------
; - Real media executable launch.
; - Fake/probe launch: A:\FRANKS_UNLIKELY.EXE.
; - Title/minwin launch after validation.
; - ROM export launch for minwin.

;
; TODO for future source-quality reconstruction:
; - Insert exact byte offsets and instructions from the production ROM listing.
; - Preserve these English comments next to the corresponding code.
; - Mark uncertain labels as `suspected_` rather than overclaiming.
;
