; ===========================================================================
; 06 - REDIR / Runtime Configuration Provider
; ===========================================================================
; ROM range: 0xE8AD0-0xE987F
; Entry model: Launched by COMMAND as EXEC "redir" after GBIOS.
;
; VIS-specific role:
;   Installs redirector/config services, embeds SYSTEM.INI, special-cases SYSTEM.INI and CARD.EXE, and uses VISBIOS service calls.
;
; Dependencies:
;   GBIOS installed first.
;
; VISENV stub guidance:
;   VISENV should provide the embedded SYSTEM.INI and stub the REDIR services enough for MINWIN/Modular Windows startup.
;
; Confidence:
;   High for embedded config; medium for every redirector call.
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
; REDIR runtime/configuration provider
;
; ROM physical range:  E8AD0h-E987Fh
; D8800 export name:   REDIR
; Export entry target: E8AD0h, initial jump to E8FE1h
;
; Developer summary
; -----------------
; REDIR is launched after GBIOS by the custom VIS COMMAND dispatcher:
;
;     EXEC "mscdex"
;     EXEC "gbios"
;     EXEC "redir"
;     EXEC "roma"
;     EXEC "romb"
;     forever EXEC "tlaunch"
;
; REDIR is not an ordinary utility. It is a resident service installer. It carries
; an embedded default SYSTEM.INI, installs interrupt hooks, registers itself with
; the GBIOS/VISBIOS service layer, and appears to provide the configuration and
; redirector substrate needed by Modular Windows and the VIS Save-It / memory-card
; ecosystem.
;
; VIS-specific significance
; -------------------------
; A normal PC DOS boot would read CONFIG.SYS/AUTOEXEC.BAT from a disk, load DOS
; drivers, and then start COMMAND.COM. The VIS does not boot that way. D8800 has
; already taken over INT 19h, the D8960 boot core has created a DOS-like runtime,
; and COMMAND is a tiny ROM dispatcher. REDIR is one of the resident modules that
; makes that custom ROM environment look enough like a DOS/Modular Windows runtime
; for TLAUNCH and MINWIN to work.
;
; For VISENV/DOSBox rehosting, REDIR is the first module after GBIOS that should
; be understood as a service provider, not an app. It is probably safe to stub at
; first, but the stub must eventually provide equivalent answers for SYSTEM.INI,
; redirector/file queries, memory-card state, and selected INT 15h/INT 2Fh calls.
;-------------------------------------------------------------------------------

REDIR_BASE       equ 0E8AD0h
REDIR_ENTRY      equ 0E8AD0h
REDIR_INSTALLER  equ 0E8FE1h

;-------------------------------------------------------------------------------
; Entry trampoline
;-------------------------------------------------------------------------------
E8AD0:  E9 0E 05              jmp     REDIR_INSTALLER
        ; D8800 export resolver enters REDIR here.
        ; The first instruction immediately jumps over the resident handler/data
        ; block to the install-time code at E8FE1.

;-------------------------------------------------------------------------------
; Resident handler / chain stubs near start of resident block
;-------------------------------------------------------------------------------
E8AD3:  CD 21                 int     21h
        ; This is not the normal program entry. It is part of the copied resident
        ; block. Current interpretation: DOS/redirector handler glue used after
        ; REDIR stays resident. Treat as handler code, not startup code.

E8AD5:  50                    push    ax
E8AD6:  8C D8                 mov     ax, ds
E8AD8:  2E A3 2F 02           mov     cs:[022Fh], ax
        ; Save caller DS. Later handler exit paths restore DS from this slot.

E8ADC:  8C C8                 mov     ax, cs
E8ADE:  8E D8                 mov     ds, ax
        ; Switch DS to REDIR resident segment so internal data slots are usable.

E8AE0:  58                    pop     ax
E8AE1:  EA 00 00 00 00        jmp     far 0000:0000
        ; Patched far jump slot. Likely chains to the previous handler once the
        ; installer fills in the old vector.

E8AE6:  80 FC 4F              cmp     ah, 4Fh
E8AE9:  75 02                 jne     short E8AED
E8AEB:  CD 6F                 int     6Fh
        ; If AH=4Fh, dispatch through INT 6Fh. REDIR installs INT 6Fh below.
        ; This looks like a private redirector/service interrupt path.

E8AED:  EA 00 00 00 00        jmp     far 0000:0000
        ; Second patched far chain slot.

E8AF2:  CF                    iret
        ; Terminal IRET stub.

;-------------------------------------------------------------------------------
; Embedded names and default Modular Windows configuration
;-------------------------------------------------------------------------------
E8C2F:  db 'SYSTEM.INI',0
E8C3A:  db 'CARD.EXE',0
        ; REDIR carries its own default config file name and memory-card utility
        ; name. This is VIS-specific: the player can provide a default Modular
        ; Windows configuration from ROM/resident data, rather than requiring a
        ; normal writable boot disk.

E8C43:  db '[boot]',13,10
        db 'shell=cdplayer.exe',13,10
        db 'mouse.drv=mouse.drv',13,10
        db 'network.drv=',13,10
        db 'language.dll=',13,10
        db 'sound.drv=sound.drv',13,10
        db 'comm.drv=comm.drv',13,10
        db 'system.drv=system.drv',13,10
        db 'drivers=mmsystem.dll',13,10
        db 'oemfonts.fon=vgaoem.fon',13,10
        db 'fixedfon.fon=vgafix.fon',13,10
        db 'fonts.fon=vgasys.fon',13,10
        db 'display.drv=vga.drv',13,10
        db 'keyboard.drv=keyboard.drv',13,10
        db 13,10
        db '[drivers]',13,10
        db 'wave=vwavmidi.drv',13,10
        db 'midi=vwavmidi.drv',13,10
        db 'timer=timer.drv',13,10
        db 13,10
        db '[vwavmidi]',13,10
        db 'channel=7',13,10
        db 'port=220',13,10
        db 'int=7',13,10
        db 13,10
        db '[mci]',13,10
        db 'CDAudio=mcicda.drv',13,10
        db 'Sequencer=mciseq.drv',13,10
        db 'WaveAudio=mciwave.drv',13,10
        db 'AviVideo=mciavi.drv',13,10
        ; This embedded SYSTEM.INI mirrors the Modular Windows default runtime
        ; expectations: shell, display/keyboard/sound/system drivers, vwaver MIDI
        ; settings, and MCI bindings. The default shell is cdplayer.exe, which
        ; explains the VIS behavior when an audio CD is inserted.

E8EFE:  db 'HAIKU Mem Card Redirector Installed.',13,10,'$'
        ; The HAIKU string strongly suggests REDIR is tied to the memory-card
        ; redirector / Save-It ecosystem. For VISENV, this means REDIR cannot be
        ; dismissed as just SYSTEM.INI text; it owns a persistent-storage service.

;-------------------------------------------------------------------------------
; Installer entry
;-------------------------------------------------------------------------------
E8FE1:  0E                    push    cs
E8FE2:  1F                    pop     ds
        ; Install-time DS = REDIR ROM segment.

E8FE3:  56                    push    si
E8FE4:  57                    push    di
E8FE5:  BE 00 01              mov     si, 0100h
E8FE8:  BF 00 01              mov     di, 0100h
E8FEB:  B9 2B 04              mov     cx, 042Bh
E8FEE:  F3 A4                 rep     movsb
        ; Copy REDIR's resident block from CS:0100 to ES:0100.
        ; The ROM EXEC resolver/boot core must have set ES to the destination
        ; process/resident segment. This is a key module-entry contract.

E8FF0:  5F                    pop     di
E8FF1:  5E                    pop     si
E8FF2:  06                    push    es
E8FF3:  1F                    pop     ds
        ; After copy, DS becomes the resident segment, not necessarily the ROM
        ; segment. REDIR is preparing to run from / stay in the copied image.

E8FFA:  06                    push    es
E8FFB:  B4 52                 mov     ah, 52h
E8FFD:  CD 21                 int     21h
E8FFF:  8C 06 A3 01           mov     [01A3h], es
E9003:  07                    pop     es
        ; DOS AH=52h returns DOS List-of-Lists pointer in ES:BX. REDIR saves ES.
        ; This reinforces that the D8960 core provides DOS-like internals, not
        ; just enough to launch programs.

E9004:  B8 00 30              mov     ax, 3000h
E9007:  CD 21                 int     21h
E9009:  A2 28 05              mov     [0528h], al
        ; Get DOS version. REDIR adapts internal table offsets based on major
        ; version. VIS appears to emulate enough DOS semantics that this matters.

E900C:  C7 06 29 05 58 00     mov     word [0529h], 0058h
E9012:  3C 03                 cmp     al, 03h
E9014:  77 05                 ja      E901B
E9016:  83 2E 29 05 07        sub     word [0529h], 0007h
        ; Version-dependent structure size/offset. For VISENV, report a DOS
        ; version compatible with the path being emulated and preserve this size.

E901B:  B0 01                 mov     al, 01h
E901D:  B4 01                 mov     ah, 01h
E901F:  B2 02                 mov     dl, 02h
E9021:  E8 A4 07              call    E97C8
        ; Initializes REDIR internal structures / drive table. Exact structure
        ; still needs naming, but it feeds later INT 2F / file redirector logic.

E9024:  E8 1C 00              call    E9043
        ; Install REDIR interrupt hooks.

E9027:  B8 00 E0              mov     ax, E000h
E902A:  B2 01                 mov     dl, 01h
E902C:  CD 21                 int     21h
        ; Nonstandard/implementation-specific DOS call under the VIS ROM DOS
        ; substrate. Needs closer tracing in D8960. Do not assume PC DOS meaning.

E902E:  BA 00 01              mov     dx, 0100h
E9031:  B8 00 31              mov     ax, 3100h
E9034:  1E                    push    ds
E9035:  BB 03 01              mov     bx, 0103h
E9038:  53                    push    bx
E9039:  CB                    retf
        ; REDIR terminates-and-stays-resident using a far-return path rather than
        ; a plain INT 21h AH=31h call in this listing. The value AX=3100h and
        ; DX=0100h show the TSR intent. The boot core likely completes the TSR
        ; semantics on return.

;-------------------------------------------------------------------------------
; Install REDIR interrupt hooks
;-------------------------------------------------------------------------------
E9043:  BA 22 01              mov     dx, 0122h
E9046:  B8 6F 25              mov     ax, 256Fh
E9049:  CD 21                 int     21h
        ; Set INT 6Fh to resident offset 0122h. This is a REDIR private/service
        ; interrupt, used by the handler path at E8AEB.

E904B:  B8 15 35              mov     ax, 3515h
E904E:  CD 21                 int     21h
E9050:  89 1E 1E 01           mov     [011Eh], bx
E9054:  8C C3                 mov     bx, es
E9056:  89 1E 20 01           mov     [0120h], bx
        ; Save previous INT 15h handler.

E905A:  BA 16 01              mov     dx, 0116h
E905D:  B8 15 25              mov     ax, 2515h
E9060:  CD 21                 int     21h
E9062:  C3                    ret
        ; Set INT 15h to resident offset 0116h. REDIR hooks the same BIOS/service
        ; interrupt family used by GBIOS. Its handler must chain to the saved
        ; vector unless it handles a REDIR-specific service.

;-------------------------------------------------------------------------------
; Register/query through GBIOS / VISBIOS service AX=7102h
;-------------------------------------------------------------------------------
E9063:  C7 06 51 02 68 04     mov     word [0251h], 0468h
E9069:  8C D8                 mov     ax, ds
E906B:  A3 53 02              mov     [0253h], ax
E906E:  B8 00 00              mov     ax, 0000h
E9071:  A3 55 02              mov     [0255h], ax
E9074:  A3 57 02              mov     [0257h], ax
E9077:  A3 5B 02              mov     [025Bh], ax
E907A:  A3 5D 02              mov     [025Dh], ax
E907D:  B8 46 00              mov     ax, 0046h
E9080:  A3 59 02              mov     [0259h], ax
E9083:  8C DA                 mov     dx, ds
E9085:  BE 51 02              mov     si, 0251h
E9088:  B8 02 71              mov     ax, 7102h
E908B:  BB 00 02              mov     bx, 0200h
E908E:  CD 15                 int     15h
        ; VIS-specific service call into GBIOS/VISBIOS.
        ; Current hypothesis: registers a redirector/memory-card parameter block.
        ; This must not be treated as a generic PC BIOS INT 15h call.

E9090:  A1 A6 04              mov     ax, [04A6h]
E9093:  25 01 00              and     ax, 0001h
E9096:  74 03                 je      E909B
E9098:  B8 04 00              mov     ax, 0004h
E909B:  0D 01 00              or      ax, 0001h
E909E:  A3 31 02              mov     [0231h], ax
E90A1:  C3                    ret
        ; Interprets result flags from the VISBIOS service block and converts
        ; them into REDIR status bits.

;-------------------------------------------------------------------------------
; Redirector/file-info update paths
;-------------------------------------------------------------------------------
E90A2:  8E 06 3D 02           mov     es, [023Dh]
E90A6:  8B 3E 3B 02           mov     di, [023Bh]
        ; Load caller/request structure pointer. REDIR uses ES:DI heavily as a
        ; request block, which is consistent with redirector-style APIs.

        ; [E90AA-E917C] updates file size/position-like fields, copies data from
        ; internal REDIR tables into caller buffers, and then calls INT 15h
        ; AX=7102h again to synchronize state with GBIOS/VISBIOS.
        ; TODO in final source pass: name request-block fields once matched to
        ; DOS redirector / Microsoft network redirector structures.

E9174:  B8 02 71              mov     ax, 7102h
E9177:  BB 00 02              mov     bx, 0200h
E917A:  CD 15                 int     15h
        ; Second confirmed GBIOS/VISBIOS registration/query call.

;-------------------------------------------------------------------------------
; INT 2F / Windows multiplex interaction
;-------------------------------------------------------------------------------
E918B:  B8 08 12              mov     ax, 1208h
E918E:  CD 2F                 int     2Fh
        ; INT 2Fh AX=1208h is in the DOS/Windows multiplex family. REDIR uses it
        ; while handling request blocks. This is a strong Modular Windows
        ; integration point.

;-------------------------------------------------------------------------------
; Path/name handling: SYSTEM.INI and CARD.EXE special cases
;-------------------------------------------------------------------------------
E91D9:  8C D8                 mov     ax, ds
E91DB:  8E C0                 mov     es, ax
E91DD:  1E                    push    ds
E91DE:  8B 36 8F 01           mov     si, [018Fh]
E91E2:  A1 91 01              mov     ax, [0191h]
E91E5:  8E D8                 mov     ds, ax
E91E7:  8B 34                 mov     si, [si]
E91E9:  80 3C 5C              cmp     byte [si], '\\'
E91EC:  75 03                 jne     E91F1
E91EE:  83 C6 08              add     si, 0008h
        ; Pull a path/name pointer from the caller/request context. If it starts
        ; with backslash, skip a prefix. This is REDIR's file-name matching path.

E91F2:  BF 5F 02              mov     di, 025Fh
        ; Compare against first special name, likely SYSTEM.INI.
E91F6:  A6                    cmpsb
        ; ... if exact match, REDIR provides embedded SYSTEM.INI data.

E9202:  BF 6A 02              mov     di, 026Ah
        ; Compare against second special name, likely CARD.EXE.
        ; CARD.EXE is the memory-card utility/application.

E9214:  ; matched first special name
        ; Sets size/offset fields so caller sees REDIR-provided embedded data.
        ; This is probably how Modular Windows can open SYSTEM.INI even when the
        ; disc does not provide one in the normal way.

E922A:  ; matched second special name
        ; Calls VISBIOS service and expects signature values below.

E9250:  B8 02 71              mov     ax, 7102h
E9253:  BB 00 02              mov     bx, 0200h
E9256:  CD 15                 int     15h
E9258:  A1 68 04              mov     ax, [0468h]
E925B:  3D 0D F0              cmp     ax, 0F00Dh
E9260:  A1 6A 04              mov     ax, [046Ah]
E9263:  3D AD 1B              cmp     ax, 1BADh
        ; Magic result check: F00D:1BAD.
        ; This is a very VIS/Tandy-looking signature. It likely indicates a valid
        ; memory-card/redirector response block from GBIOS/VISBIOS.

;-------------------------------------------------------------------------------
; Main redirector dispatch framework
;-------------------------------------------------------------------------------
E95F5:  2E FF 97 B3 05        call    far? [cs:bx+05B3h]
E9604:  2E FF 97 55 05        call    far? [cs:bx+0555h]
        ; Indexed handler calls through internal tables. This looks like the core
        ; redirector dispatch machinery. The exact function table needs one more
        ; pass to name every operation, but this is where REDIR maps requests to
        ; per-operation handlers.

E9635:  ; chain-to-old handler path
        ; Restores flags/registers, patches the return frame to jump to the old
        ; INT 2Fh handler saved at [0123]/[0125], then far-returns.

E9652:  ; handled-by-REDIR path
        ; Restores DS and returns to caller after REDIR handled the operation.

;-------------------------------------------------------------------------------
; Version-dependent table setup
;-------------------------------------------------------------------------------
E965E:  ; build internal request-table pointers
        ; Chooses different internal offsets depending on DOS major version stored
        ; at [0528]. This is why REDIR asked DOS for its version during install.

;-------------------------------------------------------------------------------
; Install INT 2Fh hook
;-------------------------------------------------------------------------------
E96F7:  1E                    push    ds
E96F8:  B8 2F 35              mov     ax, 352Fh
E96FB:  CD 21                 int     21h
E96FD:  89 1E 23 01           mov     [0123h], bx
E9701:  8C C0                 mov     ax, es
E9703:  A3 25 01              mov     [0125h], ax
        ; Save old INT 2Fh vector.

E9706:  8C C8                 mov     ax, cs
E9708:  A3 14 01              mov     [0114h], ax
E970B:  C7 06 12 01 8C 0B     mov     word [0112h], 0B8Ch
E9711:  BA 05 01              mov     dx, 0105h
E9714:  B8 2F 25              mov     ax, 252Fh
E9717:  CD 21                 int     21h
        ; Set INT 2Fh to REDIR resident offset 0105h.
        ; This is REDIR's Windows/DOS multiplex hook. VISENV must eventually
        ; decide whether to implement this API directly or let REDIR handle it.

;-------------------------------------------------------------------------------
; INT 2F helper path into Windows/DOS multiplex
;-------------------------------------------------------------------------------
E9846:  B8 22 12              mov     ax, 1222h
E9849:  CD 2F                 int     2Fh
E9851:  B8 06 12              mov     ax, 1206h
E9854:  CD 2F                 int     2Fh
        ; REDIR itself calls INT 2Fh AX=1222h and AX=1206h while preserving and
        ; switching stacks. These calls are likely DOS internal / redirector
        ; integration points used to safely call into the multiplex chain.

;-------------------------------------------------------------------------------
; End of REDIR module
;-------------------------------------------------------------------------------
; Open items for final naming pass:
;   - identify every request-block field at ES:DI offsets 00h..1Dh
;   - name internal tables at 018Fh..01ABh and 0555h/05B3h
;   - correlate AX=7102h block layout with GBIOS service implementation
;   - determine exact REDIR answers for SYSTEM.INI and CARD.EXE open/read flows
;-------------------------------------------------------------------------------
