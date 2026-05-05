; Critical VIS Boot Chunks
; ========================
;
; These chunks are the examples the guide should follow: exact ROM addresses,
; plain English meaning, and VIS-specific interpretation.
;
; NOTE: Byte values should be verified against the production ROM before
; converting these snippets into final byte-perfect source listings.

; ---------------------------------------------------------------------------
; ROM: D9433-D9449
; Purpose: Boot core launches COMMAND through the VIS ROM EXEC path.
; VIS-specific meaning:
;   This does not load COMMAND.COM. It calls the ROM-enhanced INT 21h AH=4Bh
;   path with a bare name. The resolver maps COMMAND to the D8800 export table.
; ---------------------------------------------------------------------------
D9433:  BA 58 01        mov dx,0158h      ; DS:DX -> "COMMAND"
D9446:  B4 4B           mov ah,4Bh        ; DOS EXEC function
D9449:  CD 21           int 21h           ; VIS ROM EXEC resolver handles bare name

; ---------------------------------------------------------------------------
; ROM: DC3C0 module
; Purpose: COMMAND startup dispatcher.
; VIS-specific meaning:
;   Fixed ROM startup sequence. Not DOS COMMAND.COM.
; ---------------------------------------------------------------------------
;   EXEC "mscdex"
;   EXEC "gbios"
;   EXEC "redir"
;   EXEC "roma"
;   EXEC "romb"
;   loop EXEC "tlaunch"

; ---------------------------------------------------------------------------
; ROM: TLAUNCH CONTROL.TAT path
; Purpose: Open/read title control file.
; VIS-specific meaning:
;   CONTROL.TAT is the VIS title gate. AH=3Dh/3Fh read it. AH=4Bh later
;   executes the validated title or MINWIN handoff.
; ---------------------------------------------------------------------------
;   INT 21h AH=3Dh -> open A:\CONTROL.TAT
;   INT 21h AH=3Fh -> read CONTROL.TAT
;   validator around EC290
;   INT 21h AH=4Bh -> launch selected title command or minwin b:
