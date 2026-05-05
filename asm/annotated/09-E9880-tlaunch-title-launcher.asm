; ===========================================================================
; 09 - TLAUNCH Title Launcher and CONTROL.TAT Gatekeeper
; ===========================================================================
; ROM range: 0xE9880-0xF3FFF
; Entry model: COMMAND loops EXEC "tlaunch" forever after resident services are installed.
;
; VIS-specific role:
;   Waits for disc/cartridge, opens and reads A:\CONTROL.TAT, validates title authorization/runtime requirements, then launches DOS title or MINWIN/Modular Windows title.
;
; Dependencies:
;   MSCDEX, GBIOS, REDIR, ROMA/ROMB sequence complete.
;
; VISENV stub guidance:
;   VISENV should provide A:\CONTROL.TAT and classify every EXEC site: fake probe, title/minwin launch, or blocked launch.
;
; Confidence:
;   High for major anchors; medium for complete state machine.
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
; TLAUNCH title/media launcher and CONTROL.TAT gatekeeper
;
; ROM physical range:  E9880h-F3FFFh
; D8800 export name:   TLAUNCH
; Export entry target: E9880h
;
; Developer summary
; -----------------
; TLAUNCH is the VIS-specific title launcher. After the D8800 option ROM takes
; over boot, the custom ROM COMMAND dispatcher installs the runtime modules in
; this order:
;
;     EXEC "mscdex"
;     EXEC "gbios"
;     EXEC "redir"
;     EXEC "roma"
;     EXEC "romb"
;     forever EXEC "tlaunch"
;
; This module is the final steady-state loop. It waits for valid media, opens
; A:\CONTROL.TAT, validates the VIS title-control data, and then launches either
; a DOS title command or the Modular Windows path, commonly "minwin b:".
;
; VIS-specific significance
; -------------------------
; A normal PC BIOS would boot a disk and let DOS/AUTOEXEC/COMMAND.COM control
; startup. The VIS does not. The D8800 option ROM builds a ROM DOS-like
; environment, launches custom resident modules by bare-name EXEC, and then loops
; TLAUNCH. TLAUNCH is the policy gate that prevents arbitrary media execution
; until CONTROL.TAT has been accepted.
;
; For VISENV / DOSBox rehosting, TLAUNCH is the integration test. If VISENV can
; run enough of MSCDEX, GBIOS, REDIR, ROMA/ROMB, and the ROM EXEC resolver for
; TLAUNCH to reach the media prompt, open A:\CONTROL.TAT, validate it, and attempt
; "minwin b:", the foundational boot/runtime model is working.
;-------------------------------------------------------------------------------

TLAUNCH_BASE            equ 0E9880h
TLAUNCH_END             equ 0F3FFFh
TLAUNCH_INT21_HOOK      equ 0E9E2Dh
TLAUNCH_INT2F_HOOK      equ 0E9F0Bh
TLAUNCH_CONTROL_OPEN    equ 0EA141h
TLAUNCH_FRANKS_PROBE    equ 0EA380h
TLAUNCH_VALIDATOR       equ 0EC290h
TLAUNCH_VALIDATOR_TABLE equ 0EC358h

;-------------------------------------------------------------------------------
; Section 1: Entry context and resident state
;-------------------------------------------------------------------------------
E9880:
        ; Export target for EXEC "tlaunch".
        ; The ROM EXEC resolver enters this module as a ROM-resident executable
        ; segment, not as a normal DOS MZ/COM file. Existing evidence suggests the
        ; module expects CS and likely DS to be aligned to its own segment so
        ; offsets such as 0B1Ch point to data inside this segment.
        ;
        ; Important: raw disassembly from E9880 includes code, data, bitmaps/
        ; tables, and later DD55 install blocks. The complete objdump reference is
        ; included separately. This source-style file documents the launcher logic
        ; and known anchors.

; Shared state observed by TLAUNCH. These offsets are in the low F5xx area and
; appear to be part of the VIS ROM runtime's shared data block.
TLAUNCH_FLAGS           equ 0F5BEh     ; hook/launcher state flags
TLAUNCH_CLASS_FIELD     equ 0F5C2h     ; decoded CONTROL.TAT/title authorization field
TLAUNCH_FLAGS2          equ 0F5C3h     ; additional decoded title/class flags
OLD_INT2F_OFF           equ 0F5B0h     ; observed old INT 2Fh offset storage
OLD_INT2F_SEG           equ 0F5B2h     ; observed old INT 2Fh segment storage
OLD_INT21_OFF           equ 0F5C8h     ; observed old INT 21h offset storage
OLD_INT21_SEG           equ 0F5CAh     ; observed old INT 21h segment storage

;-------------------------------------------------------------------------------
; Section 2: INT 21h hook / executable guardrail
;-------------------------------------------------------------------------------
E9E2D: pushf
E9E2E: cli
E9E2F: cmp     ah,3Dh
        je      TLAUNCH_INT21_CHECK_OPEN_OR_EXEC
E9E34: cmp     ah,4Bh
        je      TLAUNCH_INT21_CHECK_OPEN_OR_EXEC
        ; Non-open/non-EXEC DOS calls are chained to the previous INT 21h handler.
        ; This makes TLAUNCH a resident filter, not a wholesale DOS replacement.
        ; In VIS terms, it wants to control when programs can be opened/executed,
        ; but otherwise leave the ROM DOS environment intact.

TLAUNCH_CHAIN_OLD_INT21:
        ; Saves registers, restores the old INT 21h vector from F5C8/F5CA, and
        ; IRETs into the previous handler. Exact prologue is in the full objdump.
        ; VISENV requirement: a first stub can log and chain. A stricter stub must
        ; reproduce the carry/AX behavior when TLAUNCH blocks execution.

TLAUNCH_INT21_CHECK_OPEN_OR_EXEC:
        ; Calls filename extension checker at E9EB1.
        ; The checker returns zero when DS:DX names a .COM or .EXE file.
        ; That means TLAUNCH is specifically policing executable launch/open, not
        ; every file access.
        call    TLAUNCH_CHECK_COM_EXE_NAME
        ; If not .COM/.EXE, chain to old INT 21h.
        ; If .COM/.EXE, evaluate launcher flags in F5BE.
        ;
        ; Observed special behavior:
        ;   If executable launch is blocked by TLAUNCH policy, return:
        ;       CF = 1
        ;       AX = 6664h
        ;   This is not a normal DOS error. It is a VIS private status used by the
        ;   FRANKS_UNLIKELY.EXE probe below.

TLAUNCH_BLOCK_EXEC_WITH_MAGIC_STATUS:
        mov     ax,6664h
        ; Set carry in saved flags and IRET.
        ; Developer note: this is the strongest sign that TLAUNCH intentionally
        ; uses DOS EXEC as a policy surface. Real title launches are allowed only
        ; after CONTROL.TAT validation opens the gate.

;-------------------------------------------------------------------------------
; Section 3: .COM/.EXE filename checker
;-------------------------------------------------------------------------------
E9EB1:
TLAUNCH_CHECK_COM_EXE_NAME:
        ; Input:  DS:DX -> filename/path passed to INT 21h AH=3Dh or AH=4Bh
        ; Output: ZF/AL behavior indicates whether the path ends in .COM or .EXE.
        ;
        ; The checker handles drive prefixes such as B: and walks forward until
        ; it sees '.', space, or NUL. It recognizes .COM and .EXE case-insensitively.
        ;
        ; VIS-specific reason this exists:
        ;   TLAUNCH wants CONTROL.TAT and general file reads to pass normally, but
        ;   it wants executable files to be blocked unless the title authorization
        ;   state machine has explicitly allowed them.
        ;
        ; For VISENV:
        ;   Implement this as a policy hook around EXEC/open. It does not have to
        ;   be byte-perfect at first; it must be semantically accurate enough for
        ;   FRANKS_UNLIKELY.EXE and title launch behavior.

;-------------------------------------------------------------------------------
; Section 4: INT 2Fh hook / launcher multiplex behavior
;-------------------------------------------------------------------------------
E9F0B: pushf
        cli
        ; TLAUNCH also hooks INT 2Fh. The current annotated state is less complete
        ; than INT 21h, but the hook clearly participates in the resident launcher
        ; state machine and chains to a previous INT 2Fh vector stored in the F5B0
        ; range.
        ;
        ; VISENV requirement:
        ;   Initially log INT 2Fh calls and preserve chain behavior. Later, decode
        ;   the AH/AL function groups used by Modular Windows, REDIR, MSCDEX, and
        ;   TLAUNCH.

;-------------------------------------------------------------------------------
; Section 5: CONTROL.TAT open/read/validation path
;-------------------------------------------------------------------------------
EA141:
TLAUNCH_OPEN_CONTROL_TAT:
        push    ds
        ; DS is set to TLAUNCH's segment so DX can point at the local string below.
        ; This is why wrapping TLAUNCH as a COM file is wrong: COM would shift
        ; internal data by 0100h and break DX=0D65h style references.
        mov     dx,0D65h              ; DS:DX -> "a:control.tat"
        mov     ax,3D00h              ; INT 21h AH=3Dh, AL=00h: open read-only
        int     21h
        ; If open succeeds, TLAUNCH reads CONTROL.TAT using INT 21h AH=3Fh and
        ; passes authorization bytes to the EC290 validator.
        ;
        ; Important correction:
        ;   AH=4Bh EXEC does not read CONTROL.TAT. CONTROL.TAT is opened/read with
        ;   AH=3Dh/AH=3Fh. AH=4Bh is used later to launch modules or title code.

EA5E5: db 'a:control.tat',0
        ; VIS-specific title-control file. Generic Modular Windows uses AUTOEXEC
        ; and modwin, but VIS discs require CONTROL.TAT as an extra gatekeeper.

;-------------------------------------------------------------------------------
; Section 6: CONTROL.TAT runtime authorization validator
;-------------------------------------------------------------------------------
EC290:
TLAUNCH_CONTROL_TAT_VALIDATOR:
        ; Current understanding:
        ;   - Decodes 12 bytes of CONTROL.TAT authorization data into 24 nibbles.
        ;   - Applies/checks a 16-byte table at EC358.
        ;   - Checks bit-plane patterns.
        ;   - Stores decoded class/title fields into F5C2 and F5C3.
        ;
        ; Relationship to REGISTER/MAKETAT:
        ;   REGISTER.EXE generated a 20-character key from vendor/product/class.
        ;   MAKETAT.EXE validated that key and emitted CONTROL.TAT.
        ;   This runtime validator is the VIS-side check of the title-control data.
        ;
        ; VISENV requirement:
        ;   A practical v0.1 can bypass or stub this as success for known-good
        ;   CONTROL.TAT files. A faithful emulator should implement the nibble
        ;   decoder and class/version checks.

EC358:
TLAUNCH_VALIDATOR_LOOKUP_TABLE:
        db 0Ch, 05h, 09h, 0Fh, 06h, 02h, 00h, 03h, 08h, 0Ah, 0Eh, 07h, 0Bh, 01h, 0Dh, 04h
        ; 16-byte lookup/scramble table used by the CONTROL.TAT runtime validator.
        ; Keep this as data, not instructions.

EC368: db 'Frank Durda IV',0
        ; Developer signature. This likely explains the nearby version tag ending
        ; in "fdiv" rather than an x87 FDIV/floating-point clue.

;-------------------------------------------------------------------------------
; Section 7: Fake/probe executable launch
;-------------------------------------------------------------------------------
EA364:
TLAUNCH_FRANKS_PROBE_SETUP:
        ; This path manipulates TLAUNCH_FLAGS before intentionally trying to EXEC
        ; a deliberately unlikely executable name. The goal appears to be testing
        ; that TLAUNCH's own INT 21h hook is active and will block .EXE launch.

EA380:
TLAUNCH_FRANKS_PROBE_EXEC:
        push    ds
        mov     ax,cs
        mov     ds,ax
        mov     dx,0B1Ch              ; DS:DX -> "a:franks_unlikely.exe"
        mov     ah,4Bh                ; INT 21h AH=4Bh: DOS EXEC
        int     21h
        pop     ds
        ; If the hook works, EXEC fails with private AX=6664h. That value is not
        ; a normal DOS file-not-found error. It is a VIS private result meaning
        ; "the TLAUNCH executable guardrail blocked this as expected."
        ;
        ; Classification: fake/probe executable launch.

EA39C: db 'a:franks_unlikely.exe',0
        ; Almost certainly not a hidden file. It is a developer joke/probe name.

;-------------------------------------------------------------------------------
; Section 8: User-facing launcher messages and title launch command
;-------------------------------------------------------------------------------
EA4DB: db 'Copyright 1992 Tandy Corporation, All Rights Reserved.',0

EA512: db 'Insert a disc or a cartridge.',0
        ; Main steady-state prompt. Reaching this means the ROM runtime modules
        ; have been installed and COMMAND is looping TLAUNCH correctly.

EA530: db 'This disc cannot be used on this system.',0
        ; Shown when CONTROL.TAT/title authorization fails or media is not a valid
        ; VIS title for this player/runtime.

EA559: db 'An upgrade is required to use this disc.',0
        ; Runtime version gate. Earlier analysis saw a five-byte version/capability
        ; comparison between title data and ROM data.

EA582: db '[ ATTENTION: This is an Authorized Video Information System',0
EA5BE: db 'Title. END OF STATEMENT ]',0
        ; Authorized title statement checked under some title/class conditions.
        ; This is where Class A behavior appears to have runtime significance.

EA5DA: db 'minwin b: ',0
        ; Modular Windows starter command. TLAUNCH reaches this after validation
        ; when the title is a Modular Windows title. B: is the ROMWINTOC-backed
        ; Modular Windows runtime drive exposed by the VIS ROM environment.

EA609: db '     Version 1(18) 18-Oct-92 fdiv',0
        ; TLAUNCH version tag. "fdiv" likely identifies Frank Durda IV.

;-------------------------------------------------------------------------------
; Section 9: Adjacent DD55 install/support blocks
;-------------------------------------------------------------------------------
EC390:
        ; DD55 block: XMS/HMA support. Contains XMSXXXX0 and NO XMS. strings.
        ; These blocks live in the broad E9880-F3FFF extraction range. They may be
        ; part of the same ROM image payload used by the TLAUNCH/runtime region,
        ; but should be documented as separate install/support blocks where possible.

ECFB0:
        ; DD55 block: CD.SYS / Mitsumi / Gryphon CD-ROM support.
        ; Contains: "cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h"
        ; and Mitsumi copyright text.
        ;
        ; For final documentation, keep these blocks separate from TLAUNCH proper
        ; unless the boot-core/DD55 loader proves they are entered as part of the
        ; TLAUNCH path.

;-------------------------------------------------------------------------------
; Section 10: Stub contract summary
;-------------------------------------------------------------------------------
; To stub TLAUNCH well enough for homebrew development:
;
; 1. Provide a DOS-like environment where EXEC "tlaunch" reaches E9880:0000.
; 2. Provide A: file access so A:\CONTROL.TAT can be opened/read.
; 3. Provide enough INT 21h hook behavior for .COM/.EXE policy checks.
; 4. Reproduce or bypass the EC290 validator for known-good test titles.
; 5. On success, allow the title command EXEC or minwin b: launch to proceed.
; 6. Log every blocked executable, every AH=3Dh/AH=3Fh file operation, and every
;    AH=4Bh launch so the simulator can be tightened iteratively.
;-------------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; STAGE 36 EXEC-SITE NOTES
; ---------------------------------------------------------------------------
; TLAUNCH contains at least two important AH=4Bh EXEC contexts:
;
; 1. E9D5C candidate real launch path
;    Classification: TITLE_OR_MINWIN_EXEC_AFTER_CONTROL_TAT
;    Meaning: TLAUNCH has built or selected a command and now invokes DOS EXEC.
;    This is probably where a validated title command, DOS executable, or minwin path is launched.
;
; 2. EA38A FRANKS_UNLIKELY probe
;    Classification: FAKE_PROBE_EXEC
;    Meaning: TLAUNCH deliberately tries to EXEC A:\FRANKS_UNLIKELY.EXE.
;    The expected behavior is not to find or run a real file. The expected behavior is that the VIS
;    executable-blocking hook intercepts the request and returns carry set with AX=6664h.
;
; VISENV implication:
;    Do not implement FRANKS_UNLIKELY.EXE as a file. Implement the guardrail response.
;    Treat E9D5C as the title/minwin launch point and instrument the command tail/parameter block.
