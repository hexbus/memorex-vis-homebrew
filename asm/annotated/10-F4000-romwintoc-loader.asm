; ===========================================================================
; 10 - F4000 ROMWINTOC Table and Loader
; ===========================================================================
; ROM range: 0xF4000-0xF6FFF
; Entry model: Reached by MINWIN through observed F400:0016/F400:0018 pointer to F45F:0002.
;
; VIS-specific role:
;   Provides ROM B: file table and Modular Windows loader/runtime support.
;
; Dependencies:
;   MINWIN handoff; ROMWINTOC payload at 0x076F0-0xD87FF.
;
; VISENV stub guidance:
;   VISENV should expose ROMWINTOC files as B: or a virtual file provider.
;
; Confidence:
;   High for file table; medium for loader entry behavior.
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

;===============================================================================
; F4000 ROMWINTOC TABLE + MODULAR WINDOWS STARTER / LOADER REGION
;===============================================================================
;
; Physical range:  F4000-F6FFF
; Segment model:   F400:xxxx for table/header data, F45F:0002 for MINWIN handoff
; Role in VIS:     This is the bridge from the VIS-specific title launcher into
;                  the ROM-resident Microsoft Modular Windows runtime.
;
; Why this matters for homebrew / VISENV:
;   * TLAUNCH validates CONTROL.TAT and then eventually runs MINWIN.
;   * MINWIN does not itself contain the full Windows starter.
;   * MINWIN far-transfers through a pointer in this F4000 region:
;
;         F400:0016 = 0002h
;         F400:0018 = F45Fh
;         target    = F45F:0002 = physical F45F2
;
;   * That target enters the code below, which behaves like a ROM-resident
;     Standard Mode / Modular Windows startup loader.
;   * This region also contains the ROMWINTOC table that exposes the ROM B:\
;     runtime files such as KERNEL.EXE, GDI.EXE, USER.EXE, VGA.DRV, TVUI.DLL,
;     CDPLAYER.EXE, MCMAN.EXE, and the MCI drivers.
;
; Important confidence note:
;   This block begins with 55 AA 18, but its checksum does not validate as a
;   conventional PC option ROM in this BIOS image. Treat it as a ROM-resident
;   loader/table region referenced by VIS code, not as a normal independently
;   initialized BIOS option ROM.
;
;===============================================================================

F4000_ROMWINTOC_HEADER:
F4000: 55 AA 18          ; Header-like signature. Size byte 18h => 12 KiB if
                         ; interpreted as an option ROM. Checksum is not valid
                         ; in this image, so this is best treated as a VIS ROM
                         ; data/loader block, not a normal boot-time option ROM.
F4003: E9 00 00          ; Near jump to F4006.
F4006: CB                ; RETF. If entered as a conventional option-ROM init,
                         ; this returns immediately. This reinforces the idea
                         ; that normal BIOS option-ROM execution is not the main
                         ; way this region is used by VIS.
F4007: 00                ; Padding / alignment.

F4008_ROMWINTOC_MAGIC:
F4008: db 'ROMWINTOC',0  ; Identifies the table. This table maps named B: files
                         ; to ROM offsets using 0x300000-based pointers.

F4012_ROMWINTOC_CONTROL_FIELDS:
F4012: db 10h,03h,09h,01h
                         ; Undecoded table/control bytes. These appear before
                         ; the MINWIN handoff pointer and file-entry records.
F4016: dw 0002h          ; MINWIN handoff IP used by MINWIN.
F4018: dw F45Fh          ; MINWIN handoff CS used by MINWIN.
                         ; MINWIN jumps/far-returns to F45F:0002.
F401A: dd 02F79CDAh      ; Undecoded pointer/control dword.
F401E: dd 00300000h      ; 0x300000 pointer base used by ROMWINTOC file entries.
F4022: dw 00D3h          ; Undecoded.
F4024: dw 02A0h          ; Undecoded.
F4026: dw 0326h          ; Undecoded.
F4028: dd 00300000h      ; Another 0x300000 base/reference.
F402C: dd 000C9000h      ; Undecoded.
F4030: dd 0000001Dh      ; 1Dh = 29 decimal. Number of ROMWINTOC file records.

;-------------------------------------------------------------------------------
; ROMWINTOC FILE RECORD FORMAT
;-------------------------------------------------------------------------------
;
; Starting at F4034, there are 29 fixed-size records.
;
; Observed record layout:
;   +00  9 bytes   short module alias, NUL padded
;   +09  13 bytes  DOS file name, NUL padded
;   +22  4 bytes   little-endian ROM pointer
;
; The file pointer is converted to an image offset by subtracting 0x300000:
;
;   file_offset = pointer - 0x300000
;
; These files occupy the 076F0-D87FF ROMWINTOC B: payload region.
;
; Example:
;   KERNEL.EXE record pointer = 003076F0h
;   003076F0h - 00300000h = 000076F0h
;
;-------------------------------------------------------------------------------

F4034_ROMWINTOC_FILE_TABLE:
; index  alias      filename        ROM pointer  file offset   size
;  0     KERNEL    KERNEL.EXE    0x003076F0 0x076F0   68336 bytes
;  1     SYSTEM    SYSTEM.DRV    0x003181E0 0x181E0    1920 bytes
;  2     KEYBOARD  KEYBOARD.DRV  0x00318960 0x18960    6544 bytes
;  3     DISPLAY   VGA.DRV       0x0031A2F0 0x1A2F0   51520 bytes
;  4     MOUSE     MOUSE.DRV     0x00326C30 0x26C30    9536 bytes
;  5     FONTS     VGASYS.FON    0x00329170 0x29170    2672 bytes
;  6     FIXFONTS  VGAFIX.FON    0x00329BE0 0x29BE0    2352 bytes
;  7     OEMFONTS  VGAOEM.FON    0x0032A510 0x2A510    2896 bytes
;  8     TVVGA     TVVGA.FON     0x0032B060 0x2B060    8480 bytes
;  9     SOUND     SOUND.DRV     0x0032D180 0x2D180    3008 bytes
; 10     COMM      COMM.DRV      0x0032DD40 0x2DD40    7888 bytes
; 11     GDI       GDI.EXE       0x0032FC10 0x2FC10  143232 bytes
; 12     USER      USER.EXE      0x00352B90 0x52B90  137984 bytes
; 13     MMSYSTEM  MMSYSTEM.DLL  0x00374690 0x74690   48176 bytes
; 14     VWAVMIDI  VWAVMIDI.DRV  0x003802C0 0x802C0   12000 bytes
; 15     HC        HC.DLL        0x003831A0 0x831A0    2992 bytes
; 16     MC        MC.DLL        0x00383D50 0x83D50    7376 bytes
; 17     DISPDIB   DISPDIB.DLL   0x00385A20 0x85A20    5376 bytes
; 18     MMTASK    MMTASK.TSK    0x00386F20 0x86F20     304 bytes
; 19     TVUI      TVUI.DLL      0x00387050 0x87050  101824 bytes
; 20     MCICDA    MCICDA.DRV    0x0039FE10 0x9FE10   12288 bytes
; 21     MCIWAVE   MCIWAVE.DRV   0x003A2E10 0xA2E10   22160 bytes
; 22     MCISEQ    MCISEQ.DRV    0x003A84A0 0xA84A0   20320 bytes
; 23     MSVIDEO   MSVIDEO.DLL   0x003AD400 0xAD400   15760 bytes
; 24     MCIAVI    MCIAVI.DRV    0x003B1190 0xB1190   46688 bytes
; 25     TIMER     TIMER.DRV     0x003BC7F0 0xBC7F0    2592 bytes
; 26     CDPLAYER  CDPLAYER.EXE  0x003BD210 0xBD210   25904 bytes
; 27     WIN87EM   WIN87EM.DLL   0x003C3740 0xC3740   10416 bytes
; 28     MCUTIL    MCMAN.EXE     0x003C5FF0 0xC5FF0   75792 bytes


;-------------------------------------------------------------------------------
; F45F:0002 MODULAR WINDOWS STARTER ENTRY
;-------------------------------------------------------------------------------
;
; MINWIN transfers here after TLAUNCH has accepted CONTROL.TAT and decided to
; start a Modular Windows title. This code is therefore the first ROMWINTOC-side
; Windows startup code, not part of the earlier D8800 EXEC dispatcher.
;
; In VIS boot terms:
;
;   COMMAND dispatcher
;     -> EXEC "tlaunch"
;       -> TLAUNCH waits for CD/cartridge
;       -> TLAUNCH opens A:\CONTROL.TAT
;       -> TLAUNCH validates CONTROL.TAT
;       -> TLAUNCH launches MINWIN / "minwin b:"
;       -> MINWIN transfers to F45F:0002 here
;
; The code below is still first-pass annotated. It clearly performs standard-mode
; / Windows startup work: INT 2Fh Windows multiplex checks, stack/segment setup,
; protected-mode transition work, and error handling using strings later in the
; F4000 block.
;
;-------------------------------------------------------------------------------

F45F_0002_MINWIN_HANDOFF_TARGET:
F45F:0002  call  F570A              ; Early environment/CPU/memory check.
F45F:0005  jae   startup_check_ok
F45F:0007  mov   ax,4C01h           ; Abort to DOS with errorlevel 1 if the
F45F:000A  int   21h                ; Windows/standard-mode prerequisites fail.

startup_check_ok:
F45F:000C  mov   ax,ds
F45F:000E  mov   [0136h],es         ; Save caller/process context.
F45F:0012  mov   ss,ax
F45F:0014  mov   sp,0100h           ; Establish a small stack at offset 0100h.

F45F:0017  push  ds
F45F:0018  mov   ax,1605h           ; INT 2Fh AX=1605h is a Windows multiplex
F45F:001B  xor   bx,bx              ; style call. This is part of detecting or
F45F:001D  mov   cx,bx              ; notifying Windows/standard-mode state.
F45F:001F  mov   si,bx
F45F:0021  mov   ds,bx
F45F:0023  mov   es,bx
F45F:0025  mov   dx,0001h
F45F:0028  mov   di,030Ah
F45F:002B  int   2Fh
F45F:002D  pop   ax
F45F:002E  mov   ds,ax
F45F:0030  mov   es,ax
F45F:0032  jcxz  no_existing_windows_context

F45F:0034  mov   byte ptr [014Eh],02h
                         ; Existing/unsupported Windows context detected.
                         ; Branch to common cleanup/error reporting path.
F45F:0039  jmp   F46F8

no_existing_windows_context:
F45F:003C  call  F60C6              ; More startup validation.
F45F:003F  jae   validation_ok
F45F:0041  jmp   startup_error

validation_ok:
F45F:0044  push  ds
F45F:0045  mov   ax,cs
F45F:0047  mov   ds,ax
F45F:0049  mov   dx,06AAh
F45F:004C  mov   ax,2524h           ; Install INT 24h critical-error handler.
F45F:004F  int   21h
F45F:0051  pop   ds

F45F:0052  smsw  ax                 ; Inspect machine status word.
F45F:0055  test  al,01h             ; Check protected-mode bit.
F45F:0057  jne   already_protected
F45F:0059  push  ax
F45F:005A  and   al,04h
F45F:005C  mov   [0150h],al
F45F:005F  pop   ax
F45F:0060  and   al,0FBh
F45F:0062  lmsw  ax                 ; Adjust MSW before mode transition work.

already_protected:
F45F:0065  cli
F45F:0066  call  F4E31              ; Standard-mode setup helper.
F45F:0069  call  F4FA0              ; Standard-mode setup helper.
F45F:006C  ljmp  0053h:0002h        ; Far jump into newly prepared execution
                         ; context. This is a major reason VISENV cannot simply
                         ; "call F45F:0002" without emulating the surrounding
                         ; Windows/standard-mode loader contract.

;-------------------------------------------------------------------------------
; Notable later strings in this region
;-------------------------------------------------------------------------------
; F5962  "Cannot start Windows in Standard Mode."
; F598E  "Make sure your computer has an Intel 80286, 80386, or 80486 processor."
; F5A8C  "HIMEM Error."
; F5CB0  "EMMXXXX0MICROSOFT EXPANDED MEMORY MANAGER 386..."
; F5F60  "PATH"
; F5F65  "WINDIR"
;
; These strings strongly support identifying the F4000 code as a Modular Windows
; / Standard Mode startup loader, not a VIS title launcher. The VIS-specific
; title launcher is TLAUNCH; this is the Windows runtime side after MINWIN.
;-------------------------------------------------------------------------------
