; ===========================================================================
; 08 - MINWIN Modular Windows Starter
; ===========================================================================
; ROM range: 0xE1580-0xE165F
; Entry model: Not launched by COMMAND. Launched later by TLAUNCH after CONTROL.TAT validation, typically as minwin b:.
;
; VIS-specific role:
;   Bridge from VIS title gatekeeper world into the ROM-resident Modular Windows runtime and ROMWINTOC loader.
;
; Dependencies:
;   TLAUNCH validation; F4000 ROMWINTOC loader.
;
; VISENV stub guidance:
;   VISENV can initially log minwin b: and stop; later, call F4000 loader or start reconstructed Modular Windows environment.
;
; Confidence:
;   High for handoff role; medium for exact parameter block.
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

; -----------------------------------------------------------------------------
; Memorex/Tandy VIS ROM runtime - MINWIN starter
; Source-style annotated listing, Stage 32
;
; ROM physical range:  E1580-E165F
; Export name:         MINWIN
; Export role:         Starts the ROM-resident Modular Windows loader after TLAUNCH
;                      has accepted/validated CONTROL.TAT.
;
; Why MINWIN matters to VIS homebrew
; ----------------------------------
; MINWIN is the bridge from the VIS-specific launcher world into the Microsoft
; Modular Windows world. The public Microsoft documentation describes the
; generic launch command as MODWIN. The VIS ROM uses a smaller built-in starter
; named MINWIN. TLAUNCH appears to execute MINWIN after CONTROL.TAT validation,
; commonly with a command resembling:
;
;       minwin b:
;
; That command tells the starter to use the ROM-resident B: Modular Windows
; runtime. The ROMWINTOC table at F4000 exposes the B: runtime files such as
; KERNEL.EXE, GDI.EXE, USER.EXE, VGA.DRV, TVUI.DLL, DISPDIB.DLL, MCMAN.EXE,
; and the other Modular Windows components.
;
; Important model for VISENV
; --------------------------
; MINWIN is not a normal DOS EXE on disk. It is a ROM export entered at
; CS:0000 through the D8800 export/EXEC resolver path. When VISENV stubs this,
; it does not need to implement the entire Windows loader immediately. The first
; useful stub can log the requested windir/command tail and stop cleanly.
;
; Expected entry state, inferred
; -----------------------------
;   CS = MINWIN ROM module segment, physical E1580
;   DS = PSP/process segment created by the ROM DOS-like substrate
;   ES = not trusted on entry
;   PSP:80h contains the DOS command tail from EXEC "minwin ..."
;
; Summary
; -------
;   1. Shrinks its current memory block.
;   2. Reads the DOS command tail at PSP:80h.
;   3. If a windir/path argument exists, builds a tiny environment/parameter
;      area in the PSP process segment.
;   4. Stores an environment segment pointer into PSP:2Ch.
;   5. Far-transfers into the F4000 ROMWINTOC/ROM Windows loader service.
;
; Open questions
; --------------
;   * Exact layout of the scratch/environment block built at PSP:0100.
;   * Exact contract of the F4000 service at F45F:0002.
;   * Whether MINWIN accepts only a windir path or also additional environment
;     assignments like the documented MODWIN command.
; -----------------------------------------------------------------------------

MINWIN_BASE equ 0E1580h

org 0000h

MINWIN_ENTRY:
E1580:  EB 3B                 jmp short MINWIN_CODE_START
E1582:  90                    nop

; -----------------------------------------------------------------------------
; Embedded default strings and template data.
; These bytes are copied into the process segment later. They are not executed.
; -----------------------------------------------------------------------------

E1583: DEFAULT_DOSX_PATH      db 'b:\dosx.exe',0
E158E:                        db 00h,00h,00h,00h
E1592:                        db 00h
E1593:                        db 87h,0DBh,87h,0DBh,87h,0DBh,87h,0DBh,87h,0DBh
                               ; Filler/template bytes copied as part of the
                               ; 0x3D-byte header/template region.
E159D:                        db 90h
E159E: DEFAULT_ENV_WINDIR     db 'WINDIR=b:\',0
E15AA:                        db 00h
E15AB:                        db 01h,00h
E15AD: SECOND_DOSX_PATH       db 'b:\dosx.exe',0
E15B8:                        db 00h,00h,00h,00h,00h

; -----------------------------------------------------------------------------
; MINWIN executable logic begins here.
; -----------------------------------------------------------------------------

MINWIN_CODE_START:
E15BD:  BB 10 01              mov bx,0110h
E15C0:  B8 00 4A              mov ax,4A00h
E15C3:  CD 21                 int 21h
                               ; DOS Resize Memory Block.
                               ; VIS-specific meaning:
                               ;   The ROM DOS-like substrate has created a PSP
                               ;   and memory arena for this ROM export as if it
                               ;   were a DOS process. MINWIN reduces its arena
                               ;   to 0x110 paragraphs before preparing the
                               ;   Modular Windows loader handoff.

E15C5:  8C CB                 mov bx,cs
                               ; Save MINWIN's own ROM segment in BX. If no
                               ; usable command tail is found, this segment is
                               ; used to compute the default environment pointer.

E15C7:  A0 80 00              mov al,[0080h]
E15CA:  0A C0                 or al,al
E15CC:  74 72                 jz MINWIN_FINAL_TRANSFER
                               ; PSP:80h is the DOS command tail length.

E15CE:  BE 80 00              mov si,0080h
MINWIN_SKIP_LEADING_SPACES:
E15D1:  46                    inc si
E15D2:  80 3C 0D              cmp byte ptr [si],0Dh
E15D5:  74 69                 je MINWIN_FINAL_TRANSFER
E15D7:  80 3C 20              cmp byte ptr [si],' '
E15DA:  74 F5                 je MINWIN_SKIP_LEADING_SPACES
E15DC:  80 3C 00              cmp byte ptr [si],00h
E15DF:  74 5F                 je MINWIN_FINAL_TRANSFER
                               ; SI now points to the first non-space byte of
                               ; the windir/argument string, usually "b:".

; -----------------------------------------------------------------------------
; Build a small loader/environment block in the PSP process segment.
; -----------------------------------------------------------------------------

E15E1:  8C D8                 mov ax,ds
E15E3:  8E C0                 mov es,ax
                               ; ES = PSP/process segment.

E15E5:  8C C8                 mov ax,cs
E15E7:  8E D8                 mov ds,ax
                               ; DS = MINWIN ROM segment so we can copy the
                               ; template bytes from the start of this module.

E15E9:  8B DE                 mov bx,si
                               ; Save PSP command-tail pointer.

E15EB:  BE 00 00              mov si,0000h
E15EE:  B9 3D 00              mov cx,003Dh
E15F1:  BF 00 01              mov di,0100h
E15F4:  F3 A4                 rep movsb
                               ; Copy the first 0x3D bytes of MINWIN into
                               ; PSP:0100. This includes b:\dosx.exe,
                               ; WINDIR=b:\, and other template fields.

E15F6:  8C C0                 mov ax,es
E15F8:  8E D8                 mov ds,ax
                               ; DS = PSP/process segment again.

E15FA:  8B F3                 mov si,bx
E15FC:  BF 27 00              mov di,0027h
E15FF:  81 C7 00 01           add di,0100h
                               ; DI = PSP:0127, likely the mutable text area
                               ; inside the copied template.

E1603:  FC                    cld

MINWIN_COPY_ARGUMENT_TEXT:
E1604:  A4                    movsb
E1605:  80 3C 0D              cmp byte ptr [si],0Dh
E1608:  74 19                 je MINWIN_TERMINATE_BLOCK
E160A:  80 3C 20              cmp byte ptr [si],' '
E160D:  75 0F                 jne MINWIN_CHECK_NUL
                               ; Spaces become NUL separators. This resembles
                               ; construction of an environment-style block.

E160F:  26 80 7D FF 00        cmp byte ptr es:[di-1],00h
E1614:  75 03                 jne MINWIN_INSERT_NUL_SEPARATOR
E1616:  46                    inc si
E1617:  EB EC                 jmp MINWIN_COPY_ARGUMENT_TEXT

MINWIN_INSERT_NUL_SEPARATOR:
E1619:  33 C0                 xor ax,ax
E161B:  AA                    stosb
E161C:  EB E7                 jmp MINWIN_COPY_ARGUMENT_TEXT

MINWIN_CHECK_NUL:
E161E:  80 3C 00              cmp byte ptr [si],00h
E1621:  75 E1                 jne MINWIN_COPY_ARGUMENT_TEXT

MINWIN_TERMINATE_BLOCK:
E1623:  B8 00 00              mov ax,0000h
E1626:  26 80 7D FF 00        cmp byte ptr es:[di-1],00h
E162B:  74 01                 je MINWIN_ALREADY_NUL_TERMINATED
E162D:  AA                    stosb
MINWIN_ALREADY_NUL_TERMINATED:
E162E:  AA                    stosb
                               ; Double-NUL terminate the text block.

E162F:  B8 01 00              mov ax,0001h
E1632:  AB                    stosw
                               ; Store word 0001h after the double-NUL block.

E1633:  B9 0F 00              mov cx,000Fh
E1636:  BE 03 01              mov si,0103h
E1639:  F3 A4                 rep movsb
                               ; Copy 15 bytes from PSP:0103, the copied
                               ; b:\dosx.exe string, into the generated block.

E163B:  8C DB                 mov bx,ds
E163D:  83 C3 10              add bx,0010h
                               ; BX = PSP segment + 0x10.

; -----------------------------------------------------------------------------
; Final transfer to the ROMWINTOC / ROM Windows loader service.
; -----------------------------------------------------------------------------

MINWIN_FINAL_TRANSFER:
E1640:  B8 20 00              mov ax,0020h
E1643:  C1 E8 04              shr ax,04h
E1646:  03 C3                 add ax,bx
                               ; AX = BX + 2.

E1648:  BF 2C 00              mov di,002Ch
E164B:  26 89 05              mov es:[di],ax
                               ; Store environment segment pointer into PSP:2Ch.

E164E:  B8 00 F4              mov ax,0F400h
E1651:  8E D8                 mov ds,ax
                               ; DS = F400h option ROM segment containing the
                               ; ROMWINTOC table and loader/file-service code.

E1653:  FF 36 18 00           push word ptr [0018h]
E1657:  FF 36 16 00           push word ptr [0016h]
                               ; In this ROM:
                               ;   F400:0016 = 0002h
                               ;   F400:0018 = F45Fh
                               ; Target = F45F:0002.

E165B:  06                    push es
E165C:  1F                    pop ds
                               ; Restore DS = PSP/process segment for callee.

E165D:  CB                    retf
                               ; Transfer into F4000 ROM Windows loader.

E165E:  00 00                 db 00h,00h
