; ===========================================================================
; 03 - COMMAND Startup Dispatcher
; ===========================================================================
; ROM range: 0xDC3C0-0xDC45F
; Entry model: Launched by D8960 via EXEC "COMMAND" and ROM export resolution.
;
; VIS-specific role:
;   Custom fixed startup script, not DOS COMMAND.COM. It loads resident VIS modules in order, then loops forever running TLAUNCH.
;
; Dependencies:
;   ROM EXEC resolver working; DOS-like PSP/memory environment.
;
; VISENV stub guidance:
;   Excellent first integration test. VISENV should simulate this sequence even before running the raw dispatcher.
;
; Confidence:
;   High.
;
; ---------------------------------------------------------------------------
; VIS annotated-source style
; ---------------------------------------------------------------------------
; This is not intended to be reassembled as-is. It is source-style commented
; disassembly for engineering analysis and VISENV implementation.
;
; Comment conventions:
;   CONFIRMED  = directly observed in code/data.
;   HYPOTHESIS = likely interpretation that still needs runtime proof.
;   VISENV     = requirement or shortcut for a DOSBox/MS-DOS shim.
; ---------------------------------------------------------------------------

; Module: COMMAND dispatcher
; ROM range: DC3C0-DC45F
; Role: fixed VIS runtime startup script
; Entry model: D8960 boot core EXECs bare name "COMMAND"; ROM EXEC resolver finds D8800 export and enters DC3C:0000.
; VIS-specific significance:
;   This is not DOS COMMAND.COM. It is a tiny ROM-resident dispatcher that starts the VIS service modules.
;   It depends on the custom ROM EXEC resolver, because names like "mscdex" and "gbios" are not disk files.
; Stub priority: highest. This is the simplest complete proof of the ROM EXEC mechanism.
;
; Register/segment expectations:
;   CS = DC3C on entry.
;   DS is explicitly set to CS before EXEC calls so DS:DX points to strings in this module.
;   A DOS-like PSP/process environment already exists, because the module calls INT 21h AH=4Ah to resize its memory block.
;
; VISENV implication:
;   VISENV must allow this module to call INT 21h AH=4Bh with bare names and resolve them through the D8800 export table.

; ---------------------------------------------------------------------------
; SECTION: Entry and local data
; ---------------------------------------------------------------------------
DC3C0:  EB 40                 jmp short DC402_entry
DC3C2:  90                    nop
DC3C3:  00 00 00 00           db 0,0,0,0

; These are command names used by the dispatcher.
; They are decoded as data, not instructions. Earlier linear disassemblies showed bogus INS/OUTS instructions here.
DC3C7_mscdex:      db 'mscdex',0
DC3CE_redir:       db 'redir',0
DC3D4_minwin:      db 'minwin',0       ; Present but not launched by COMMAND. TLAUNCH uses MINWIN later after CONTROL.TAT validation.
DC3DB_gbios:       db 'gbios',0
DC3E1_tlaunch:     db 'tlaunch',0
DC3E9_roma:        db 'roma',0
DC3EE_romb:        db 'romb',0
DC3F3_screen_test: db 'a:\screen.exe',0 ; Development/test leftover. Not part of the normal dispatcher sequence seen here.

; ---------------------------------------------------------------------------
; SECTION: Process setup
; ---------------------------------------------------------------------------
DC402_entry:
DC402:  8C 0E 00 01           mov  [0100h],cs
; CONFIRMED: Stores CS into local offset 0100h. This appears to contribute to a small EXEC parameter block.
; HYPOTHESIS: The ROM EXEC resolver may use this as part of the DOS-compatible EXEC parameter block or inherited environment.

DC406:  B8 00 4A              mov  ax,4A00h
DC409:  BB 11 00              mov  bx,0011h
DC40C:  CD 21                 int  21h
; INT 21h AH=4Ah RESIZE MEMORY BLOCK
; VIS meaning:
;   COMMAND is running as a DOS-like process created by the D8960 boot core. It shrinks its allocation to 0x11 paragraphs.
; Stub implication:
;   VISENV cannot just far-jump here with no PSP/memory-control-block concept if this code is to run unmodified.

DC40E:  8C C8                 mov  ax,cs
DC410:  8E D8                 mov  ds,ax
; CONFIRMED: DS=CS. All subsequent DS:DX command strings are local to this dispatcher segment.

; ---------------------------------------------------------------------------
; SECTION: Startup module sequence
; ---------------------------------------------------------------------------
; Each block uses INT 21h AH=4Bh EXEC, but the target is a bare ROM export name.
; These are not files named MSCDEX.EXE or GBIOS.EXE on the CD.
; The ROM EXEC resolver should scan the D8800 export table and enter the matching ROM segment.

; --- EXEC "mscdex" ----------------------------------------------------------
DC412:  BA 07 00              mov  dx,offset DC3C7_mscdex
DC415:  BB 00 01              mov  bx,0100h
DC418:  B8 00 4B              mov  ax,4B00h
DC41B:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "mscdex"
; Expected resolver result: enter MSCDEX/CD-ROM module at DC460:0000.
DC41D:  72 32                 jb   DC451_halt_on_failure

; --- EXEC "gbios" -----------------------------------------------------------
DC41F:  B8 00 4B              mov  ax,4B00h
DC422:  BA 1B 00              mov  dx,offset DC3DB_gbios
DC425:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "gbios"
; Expected resolver result: enter GBIOS/VIS BIOS Extensions at E1660:0000.
DC427:  72 28                 jb   DC451_halt_on_failure

; --- EXEC "redir" -----------------------------------------------------------
DC429:  B8 00 4B              mov  ax,4B00h
DC42C:  BA 0E 00              mov  dx,offset DC3CE_redir
DC42F:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "redir"
; Expected resolver result: enter REDIR/runtime configuration module at E8AD0:0000.
DC431:  72 1E                 jb   DC451_halt_on_failure

; --- EXEC "roma" ------------------------------------------------------------
DC433:  B8 00 4B              mov  ax,4B00h
DC436:  BA 29 00              mov  dx,offset DC3E9_roma
DC439:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "roma"
; Expected behavior: probe/transfer to optional external ROM region around C000:0000 if signature is present.
DC43B:  72 14                 jb   DC451_halt_on_failure

; --- EXEC "romb" ------------------------------------------------------------
DC43D:  B8 00 4B              mov  ax,4B00h
DC440:  BA 2E 00              mov  dx,offset DC3EE_romb
DC443:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "romb"
; Expected behavior: probe/transfer to optional external ROM region around C400:0000 if signature is present.
DC445:  72 0A                 jb   DC451_halt_on_failure

; ---------------------------------------------------------------------------
; SECTION: Permanent TLAUNCH loop
; ---------------------------------------------------------------------------
DC447_loop_tlaunch:
DC447:  B8 00 4B              mov  ax,4B00h
DC44A:  BA 21 00              mov  dx,offset DC3E1_tlaunch
DC44D:  CD 21                 int  21h
; INT 21h AH=4Bh EXEC
; VIS classification: ROM_EXPORT_EXEC
; Target: "tlaunch"
; Meaning:
;   At this point resident VIS services have been installed. COMMAND repeatedly runs TLAUNCH.
;   TLAUNCH is the media/title gatekeeper. It waits for a disc or cartridge, reads CONTROL.TAT, and launches the title.
DC44F:  EB F6                 jmp  short DC447_loop_tlaunch

DC451_halt_on_failure:
DC451:  EB FE                 jmp  short DC451_halt_on_failure
; If any required resident module fails to load, COMMAND hangs here. On the real VIS this likely leaves the unit unusable until reset.

; Stage 27 note:
;   This file remains the readability model for the rest of the module listings.


; ---------------------------------------------------------------------------
; STAGE 36 CANONICAL EXEC CLASSIFICATION
; ---------------------------------------------------------------------------
; All AH=4Bh calls in COMMAND are ROM_EXPORT_EXEC.
;
; They are intentionally bare names, not filenames with .EXE/.COM extensions.
; The D8960 ROM EXEC resolver scans the option-ROM export table and transfers to
; the matching ROM segment. VISENV v0.1 should initially model this sequence
; directly, even before attempting to execute the raw ROM module bodies.
