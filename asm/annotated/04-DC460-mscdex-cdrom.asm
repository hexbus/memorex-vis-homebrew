; ===========================================================================
; 04 - MSCDEX / CD-ROM Runtime Layer
; ===========================================================================
; ROM range: 0xDC460-0xE157F
; Entry model: Launched by COMMAND as EXEC "mscdex".
;
; VIS-specific role:
;   Installs CD-ROM/DOS file services so later code can access A: and TLAUNCH can open A:\CONTROL.TAT.
;
; Dependencies:
;   COMMAND dispatcher; DOS INT 21h/2Fh vector substrate.
;
; VISENV stub guidance:
;   VISENV should fake enough A: filesystem behavior to open/read CONTROL.TAT and log other CD-ROM calls.
;
; Confidence:
;   High for role and hook locations; medium for detailed CD driver internals.
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

;-------------------------------------------------------------------------------
; Memorex / Tandy VIS ROM Runtime
; MSCDEX / CD-ROM resident service module
;
; ROM physical range:  DC460h-E157Fh
; D8800 export name:   MSCDEX
; Export entry target: DC460h, with install/startup code later in the segment
;
; Developer summary
; -----------------
; MSCDEX is the first resident runtime module launched by the custom VIS COMMAND
; dispatcher:
;
;     EXEC "mscdex"
;     EXEC "gbios"
;     EXEC "redir"
;     EXEC "roma"
;     EXEC "romb"
;     forever EXEC "tlaunch"
;
; This is not simply a disk file named MSCDEX.EXE. It is a ROM-resident service
; segment launched through the VIS ROM EXEC resolver. It carries Microsoft MSCDEX
; strings, CD-ROM / ISO-9660 messages, and installs DOS multiplex/file-service
; hooks. In VIS terms, this module helps create the DOS-level CD-ROM environment
; that later lets TLAUNCH open A:\CONTROL.TAT.
;
; VIS-specific significance
; -------------------------
; A normal PC would usually load a CD-ROM block driver in CONFIG.SYS and then load
; MSCDEX.EXE from AUTOEXEC.BAT. The VIS does not boot from a normal disk and does
; not run a normal AUTOEXEC.BAT before the launcher. Instead, the D8800 option ROM
; builds a ROM DOS-like environment and COMMAND launches this ROM MSCDEX module by
; bare name. The ROM EXEC resolver resolves "mscdex" from the D8800 export table.
;
; For a VISENV / DOSBox rehosting project, this module is important because it is
; probably where the CD-ROM-facing DOS API behavior starts. A first stub can fake
; success and expose A: as a host directory. A later stub should implement enough
; INT 21h / INT 2Fh behavior to satisfy TLAUNCH and Modular Windows.
;-------------------------------------------------------------------------------

MSCDEX_BASE             equ 0DC460h
MSCDEX_END              equ 0E157Fh
MSCDEX_INT21_HANDLER    equ 0DF4FBh     ; DC460h + 309Bh
MSCDEX_INSTALL_MAIN     equ 0E01BEh

;-------------------------------------------------------------------------------
; Exported segment beginning / resident data region
;-------------------------------------------------------------------------------
DC460:  ; raw module begins here
        ; The D8800 export resolver transfers to the MSCDEX export target. This
        ; segment is not laid out like a normal DOS EXE. The early portion contains
        ; a mix of resident data, tables, strings, and handler glue. Do not treat
        ; every byte from DC460 as linear startup code.

DC5CC:  db 'CDROM',0
DC5D2:  db 'CD001',0
        ; 'CD001' is the ISO-9660 standard volume descriptor signature. The nearby
        ; CDR103 error string explicitly mentions High Sierra / ISO-9660. That
        ; strongly identifies this module as the CD-ROM filesystem layer TLAUNCH
        ; ultimately relies on when it opens A:\CONTROL.TAT.

DC5DC:  db '\NEWELL.DAN',0
        ; A curious embedded path/name. Current status: likely inherited debug,
        ; test, or developer string from the MSCDEX/CD-ROM codebase. It should be
        ; documented, but not assumed to be a VIS title path.

DC63D:  db 'EMMXXXX0',0
        ; Legacy EMS/XMS style marker used by Microsoft-era drivers. In this ROM
        ; environment it is part of the resident MSCDEX heritage rather than a
        ; normal CONFIG.SYS-loaded memory manager path.

DC6D8:  db 'CDR100: Unknown error',0
DC6EE:  db 'CDR101: Not ready',0
DC700:  db 'CDR102: EMS memory no longer valid',0
DC723:  db 'CDR103: CDROM not High Sierra or ISO-9660 format',0
DC754:  db 'CDR104: Door open',0
        ; CD-ROM runtime error table. For VISENV, these strings are useful for
        ; identifying failure paths when the CD-ROM side of the environment is not
        ; satisfied.

DCC0C:  db 'Cannot share drives',0
DCC21:  db 'Incorrect DOS version',0
DCC38:  db 'MSCDEX Version %d.%d already started',0
DCC5E:  db 'MSCDEX Version %d.%d',0
DCC74:  db 'Copyright (C) Microsoft Corp. 1986, 1987, 1988, 1989, 1990. All rights reserved.',0
DCCC6:  db 'Unable to load translated messages',0
        ; This looks like Microsoft MSCDEX code adapted into the VIS ROM. The VIS-
        ; specific part is how it is launched and resident from ROM rather than as
        ; a normal disk EXE.

;-------------------------------------------------------------------------------
; Candidate install / relocation startup path
;-------------------------------------------------------------------------------
E01BE:  mov     si,0100h
        mov     cx,0B80h
        ; Copies a resident block starting at offset 0100h. This is one of the
        ; reasons a naive COM/EXE wrapper is not enough: the ROM module expects a
        ; very particular process/segment layout created by the VIS boot core.

E01C4:  mov     ax,cx
E01C6:  sub     cx,si
E01C8:  shr     ax,1
E01CA:  shr     ax,1
E01CC:  shr     ax,1
E01CE:  shr     ax,1
E01D0:  mov     bx,cs
E01D2:  sub     bx,ax
E01D4:  mov     ds,bx
E01D6:  mov     di,0100h
E01D9:  cld
E01DA:  rep     movsb
        ; Current interpretation: copy/relocate resident data/code so the module
        ; can stay resident and service interrupts. The exact source/destination
        ; relationship still needs full verification under an emulator/logger.

E01DC:  mov     ax,es
E01DE:  mov     ds,ax
E01E0:  mov     ss,ax
E01E2:  mov     [023Ch],ax
E01E5:  mov     [023Ah],di
E01E9:  mov     [096Ch],ax
E01EC:  mov     word ptr [096Ah],0970h
E01F2:  mov     sp,071Ch
E01F5:  mov     bp,sp
        ; Sets DS/SS/SP into the resident/runtime segment. VISENV needs to model
        ; this closely if it attempts to execute the original ROM module instead
        ; of replacing it with a stub.

E0200:  mov     ah,49h
E0202:  int     21h
        ; DOS free memory block. Likely frees the inherited environment block or
        ; installation-time allocation. In VIS, this is handled by the ROM DOS-like
        ; substrate, not by a conventional DOS boot from disk.

;-------------------------------------------------------------------------------
; Initialization calls before installing hooks
;-------------------------------------------------------------------------------
E0214:  call    E031D_GET_DOS_LISTS
E0217:  call    E0372_CHECK_DOS_MSCDEX_ENV
E021A:  call    E044D_MISC_DOS_STATE_SETUP
E021D:  call    E073B_UNRESOLVED_INIT
E0220:  call    E0C73_UNRESOLVED_INIT
E0223:  call    E095E_UNRESOLVED_INIT
E0226:  call    E0EC2_UNRESOLVED_INIT
E0229:  call    E1288_UNRESOLVED_INIT
        ; These are still open naming targets. For the Git reference, keep them as
        ; named anchors and refine as the routines are understood.

;-------------------------------------------------------------------------------
; Install INT 21h hook
;-------------------------------------------------------------------------------
E022C:  cmp     word ptr [077Eh],0000h
E0231:  je      E0250_AFTER_INT21_HOOK

E0233:  mov     ax,3521h
E0236:  int     21h
        ; Get old INT 21h vector. This is the strongest anchor for MSCDEX's DOS
        ; service interception role.

E0238:  push    ds
E0239:  mov     ax,cs
E023B:  mov     ds,ax
E023D:  mov     cs:[3097h],bx
E0242:  mov     cs:[3099h],es
        ; Save previous INT 21h handler at CS:3097/3099 so the resident handler
        ; can chain unhandled calls.

E0247:  mov     dx,309Bh
E024A:  mov     ax,2521h
E024D:  int     21h
        ; Install new INT 21h vector = CS:309Bh.
        ; Physical target: MSCDEX_BASE + 309Bh = DF4FBh.
        ; This handler is a high-priority target for a future fully commented pass.

E024F:  pop     ds

E0250_AFTER_INT21_HOOK:
        ; Continued init: prints/version handling, file-handle cleanup, INT 2Fh
        ; install, and CD-ROM multiplex setup.

;-------------------------------------------------------------------------------
; Install INT 2Fh hook helper
;-------------------------------------------------------------------------------
E02A0_INSTALL_INT2F_HELPER:
E02A3:  mov     ax,352Fh
E02A6:  int     21h
        ; Get old INT 2Fh vector.

E02A8:  mov     si,[bp+06h]
E02AB:  mov     [si],bx
E02AD:  mov     [si+02h],es
        ; Save old vector into caller-provided storage.

E02B0:  mov     ax,252Fh
E02B3:  mov     dx,[bp+04h]
E02B6:  int     21h
        ; Install new INT 2Fh handler at CS:DX.
        ; INT 2Fh is the DOS multiplex interrupt used by MSCDEX and Windows-era
        ; resident services. This fits the documented Modular Windows/MS-DOS
        ; function support model and the VIS runtime hook chain.

E02BB:  ret     0004h

;-------------------------------------------------------------------------------
; DOS/system-list and MSCDEX environment checks
;-------------------------------------------------------------------------------
E031D_GET_DOS_LISTS:
E031D:  mov     ah,52h
E031F:  int     21h
        ; DOS 'get list of lists'. MSCDEX uses this on normal PCs to locate DOS
        ; internals. The VIS boot core must provide enough DOS internal structure
        ; for this to work.
E0321:  mov     [071Ch],es
E0325:  mov     ax,es:[0004h]
E0329:  mov     [071Eh],ax
        ; Stores DOS internal pointers for later use.
E0371:  ret

E0372_CHECK_DOS_MSCDEX_ENV:
E0372:  mov     ah,30h
E0374:  int     21h
        ; Get DOS version. The ROM module still checks DOS compatibility even
        ; though it is running under the VIS ROM DOS-like core.
E0376:  xchg    al,ah
E0378:  cmp     ax,030Ah
E037B:  jb      E038E_BAD_DOS
E037D:  cmp     ax,0600h
E0380:  jge     E038E_BAD_DOS
        ; Accepts DOS versions in an MSCDEX-era range.

E0412:  mov     ax,0DADAh
E0415:  push    ax
E0416:  mov     ax,1100h
E0419:  int     2Fh
        ; Standard-looking MSCDEX installation/multiplex check. If another MSCDEX
        ; is already present, this branch helps avoid duplicate installation.
E041B:  pop     bx
E041C:  cmp     al,0FFh
E041E:  jne     E044C_RETURN

E0426:  mov     ax,150Ch
E0429:  xor     bx,bx
E042B:  int     2Fh
        ; CD-ROM/MSCDEX multiplex style query. This helps identify the module as
        ; a real MSCDEX-derived resident service, not merely a Tandy wrapper.

E044C_RETURN:
E044C:  ret

;-------------------------------------------------------------------------------
; Misc DOS state setup: DTA/search behavior and restoring INT 2Fh
;-------------------------------------------------------------------------------
E044D_MISC_DOS_STATE_SETUP:
E044D:  cmp     word ptr [077Eh],0000h
E0452:  jne     E0455_DO_SETUP
E0454:  ret

E0455_DO_SETUP:
E0470:  mov     ax,2F00h
E0473:  int     21h
        ; Get current DTA.

E0477:  mov     ax,1A00h
E047A:  mov     dx,0781h
E047D:  int     21h
        ; Set DTA to MSCDEX local buffer.

E047F:  mov     ax,4F00h
E0482:  int     21h
        ; Find-next style call. Exact purpose needs more study, but it is classic
        ; DOS filesystem machinery.

E0484:  mov     ax,1A00h
E0489:  int     21h
        ; Restore previous DTA.

E049C:  mov     ax,252Fh
E049F:  lds     dx,[0221h]
E04A3:  int     21h
        ; Restores or changes INT 2Fh vector depending on the path. This is part
        ; of setup/cleanup around the multiplex install check.
E04BE:  ret

;-------------------------------------------------------------------------------
; Command-tail / option parser area
;-------------------------------------------------------------------------------
E04C9:  push    bp
        ; The following routine parses the command tail / options. It recognizes
        ; slash-prefixed options and numeric values. This matches MSCDEX heritage
        ; options such as /D:name and /M:n, but the VIS ROM launch does not require
        ; a normal AUTOEXEC.BAT line. COMMAND simply EXECs the bare ROM export
        ; name "mscdex" and the resident code uses ROM defaults/internal state.

;-------------------------------------------------------------------------------
; Still to fully comment
;-------------------------------------------------------------------------------
; DF4FB  INT 21h resident handler installed above
; E02CE  INT 2Fh handler path for selected AX values
; E073B+ CD-ROM/driver data structure setup
; E0C73+ drive/device registration
; E0EC2+ filesystem / ISO-9660 support path
; E1288+ final resident state setup
;
; These should be the focus of the next MSCDEX-specific pass if we need exact
; CD-ROM API emulation. For VISENV v0.1, a stub can likely bypass most of this
; by providing a host-backed A: directory and enough INT 21h open/read behavior
; for TLAUNCH to find CONTROL.TAT.
;-------------------------------------------------------------------------------
