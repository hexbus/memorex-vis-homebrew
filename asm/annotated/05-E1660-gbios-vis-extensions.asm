; ===========================================================================
; 05 - GBIOS / VIS BIOS Extensions
; ===========================================================================
; ROM range: 0xE1660-0xE8ACF
; Entry model: Launched by COMMAND as EXEC "gbios" after MSCDEX.
;
; VIS-specific role:
;   Installs VIS-specific BIOS extension services. Likely homebrew-relevant for video/audio/timer/hand-control/memory-card support; contains General MIDI instrument table.
;
; Dependencies:
;   MSCDEX already initialized; REDIR depends on GBIOS services.
;
; VISENV stub guidance:
;   VISENV should initially install/log INT 15h and INT 2Fh service calls, then add port/device emulation as service IDs are identified.
;
; Confidence:
;   High for install role; medium for individual service IDs.
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

; ============================================================================
; Memorex/Tandy VIS ROM - GBIOS / VIS BIOS Extensions
; Source-style annotated working listing - Stage 28
; ROM range: 0xE1660-0xE8ACF
; Export name: GBIOS
; Launched by: COMMAND dispatcher through INT 21h AH=4Bh EXEC "gbios"
;
; Purpose in VIS boot:
;   GBIOS is the VIS low-level service installer. It is not just a utility.
;   It installs resident VIS BIOS Extensions, including INT 15h and INT 2Fh
;   hooks, and appears to provide services used by later runtime pieces such as
;   REDIR, Modular Windows drivers, memory-card support, audio/timer/video
;   support, and possibly development-card hardware abstractions.
;
; Boot position:
;   COMMAND dispatcher order:
;       EXEC "mscdex"
;       EXEC "gbios"     <-- this module
;       EXEC "redir"
;       EXEC "roma"
;       EXEC "romb"
;       loop EXEC "tlaunch"
;
; VIS-specific meaning:
;   On a normal DOS/Windows 3.1 PC there is no GBIOS step.  VIS uses this ROM
;   export to install the VIS-specific BIOS extension layer before REDIR and
;   TLAUNCH run.  A VISENV/DOSBox simulation must either run this module or stub
;   the services it installs.
; ============================================================================

GBIOS_ENTRY:
    jmp     GBIOS_INSTALL_START

GBIOS_REVISION_STRING:
    db      "0.153 - Mon Sep 28 13:47:13 1992",0

; ----------------------------------------------------------------------------
; GBIOS_INSTALL_START
; ----------------------------------------------------------------------------
; This is the install-time entry point reached when COMMAND EXECs "gbios".
;
; The first thing it does is call INT 15h with AX=7100.  Because GBIOS later
; installs an INT 15h hook, this is likely the "are you already installed?" /
; service-presence check.  If AX still has the expected VISBIOS-style response,
; the installer prints "VISBIOS: Already installed." and exits.
;
; It then checks whether Windows/Modular Windows is already running via INT 2Fh
; (see GBIOS_CHECK_WINDOWS_RUNNING).  If Windows is already active, it refuses
; to install.  That is important for homebrew: GBIOS is a pre-Windows resident
; layer, not a DLL loaded after Modular Windows starts.
; ----------------------------------------------------------------------------

/mnt/data/VIS_ROM_STAGE28_GBIOS_SERVICE_RECOVERY_PACK/raw/GBIOS_E1660_E8ACF.bin:     file format binary


Disassembly of section .data:

000e1660 <.data>:
   e1660:	e9 2d 00             	jmp    0xe1690
   e1663:	30 2e 31 35          	xor    %ch,0x3531
   e1667:	33 20                	xor    (%bx,%si),%sp
   e1669:	2d 20 4d             	sub    $0x4d20,%ax
   e166c:	6f                   	outsw  %ds:(%si),(%dx)
   e166d:	6e                   	outsb  %ds:(%si),(%dx)
   e166e:	20 53 65             	and    %dl,0x65(%bp,%di)
   e1671:	70 20                	jo     0xe1693
   e1673:	32 38                	xor    (%bx,%si),%bh
   e1675:	20 31                	and    %dh,(%bx,%di)
   e1677:	33 3a                	xor    (%bp,%si),%di
   e1679:	34 37                	xor    $0x37,%al
   e167b:	3a 31                	cmp    (%bx,%di),%dh
   e167d:	33 20                	xor    (%bx,%si),%sp
   e167f:	31 39                	xor    %di,(%bx,%di)
   e1681:	39 32                	cmp    %si,(%bp,%si)
	...
   e168f:	00 b8 00 71          	add    %bh,0x7100(%bx,%si)
   e1693:	b7 00                	mov    $0x0,%bh
   e1695:	cd 15                	int    $0x15
   e1697:	83 f8 71             	cmp    $0x71,%ax
   e169a:	75 10                	jne    0xe16ac
   e169c:	8c c8                	mov    %cs,%ax
   e169e:	8e d8                	mov    %ax,%ds
   e16a0:	b4 09                	mov    $0x9,%ah
   e16a2:	ba 6a 4d             	mov    $0x4d6a,%dx
   e16a5:	cd 21                	int    $0x21
   e16a7:	b8 01 4c             	mov    $0x4c01,%ax
   e16aa:	cd 21                	int    $0x21
   e16ac:	e8 57 01             	call   0xe1806
   e16af:	0a c0                	or     %al,%al
   e16b1:	74 10                	je     0xe16c3
   e16b3:	8c c8                	mov    %cs,%ax
   e16b5:	8e d8                	mov    %ax,%ds
   e16b7:	b4 09                	mov    $0x9,%ah
   e16b9:	ba 32 4d             	mov    $0x4d32,%dx
   e16bc:	cd 21                	int    $0x21
   e16be:	b8 01 4c             	mov    $0x4c01,%ax
   e16c1:	cd 21                	int    $0x21
   e16c3:	b8 ff ff             	mov    $0xffff,%ax
   e16c6:	8e d8                	mov    %ax,%ds
   e16c8:	33 f6                	xor    %si,%si
   e16ca:	b9 08 00             	mov    $0x8,%cx
   e16cd:	83 bc c0 ff 00       	cmpw   $0x0,-0x40(%si)
   e16d2:	75 07                	jne    0xe16db
   e16d4:	83 bc c2 ff 00       	cmpw   $0x0,-0x3e(%si)
   e16d9:	74 15                	je     0xe16f0
   e16db:	83 c6 08             	add    $0x8,%si
   e16de:	e2 ed                	loop   0xe16cd
   e16e0:	8c c8                	mov    %cs,%ax
   e16e2:	8e d8                	mov    %ax,%ds
   e16e4:	b4 09                	mov    $0x9,%ah
   e16e6:	ba 00 4d             	mov    $0x4d00,%dx
   e16e9:	cd 21                	int    $0x21
   e16eb:	b8 01 4c             	mov    $0x4c01,%ax
   e16ee:	cd 21                	int    $0x21
   e16f0:	33 ff                	xor    %di,%di
   e16f2:	89 bc c0 ff          	mov    %di,-0x40(%si)
   e16f6:	83 c7 10             	add    $0x10,%di
   e16f9:	83 f9 08             	cmp    $0x8,%cx
   e16fc:	74 0c                	je     0xe170a
   e16fe:	8b bc b8 ff          	mov    -0x48(%si),%di
   e1702:	03 bc ba ff          	add    -0x46(%si),%di
   e1706:	89 bc c0 ff          	mov    %di,-0x40(%si)
   e170a:	83 f9 01             	cmp    $0x1,%cx
   e170d:	74 12                	je     0xe1721
   e170f:	c7 84 c8 ff 00 00    	movw   $0x0,-0x38(%si)
   e1715:	c7 84 ca ff 00 00    	movw   $0x0,-0x36(%si)
   e171b:	c7 84 cc ff 00 00    	movw   $0x0,-0x34(%si)
   e1721:	83 c7 0f             	add    $0xf,%di
   e1724:	83 e7 f0             	and    $0xfff0,%di
   e1727:	8b c7                	mov    %di,%ax
   e1729:	05 00 40             	add    $0x4000,%ax
   e172c:	2b 84 c0 ff          	sub    -0x40(%si),%ax
   e1730:	89 84 c2 ff          	mov    %ax,-0x3e(%si)
   e1734:	c7 84 c4 ff 42 47    	movw   $0x4742,-0x3c(%si)
   e173a:	ba ff ff             	mov    $0xffff,%dx
   e173d:	8b f7                	mov    %di,%si
   e173f:	e8 e0 00             	call   0xe1822
   e1742:	81 ee b0 bf          	sub    $0xbfb0,%si
   e1746:	83 da 00             	sbb    $0x0,%dx
   e1749:	c1 ca 04             	ror    $0x4,%dx
   e174c:	c1 ee 04             	shr    $0x4,%si
   e174f:	0b d6                	or     %si,%dx
   e1751:	8e da                	mov    %dx,%ds
   e1753:	1e                   	push   %ds
   e1754:	06                   	push   %es
   e1755:	8c d8                	mov    %ds,%ax
   e1757:	8e c0                	mov    %ax,%es
   e1759:	8c c8                	mov    %cs,%ax
   e175b:	be d0 4d             	mov    $0x4dd0,%si
   e175e:	c1 ee 04             	shr    $0x4,%si
   e1761:	03 c6                	add    %si,%ax
   e1763:	8e d8                	mov    %ax,%ds
   e1765:	33 f6                	xor    %si,%si
   e1767:	bf b0 bf             	mov    $0xbfb0,%di
   e176a:	b9 50 e6             	mov    $0xe650,%cx
   e176d:	81 e9 b0 bf          	sub    $0xbfb0,%cx
   e1771:	f3 a4                	rep movsb %ds:(%si),%es:(%di)
   e1773:	07                   	pop    %es
   e1774:	1f                   	pop    %ds
   e1775:	c7 06 c0 bf 50 e6    	movw   $0xe650,-0x4040
   e177b:	1e                   	push   %ds
   e177c:	8c c8                	mov    %cs,%ax
   e177e:	8e d8                	mov    %ax,%ds
   e1780:	b4 09                	mov    $0x9,%ah
   e1782:	ba 8c 4d             	mov    $0x4d8c,%dx
   e1785:	cd 21                	int    $0x21
   e1787:	1f                   	pop    %ds
   e1788:	06                   	push   %es
   e1789:	b8 8e 01             	mov    $0x18e,%ax
   e178c:	a3 c4 bf             	mov    %ax,0xbfc4
   e178f:	8c 0e c6 bf          	mov    %cs,-0x403a
   e1793:	b8 15 35             	mov    $0x3515,%ax
   e1796:	cd 21                	int    $0x21
   e1798:	89 1e 50 c1          	mov    %bx,-0x3eb0
   e179c:	8c 06 52 c1          	mov    %es,-0x3eae
   e17a0:	1e                   	push   %ds
   e17a1:	07                   	pop    %es
   e17a2:	b8 15 25             	mov    $0x2515,%ax
   e17a5:	ba 4e c1             	mov    $0xc14e,%dx
   e17a8:	cd 21                	int    $0x21
   e17aa:	b8 2f 35             	mov    $0x352f,%ax
   e17ad:	cd 21                	int    $0x21
   e17af:	89 1e 9c c1          	mov    %bx,-0x3e64
   e17b3:	8c 06 9e c1          	mov    %es,-0x3e62
   e17b7:	1e                   	push   %ds
   e17b8:	07                   	pop    %es
   e17b9:	b8 2f 25             	mov    $0x252f,%ax
   e17bc:	ba 9a c1             	mov    $0xc19a,%dx
   e17bf:	cd 21                	int    $0x21
   e17c1:	07                   	pop    %es
   e17c2:	e8 06 00             	call   0xe17cb
   e17c5:	1e                   	push   %ds
   e17c6:	b8 cf c1             	mov    $0xc1cf,%ax
   e17c9:	50                   	push   %ax
   e17ca:	cb                   	lret
   e17cb:	e8 9a 1e             	call   0xe3668
   e17ce:	e8 83 2c             	call   0xe4454
   e17d1:	e8 9c 00             	call   0xe1870
   e17d4:	e8 2d 05             	call   0xe1d04
   e17d7:	e8 4e 07             	call   0xe1f28
   e17da:	e8 e8 28             	call   0xe40c5
   e17dd:	c3                   	ret
   e17de:	4b                   	dec    %bx
   e17df:	02 5b 07             	add    0x7(%bp,%di),%bl
   e17e2:	3c 03                	cmp    $0x3,%al
   e17e4:	0d 0a 51             	or     $0x510a,%ax
   e17e7:	0a 2c                	or     (%si),%ch
   e17e9:	20 88 2a 1b          	and    %cl,0x1b2a(%bx,%si)
   e17ed:	2e 60                	cs pusha
   e17ef:	06                   	push   %es
   e17f0:	8b ec                	mov    %sp,%bp
   e17f2:	3c 07                	cmp    $0x7,%al
   e17f4:	77 0e                	ja     0xe1804
   e17f6:	32 e4                	xor    %ah,%ah
   e17f8:	d1 e0                	shl    $1,%ax
   e17fa:	8b f8                	mov    %ax,%di
   e17fc:	8b 46 10             	mov    0x10(%bp),%ax
   e17ff:	2e ff a5 7e 01       	jmp    *%cs:0x17e(%di)
   e1804:	eb 4d                	jmp    0xe1853
   e1806:	b8 00 16             	mov    $0x1600,%ax
   e1809:	cd 2f                	int    $0x2f
   e180b:	0a c0                	or     %al,%al
   e180d:	74 07                	je     0xe1816
   e180f:	3c 80                	cmp    $0x80,%al
   e1811:	74 03                	je     0xe1816
   e1813:	b0 01                	mov    $0x1,%al
   e1815:	c3                   	ret
   e1816:	b8 80 46             	mov    $0x4680,%ax
   e1819:	cd 2f                	int    $0x2f
   e181b:	0b c0                	or     %ax,%ax
   e181d:	74 f4                	je     0xe1813


; ----------------------------------------------------------------------------
; GBIOS_CHECK_WINDOWS_RUNNING
; ----------------------------------------------------------------------------
; This helper uses INT 2Fh multiplex calls.  AX=1600 is the standard Windows
; enhanced/standard mode detection family.  AX=4680 is also used here as part of
; the install guard.  The behavior observed in the installer:
;
;   return AL = 0  -> OK to continue installing GBIOS
;   return AL != 0 -> Windows/Modular Windows appears active; refuse install
;
; This matches the user-facing string:
;   "VISBIOS: Cannot install while Windows is running."
; ----------------------------------------------------------------------------

/mnt/data/VIS_ROM_STAGE28_GBIOS_SERVICE_RECOVERY_PACK/raw/GBIOS_E1660_E8ACF.bin:     file format binary


Disassembly of section .data:

000e1806 <.data+0x1a6>:
   e1806:	b8 00 16             	mov    $0x1600,%ax
   e1809:	cd 2f                	int    $0x2f
   e180b:	0a c0                	or     %al,%al
   e180d:	74 07                	je     0xe1816
   e180f:	3c 80                	cmp    $0x80,%al
   e1811:	74 03                	je     0xe1816
   e1813:	b0 01                	mov    $0x1,%al
   e1815:	c3                   	ret
   e1816:	b8 80 46             	mov    $0x4680,%ax
   e1819:	cd 2f                	int    $0x2f
   e181b:	0b c0                	or     %ax,%ax
   e181d:	74 f4                	je     0xe1813
   e181f:	32 c0                	xor    %al,%al
   e1821:	c3                   	ret


; ----------------------------------------------------------------------------
; Resident service notes
; ----------------------------------------------------------------------------
; During successful install, GBIOS:
;
;   1. Locates/allocates a resident data/code area.  The failure string says
;      "Cannot allocate data space in HMA."  The code also refers to a marker
;      string "GBIOSRAM" and stack labels such as gbioSTAK/waveSTAK/timeSTAK.
;
;   2. Copies the resident block beginning around the GBIOSRAM area into that
;      runtime location.
;
;   3. Saves old INT 15h and INT 2Fh vectors using DOS INT 21h AH=35h.
;
;   4. Installs new INT 15h and INT 2Fh handlers using DOS INT 21h AH=25h.
;
;      Observed install calls:
;         AX=3515h -> get old INT 15h vector
;         AX=2515h -> set new INT 15h vector
;         AX=352Fh -> get old INT 2Fh vector
;         AX=252Fh -> set new INT 2Fh vector
;
; VISENV implication:
;   A simulator can initially stub this by responding to key INT 15h AX=71xx
;   services and enough INT 2Fh behavior for REDIR and TLAUNCH to proceed.
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Known later self-call into INT 15h service family
; ----------------------------------------------------------------------------
; This code issues INT 15h AX=7106h from inside GBIOS.  That strongly supports
; the model that GBIOS owns a VISBIOS INT 15h service family in the AX=71xx
; range.  Exact service semantics still need naming by tracing the resident
; handler dispatch table.
; ----------------------------------------------------------------------------

/mnt/data/VIS_ROM_STAGE28_GBIOS_SERVICE_RECOVERY_PACK/raw/GBIOS_E1660_E8ACF.bin:     file format binary


Disassembly of section .data:

000e40b8 <.data+0x2a58>:
   e40b8:	26 c7 44 05 00 00    	movw   $0x0,%es:0x5(%si)
   e40be:	26 c7 44 07 00 00    	movw   $0x0,%es:0x7(%si)
   e40c4:	c3                   	ret
   e40c5:	b8 06 71             	mov    $0x7106,%ax
   e40c8:	bb 00 05             	mov    $0x500,%bx
   e40cb:	cd 15                	int    $0x15
   e40cd:	c3                   	ret
   e40ce:	f3 01 9e 2a        	repz add %bx,-0x4cd6(%bp)


; ----------------------------------------------------------------------------
; Timer-related hook candidate
; ----------------------------------------------------------------------------
; This region gets and sets INT 08h, the hardware timer interrupt.  That aligns
; with the nearby visible timeSTAK string area and suggests GBIOS provides or
; supports timer services for audio/MIDI/Modular Windows.
; ----------------------------------------------------------------------------

/mnt/data/VIS_ROM_STAGE28_GBIOS_SERVICE_RECOVERY_PACK/raw/GBIOS_E1660_E8ACF.bin:     file format binary


Disassembly of section .data:

000e4458 <.data+0x2df8>:
   e4458:	00 c4                	add    %al,%ah
   e445a:	8c 0e 02 c4          	mov    %cs,-0x3bfe
   e445e:	06                   	push   %es
   e445f:	b8 08 35             	mov    $0x3508,%ax
   e4462:	cd 21                	int    $0x21
   e4464:	89 1e 0a c5          	mov    %bx,-0x3af6
   e4468:	8c 06 0c c5          	mov    %es,-0x3af4
   e446c:	07                   	pop    %es
   e446d:	b8 08 25             	mov    $0x2508,%ax
   e4470:	ba 35 c5             	mov    $0xc535,%dx
   e4473:	cd 21                	int    $0x21
   e4475:	f8                   	clc
   e4476:	c3                   	ret
   e4477:	31             	xor    %bp,0x2e48


; ----------------------------------------------------------------------------
; GBIOS data regions and embedded tables
; ----------------------------------------------------------------------------
; Important embedded strings/tables:
;
;   0xE6362  "VISBIOS: Cannot allocate data space in HMA."
;   0xE6394  "VISBIOS: Cannot install while Windows is running."
;   0xE63CC  "VISBIOS: Already installed."
;   0xE63EB  "$$VIS BIOS Extensions Revision 0.153 - Mon Sep 28 13:47:13 1992"
;   0xE6430  "GBIOSRAM"
;   0xE644C  repeated "gbioSTAK"
;   0xE66C8  repeated "waveSTAK"
;   0xE6888  repeated "timeSTAK"
;   0xE803E  128-entry General MIDI-style instrument table, 16 bytes per entry
;
; These are not random strings.  They are the visible landmarks for the resident
; service block, stack/data allocation, audio/wave/timer support, and MIDI patch
; naming used by the VIS audio layer.
; ----------------------------------------------------------------------------

GBIOS_GENERAL_MIDI_TABLE:
    ; See data_tables/GBIOS_GENERAL_MIDI_INSTRUMENT_TABLE.md
    ; Starts at ROM offset 0xE803E, 128 entries x 16 bytes.
