; ===========================================================================
; 00 - D8800 Option ROM Header and Export Table
; ===========================================================================
; ROM range: 0xD8800-0xD895F
; Entry model: Phoenix option-ROM scan enters the 55 AA option-ROM init path; exports are later used by ROM EXEC resolver.
;
; VIS-specific role:
;   VIS-specific boot/runtime root. Installs or participates in the custom INT 19h boot handoff and publishes named ROM module exports.
;
; Dependencies:
;   Phoenix BIOS option-ROM scan; later D8960 boot core and ROM EXEC resolver.
;
; VISENV stub guidance:
;   VISENV can implement this as a static export table: COMMAND, MSCDEX, MINWIN, GBIOS, REDIR, TLAUNCH, ROMA, ROMB.
;
; Confidence:
;   High for table structure and names; medium for every byte of early option-ROM init behavior.
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

; Module: D8800 VIS option ROM header, boot hook, and export table
; ROM range: D8800-D895F
; Role: VIS boot takeover root and ROM module export directory
; Entry model: found by normal Phoenix/PC option-ROM scan because D8800 begins with 55 AA.
; VIS-specific significance:
;   This is the point where a mostly normal Phoenix BIOS stops behaving like a generic PC boot path.
;   The option ROM installs a custom INT 19h boot vector and provides named ROM exports that can be EXECed later.
; Stub priority: highest for VISENV. The export table is the map from bare EXEC names to ROM modules.

; ---------------------------------------------------------------------------
; SECTION: PC-compatible option-ROM header
; ---------------------------------------------------------------------------
D8800_option_header:
D8800:  db 055h,0AAh,07Fh
; CONFIRMED: standard option-ROM signature.
; 07Fh * 512 = 65024 bytes, covering D8800-E85FF.
; VIS meaning: Phoenix BIOS discovers this normally while scanning option ROMs.

D8803:  jmp D88B2_option_init
; The option ROM initialization entry is ordinary PC BIOS mechanism.
; What it installs is VIS-specific.

; ---------------------------------------------------------------------------
; SECTION: D8800 export table
; ---------------------------------------------------------------------------
; Format:
;   db name_length
;   db uppercase ASCII name
;   jmp export_stub
;
; The ROM EXEC resolver scans this table when INT 21h AH=4Bh receives a bare name.
; That is why COMMAND can EXEC "gbios" even though there is no GBIOS.EXE file.

D8806_export_COMMAND:
D8806:  db 07h,'COMMAND'
D880E:  jmp D88DB_stub_COMMAND
; Resolves to DC3C0 startup dispatcher.

D8811_export_MSCDEX:
D8811:  db 06h,'MSCDEX'
D8818:  jmp D88E8_stub_MSCDEX
; Resolves to DC460 CD-ROM / DOS hook module.

D881B_export_MINWIN:
D881B:  db 06h,'MINWIN'
D8822:  jmp D8919_stub_MINWIN
; Present as ROM export, but COMMAND does not launch it during resident setup.
; TLAUNCH launches MINWIN after CONTROL.TAT validation for Modular Windows titles.

D8825_export_GBIOS:
D8825:  db 05h,'GBIOS'
D882B:  jmp D890C_stub_GBIOS
; Resolves to E1660 VIS BIOS Extensions.

D882E_export_REDIR:
D882E:  db 05h,'REDIR'
D8834:  jmp D88F9_stub_REDIR
; Resolves to E8AD0 redirector/config provider.

D8837_export_TLAUNCH:
D8837:  db 07h,'TLAUNCH'
D883F:  jmp D8926_stub_TLAUNCH
; Resolves to E9880 media/title launcher.

D8842_export_ROMA:
D8842:  db 04h,'ROMA'
D8847:  jmp D8933_ROMA_probe
; Probes external ROM region C000:0000.

D884A_export_ROMB:
D884A:  db 04h,'ROMB'
D884F:  jmp D8950_ROMB_probe
; Probes external ROM region C400:0000.

D8852_export_table_end:
D8852:  db 00h
; End of local export names.

; ---------------------------------------------------------------------------
; SECTION: Microsoft Modular Windows identity string
; ---------------------------------------------------------------------------
D8864_modwin_string:
    db 'Microsoft Modular Windows',0
D887E_version_string:
    db 'Version 1.0',0
D888A_copyright_string:
    db 'Copyright (c) 1985-1992 Microsoft Corp.',0
; Developer meaning:
;   The VIS ROM is not just a BIOS. It embeds the Modular Windows runtime substrate.

; ---------------------------------------------------------------------------
; SECTION: option-ROM initialization installs INT 19h
; ---------------------------------------------------------------------------
D88B2_option_init:
    pushf
    push es
    push ax
    xor  ax,ax
    mov  es,ax
    mov  ax,0156h
    mov  es:[0064h],ax       ; IVT entry for INT 19h offset
    mov  ax,cs
    mov  es:[0066h],ax       ; IVT entry for INT 19h segment
    pop  ax
    pop  es
    popf
    retf
; CONFIRMED: installs INT 19h vector to CS:0156, physical D8956.
; Normal PC behavior: BIOS calls INT 19h to boot from a device.
; VIS-specific behavior: INT 19h no longer boots floppy/hard disk. It enters the VIS ROM boot core.

; ---------------------------------------------------------------------------
; SECTION: INT 19h / boot entry path
; ---------------------------------------------------------------------------
D8956_int19_entry:
D8956:  int3
D8957:  jmp D88CB_enter_boot_core
; INT3 appears as a debug/breakpoint byte before the jump. The practical path jumps into the boot-core transfer stub.

D88CB_enter_boot_core:
    mov  bx,cs
    add  bx,cs:[0054h]
    push bx
    xor  bx,bx
    push bx
    mov  bx,cs
    mov  es,bx
    retf
; LIKELY: far-return into the D8960 boot/core environment.
; VISENV implication: this is the start of the ROM DOS-like substrate, not a normal disk boot sector.

; ---------------------------------------------------------------------------
; SECTION: representative export stubs
; ---------------------------------------------------------------------------
D88DB_stub_COMMAND:
    int3
    mov  ax,cs
    add  ax,cs:[0058h]
    push ax
    xor  ax,ax
    push ax
    retf
; Enters COMMAND target segment at offset 0000.

D890C_stub_GBIOS:
    int3
    mov  ax,cs
    add  ax,cs:[005Eh]
    push ax
    xor  ax,ax
    push ax
    retf
; Enters GBIOS target segment at offset 0000.

D8926_stub_TLAUNCH:
    int3
    mov  ax,cs
    add  ax,cs:[0062h]
    push ax
    xor  ax,ax
    push ax
    retf
; Enters TLAUNCH at E988:0000.

; Note:
;   The INT3 bytes are probably not ordinary runtime traps in production flow.
;   They may be development breadcrumbs or used because entry normally lands after the INT3.
;   Do not treat them as proof these stubs are invalid.
