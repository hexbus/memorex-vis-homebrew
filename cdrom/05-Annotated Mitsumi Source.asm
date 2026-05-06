; ---------------------------------------------------------------------------
; Mitsumi / Gryphon CD-ROM Driver
; ---------------------------------------------------------------------------
; Source: extracted from VIS 1 MiB ROM baseline.
; Purpose: lower CD-ROM DOS device driver used below the ROM MSCDEX layer.
;
; Important addresses:
;   0xED067  embedded command line:
;            cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h
;   0xED08D  DOS device-driver header
;   0xEDA18  strategy entry, header offset 0x098B
;   0xEDA23  interrupt entry, header offset 0x0996
;   0xF14A2  version string:
;            GRYPHON CD-ROM device driver - Version is 2(33) 29-Sep-92
;
; Header decode at 0xED08D:
;   next pointer      ff ff ff ff
;   attributes        0xC800
;   strategy offset   0x098B
;   interrupt offset  0x0996
;   placeholder name  12345678
;
; High-level behavior:
;   MSCDEX discovers this as an MSCD00/MSCD001-style CD-ROM device driver.
;   MSCDEX calls the strategy entry with ES:BX pointing to a request header.
;   The strategy entry stores ES:BX in driver globals.
;   The interrupt entry reads request_header[2] as the command byte and
;   dispatches through jump tables at driver offsets 0x0519 and 0x0539.
;
; Notes:
;   This file is a disassembly aid, not reconstructed original source.
;   Some linear disassembly crosses data tables and strings. Use the maps/*.csv
;   tables and comments below to orient review.
; ---------------------------------------------------------------------------

; Primary DOS device-driver command dispatch table at driver offset 0x0519
; See maps/mitsumi_dos_request_dispatch_table.csv
;   0x00  INIT                         -> 0xF0CD9  (0x3C4C)
;   0x01  MEDIA CHECK                  -> 0xEE02C  (0x0F9F)
;   0x02  BUILD BPB                    -> 0xEDB74  (0x0AE7)
;   0x03  IOCTL INPUT                  -> 0xEE034  (0x0FA7)
;   0x04  INPUT / READ                 -> 0xEDB74  (0x0AE7)
;   0x05  NON-DESTRUCTIVE INPUT        -> 0xEDB74  (0x0AE7)
;   0x06  INPUT STATUS                 -> 0xEDB74  (0x0AE7)
;   0x07  INPUT FLUSH                  -> 0xEDBA6  (0x0B19)
;   0x08  OUTPUT / WRITE               -> 0xEDB74  (0x0AE7)
;   0x09  OUTPUT WITH VERIFY           -> 0xEDB74  (0x0AE7)
;   0x0A  OUTPUT STATUS                -> 0xEDB74  (0x0AE7)
;   0x0B  OUTPUT FLUSH                 -> 0xEDB74  (0x0AE7)
;   0x0C  IOCTL OUTPUT                 -> 0xEDBD0  (0x0B43)
;   0x0D  DEVICE OPEN                  -> 0xEDB8C  (0x0AFF)
;   0x0E  DEVICE CLOSE                 -> 0xEDB8C  (0x0AFF)
;   0x0F  REMOVABLE MEDIA              -> 0xEDB74  (0x0AE7)
;   0x80  extended/vendor command      -> 0xEF656  (0x25C9)
;   0x81  extended/vendor command      -> 0xEDB74  (0x0AE7)
;   0x82  extended/vendor command      -> 0xEFE93  (0x2E06)
;   0x83  extended/vendor command      -> 0xF000E  (0x2F81)
;   0x84  extended/vendor command      -> 0xF01A0  (0x3113)
;   0x85  extended/vendor command      -> 0xF051A  (0x348D)
;   0x86  extended/vendor command      -> 0xEDB74  (0x0AE7)
;   0x87  extended/vendor command      -> 0xEDB74  (0x0AE7)
;   0x88  extended/vendor command      -> 0xF0652  (0x35C5)

; ---------------------------------------------------------------------------
; Raw objdump follows
; ---------------------------------------------------------------------------


/mnt/data/_mitsumi_driver_region.bin:     file format binary


Disassembly of section .data:

000ed067 <.data>:
   ed067:	63 64 2e             	arpl   %sp,0x2e(%si)
   ed06a:	73 79                	jae    0xed0e5
   ed06c:	73 20                	jae    0xed08e
   ed06e:	2f                   	das
   ed06f:	6d                   	insw   (%dx),%es:(%di)
   ed070:	3a 31                	cmp    (%bx,%di),%dh
   ed072:	38 20                	cmp    %ah,(%bx,%si)
   ed074:	2f                   	das
   ed075:	69 3a 35 20          	imul   $0x2035,(%bp,%si),%di
   ed079:	2f                   	das
   ed07a:	74 3a                	je     0xed0b6
   ed07c:	35 20 2f             	xor    $0x2f20,%ax
   ed07f:	64 3a 6d 73          	cmp    %fs:0x73(%di),%ch
   ed083:	63 64 30             	arpl   %sp,0x30(%si)
   ed086:	30 31                	xor    %dh,(%bx,%di)
   ed088:	20 2f                	and    %ch,(%bx)
   ed08a:	68 0d 00             	push   $0xd
   ed08d:	ff                   	(bad)
   ed08e:	ff                   	(bad)
   ed08f:	ff                   	(bad)
   ed090:	ff 00                	incw   (%bx,%si)
   ed092:	c8 8b 09 96          	enter  $0x98b,$0x96
   ed096:	09 31                	or     %si,(%bx,%di)
   ed098:	32 33                	xor    (%bp,%di),%dh
   ed09a:	34 35                	xor    $0x35,%al
   ed09c:	36 37                	ss aaa
   ed09e:	38 00                	cmp    %al,(%bx,%si)
   ed0a0:	00 00                	add    %al,(%bx,%si)
   ed0a2:	01 00                	add    %ax,(%bx,%si)
   ed0a4:	00 00                	add    %al,(%bx,%si)
   ed0a6:	00 43 6f             	add    %al,0x6f(%bp,%di)
   ed0a9:	70 79                	jo     0xed124
   ed0ab:	72 69                	jb     0xed116
   ed0ad:	67 68 74 20          	addr32 push $0x2074
   ed0b1:	28 43 29             	sub    %al,0x29(%bp,%di)
   ed0b4:	20 4d 69             	and    %cl,0x69(%di)
   ed0b7:	74 73                	je     0xed12c
   ed0b9:	75 6d                	jne    0xed128
   ed0bb:	69 20 63 6f          	imul   $0x6f63,(%bx,%si),%sp
   ed0bf:	72 70                	jb     0xed131
   ed0c1:	6f                   	outsw  %ds:(%si),(%dx)
   ed0c2:	72 61                	jb     0xed125
   ed0c4:	74 69                	je     0xed12f
   ed0c6:	6f                   	outsw  %ds:(%si),(%dx)
   ed0c7:	6e                   	outsb  %ds:(%si),(%dx)
   ed0c8:	20 31                	and    %dh,(%bx,%di)
   ed0ca:	39 38                	cmp    %di,(%bx,%si)
   ed0cc:	39 2c                	cmp    %bp,(%si)
   ed0ce:	31 39                	xor    %di,(%bx,%di)
   ed0d0:	39 30                	cmp    %si,(%bx,%si)
   ed0d2:	2c 31                	sub    $0x31,%al
   ed0d4:	39 39                	cmp    %di,(%bx,%di)
   ed0d6:	31 2e 20 41          	xor    %bp,0x4120
   ed0da:	6c                   	insb   (%dx),%es:(%di)
   ed0db:	6c                   	insb   (%dx),%es:(%di)
   ed0dc:	20 72 69             	and    %dh,0x69(%bp,%si)
   ed0df:	67 68 74 20          	addr32 push $0x2074
   ed0e3:	72 65                	jb     0xed14a
   ed0e5:	73 65                	jae    0xed14c
   ed0e7:	72 76                	jb     0xed15f
   ed0e9:	65 64 20 20          	gs and %ah,%fs:(%bx,%si)
   ed0ed:	02 10                	add    (%bx,%si),%dl
   ed0ef:	03 11                	add    (%bx,%di),%dx
   ed0f1:	03 11                	add    (%bx,%di),%dx
   ed0f3:	03 12                	add    (%bp,%si),%dx
   ed0f5:	03 00                	add    (%bx,%si),%ax
	...
   ed10f:	00 00                	add    %al,(%bx,%si)
   ed111:	ff                   	(bad)
   ed112:	ff                   	(bad)
   ed113:	ff                   	(bad)
   ed114:	ff 00                	incw   (%bx,%si)
	...
   ed12e:	ff                   	(bad)
   ed12f:	ff                   	(bad)
   ed130:	ff                   	(bad)
   ed131:	ff 00                	incw   (%bx,%si)
   ed133:	00 00                	add    %al,(%bx,%si)
   ed135:	00 00                	add    %al,(%bx,%si)
   ed137:	20 02                	and    %al,(%bp,%si)
   ed139:	40                   	inc    %ax
   ed13a:	02 60 02             	add    0x2(%bx,%si),%ah
   ed13d:	80 02 a0             	addb   $0xa0,(%bp,%si)
   ed140:	02 c0                	add    %al,%al
   ed142:	02 e0                	add    %al,%ah
   ed144:	02 00                	add    (%bx,%si),%al
   ed146:	03 40 03             	add    0x3(%bx,%si),%ax
   ed149:	60                   	pusha
   ed14a:	03 c0                	add    %ax,%ax
   ed14c:	03 e0                	add    %ax,%sp
   ed14e:	03 00                	add    (%bx,%si),%ax
   ed150:	00 00                	add    %al,(%bx,%si)
   ed152:	00 03                	add    %al,(%bp,%di)
   ed154:	f7 63 00             	mulw   0x0(%bp,%di)
   ed157:	00 02                	add    %al,(%bp,%si)
   ed159:	02 02                	add    (%bp,%si),%al
   ed15b:	00 0f                	add    %cl,(%bx)
	...
   ed16d:	00 ff                	add    %bh,%bh
   ed16f:	ff                   	(bad)
   ed170:	ff                   	(bad)
   ed171:	ff 00                	incw   (%bx,%si)
	...
   ed183:	00 00                	add    %al,(%bx,%si)
   ed185:	01 00                	add    %ax,(%bx,%si)
	...
   ed43f:	00 00                	add    %al,(%bx,%si)
   ed441:	00 01                	add    %al,(%bx,%di)
   ed443:	00 01                	add    %al,(%bx,%di)
	...
   ed44d:	00 00                	add    %al,(%bx,%si)
   ed44f:	00 ff                	add    %bh,%bh
	...
   ed461:	00 00                	add    %al,(%bx,%si)
   ed463:	08 03                	or     %al,(%bp,%di)
   ed465:	62 00                	bound  %ax,(%bx,%si)
	...
   ed4cb:	01 02                	add    %ax,(%bp,%si)
   ed4cd:	04 08                	add    $0x8,%al
   ed4cf:	10 20                	adc    %ah,(%bx,%si)
   ed4d1:	03 06 0c 18          	add    0x180c,%ax
   ed4d5:	30 23                	xor    %ah,(%bp,%di)
   ed4d7:	05 0a 14             	add    $0x140a,%ax
   ed4da:	28 13                	sub    %dl,(%bp,%di)
   ed4dc:	26 0f 1e 3c          	nopw   %es:(%si)
   ed4e0:	3b 35                	cmp    (%di),%si
   ed4e2:	29 11                	sub    %dx,(%bx,%di)
   ed4e4:	22 07                	and    (%bx),%al
   ed4e6:	0e                   	push   %cs
   ed4e7:	1c 38                	sbb    $0x38,%al
   ed4e9:	33 25                	xor    (%di),%sp
   ed4eb:	09 12                	or     %dx,(%bp,%si)
   ed4ed:	24 0b                	and    $0xb,%al
   ed4ef:	16                   	push   %ss
   ed4f0:	2c 1b                	sub    $0x1b,%al
   ed4f2:	36 2f                	ss das
   ed4f4:	1d 3a 37             	sbb    $0x373a,%ax
   ed4f7:	2d 19 32             	sub    $0x3219,%ax
   ed4fa:	27                   	daa
   ed4fb:	0d 1a 34             	or     $0x341a,%ax
   ed4fe:	2b 15                	sub    (%di),%dx
   ed500:	2a 17                	sub    (%bx),%dl
   ed502:	2e 1f                	cs pop %ds
   ed504:	3e 3f                	ds aas
   ed506:	3d 39 31             	cmp    $0x3139,%ax
   ed509:	21 00                	and    %ax,(%bx,%si)
   ed50b:	00 01                	add    %al,(%bx,%di)
   ed50d:	06                   	push   %es
   ed50e:	02 0c                	add    (%si),%cl
   ed510:	07                   	pop    %es
   ed511:	1a 03                	sbb    (%bp,%di),%al
   ed513:	20 0d                	and    %cl,(%di)
   ed515:	23 08                	and    (%bx,%si),%cx
   ed517:	30 1b                	xor    %bl,(%bp,%di)
   ed519:	12 04                	adc    (%si),%al
   ed51b:	18 21                	sbb    %ah,(%bx,%di)
   ed51d:	10 0e 34 24          	adc    %cl,0x2434
   ed521:	36 09 2d             	or     %bp,%ss:(%di)
   ed524:	31 26 1c 29          	xor    %sp,0x291c
   ed528:	13 38                	adc    (%bx,%si),%di
   ed52a:	05 3e 19             	add    $0x193e,%ax
   ed52d:	0b 22                	or     (%bp,%si),%sp
   ed52f:	1f                   	pop    %ds
   ed530:	11 2f                	adc    %bp,(%bx)
   ed532:	0f 17 35             	movhps %xmm6,(%di)
   ed535:	33 25                	xor    (%di),%sp
   ed537:	2c 37                	sub    $0x37,%al
   ed539:	28 0a                	sub    %cl,(%bp,%si)
   ed53b:	3d 2e 1e             	cmp    $0x1e2e,%ax
   ed53e:	32 16 27 2b          	xor    0x2b27,%dl
   ed542:	1d 3c 2a             	sbb    $0x2a3c,%ax
   ed545:	15 14 3b             	adc    $0x3b14,%ax
   ed548:	39 3a                	cmp    %di,(%bp,%si)
   ed54a:	00 02                	add    %al,(%bp,%si)
   ed54c:	05 07 04             	add    $0x407,%ax
   ed54f:	02 06 07 00          	add    0x7,%al
   ed553:	01 02                	add    %ax,(%bp,%si)
   ed555:	03 04                	add    (%si),%ax
   ed557:	05 06 07             	add    $0x706,%ax
   ed55a:	00 01                	add    %al,(%bx,%di)
   ed55c:	01 03                	add    %ax,(%bp,%di)
   ed55e:	04 05                	add    $0x5,%al
   ed560:	06                   	push   %es
   ed561:	03 00                	add    (%bx,%si),%ax
   ed563:	12 05                	adc    (%di),%al
   ed565:	17                   	pop    %ss
   ed566:	04 02                	add    $0x2,%al
   ed568:	06                   	push   %es
   ed569:	07                   	pop    %es
   ed56a:	08 09                	or     %cl,(%bx,%di)
   ed56c:	0a 0b                	or     (%bp,%di),%cl
   ed56e:	0c 0d                	or     $0xd,%al
   ed570:	0e                   	push   %cs
   ed571:	0f 10 11             	movups (%bx,%di),%xmm2
   ed574:	01 13                	add    %dx,(%bp,%di)
   ed576:	14 15                	adc    $0x15,%al
   ed578:	16                   	push   %ss
   ed579:	03 00                	add    (%bx,%si),%ax
	...
   ed58f:	01 00                	add    %ax,(%bx,%si)
   ed591:	00 00                	add    %al,(%bx,%si)
   ed593:	00 00                	add    %al,(%bx,%si)
   ed595:	01 00                	add    %ax,(%bx,%si)
	...
   ed5a3:	00 00                	add    %al,(%bx,%si)
   ed5a5:	00 4c 3c             	add    %cl,0x3c(%si)
   ed5a8:	9f                   	lahf
   ed5a9:	0f e7 0a             	movntq %mm1,(%bp,%si)
   ed5ac:	a7                   	cmpsw  %es:(%di),%ds:(%si)
   ed5ad:	0f e7 0a             	movntq %mm1,(%bp,%si)
   ed5b0:	e7 0a                	out    %ax,$0xa
   ed5b2:	e7 0a                	out    %ax,$0xa
   ed5b4:	19 0b                	sbb    %cx,(%bp,%di)
   ed5b6:	e7 0a                	out    %ax,$0xa
   ed5b8:	e7 0a                	out    %ax,$0xa
   ed5ba:	e7 0a                	out    %ax,$0xa
   ed5bc:	e7 0a                	out    %ax,$0xa
   ed5be:	43                   	inc    %bx
   ed5bf:	0b ff                	or     %di,%di
   ed5c1:	0a ff                	or     %bh,%bh
   ed5c3:	0a e7                	or     %bh,%ah
   ed5c5:	0a c9                	or     %cl,%cl
   ed5c7:	25 e7 0a             	and    $0xae7,%ax
   ed5ca:	06                   	push   %es
   ed5cb:	2e 81 2f 13 31       	subw   $0x3113,%cs:(%bx)
   ed5d0:	8d 34                	lea    (%si),%si
   ed5d2:	e7 0a                	out    %ax,$0xa
   ed5d4:	e7 0a                	out    %ax,$0xa
   ed5d6:	c5 35                	lds    (%di),%si
   ed5d8:	e7 0a                	out    %ax,$0xa
   ed5da:	e7 0a                	out    %ax,$0xa
   ed5dc:	e7 0a                	out    %ax,$0xa
   ed5de:	e7 0a                	out    %ax,$0xa
   ed5e0:	e7 0a                	out    %ax,$0xa
   ed5e2:	e7 0a                	out    %ax,$0xa
   ed5e4:	e7 0a                	out    %ax,$0xa
   ed5e6:	69 0b b1 0b          	imul   $0xbb1,(%bp,%di),%cx
   ed5ea:	36 0c 95             	ss or  $0x95,%al
   ed5ed:	0c 9c                	or     $0x9c,%al
   ed5ef:	0f 4e 0e 22 1f       	cmovle 0x1f22,%cx
   ed5f4:	c8 0f ea 0f          	enter  $0xea0f,$0xf
   ed5f8:	22 1f                	and    (%bx),%bl
   ed5fa:	22 1f                	and    (%bx),%bl
   ed5fc:	ed                   	in     (%dx),%ax
   ed5fd:	10 0d                	adc    %cl,(%di)
   ed5ff:	12 1a                	adc    (%bp,%si),%bl
   ed601:	12 e8                	adc    %al,%ch
   ed603:	12 0d                	adc    (%di),%cl
   ed605:	13 96 13 76          	adc    0x7613(%bp),%dx
   ed609:	14 fd                	adc    $0xfd,%al
   ed60b:	14 bb                	adc    $0xbb,%al
   ed60d:	15 4c 16             	adc    $0x164c,%ax
   ed610:	a5                   	movsw  %ds:(%si),%es:(%di)
   ed611:	1d 35 1e             	sbb    $0x1e35,%ax
	...
   eda18:	2e 89 1e 16 00       	mov    %bx,%cs:0x16
   eda1d:	2e 8c 06 18 00       	mov    %es,%cs:0x18
   eda22:	cb                   	lret
   eda23:	9c                   	pushf
   eda24:	50                   	push   %ax
   eda25:	53                   	push   %bx
   eda26:	51                   	push   %cx
   eda27:	52                   	push   %dx
   eda28:	56                   	push   %si
   eda29:	57                   	push   %di
   eda2a:	55                   	push   %bp
   eda2b:	1e                   	push   %ds
   eda2c:	06                   	push   %es
   eda2d:	8c c8                	mov    %cs,%ax
   eda2f:	8e d8                	mov    %ax,%ds
   eda31:	fc                   	cld
   eda32:	fa                   	cli
   eda33:	2e 89 26 75 00       	mov    %sp,%cs:0x75
   eda38:	2e 8c 16 77 00       	mov    %ss,%cs:0x77
   eda3d:	8e d0                	mov    %ax,%ss
   eda3f:	bc 87 09             	mov    $0x987,%sp
   eda42:	fb                   	sti
   eda43:	c6 06 b0 03 00       	movb   $0x0,0x3b0
   eda48:	c6 06 af 03 00       	movb   $0x0,0x3af
   eda4d:	c4 1e 16 00          	les    0x16,%bx
   eda51:	26 8a 47 02          	mov    %es:0x2(%bx),%al
   eda55:	3c 00                	cmp    $0x0,%al
   eda57:	75 0f                	jne    0xeda68
   eda59:	8a 26 a7 03          	mov    0x3a7,%ah
   eda5d:	80 fc 01             	cmp    $0x1,%ah
   eda60:	74 23                	je     0xeda85
   eda62:	fe c4                	inc    %ah
   eda64:	88 26 a7 03          	mov    %ah,0x3a7
   eda68:	be 19 05             	mov    $0x519,%si
   eda6b:	b1 10                	mov    $0x10,%cl
   eda6d:	3c 80                	cmp    $0x80,%al
   eda6f:	72 07                	jb     0xeda78
   eda71:	be 39 05             	mov    $0x539,%si
   eda74:	b1 09                	mov    $0x9,%cl
   eda76:	2c 80                	sub    $0x80,%al
   eda78:	3a c1                	cmp    %cl,%al
   eda7a:	72 02                	jb     0xeda7e
   eda7c:	eb 07                	jmp    0xeda85
   eda7e:	98                   	cbtw
   eda7f:	d1 e0                	shl    $1,%ax
   eda81:	03 f0                	add    %ax,%si
   eda83:	ff 24                	jmp    *(%si)
   eda85:	b8 03 80             	mov    $0x8003,%ax
   eda88:	eb 03                	jmp    0xeda8d
   eda8a:	0d 00 02             	or     $0x200,%ax
   eda8d:	0d 00 01             	or     $0x100,%ax
   eda90:	2e 80 3e 00 05 00    	cmpb   $0x0,%cs:0x500
   eda96:	74 09                	je     0xedaa1
   eda98:	2e c6 06 00 05 00    	movb   $0x0,%cs:0x500
   eda9e:	25 f0 7f             	and    $0x7ff0,%ax
   edaa1:	80 3e b0 03 00       	cmpb   $0x0,0x3b0
   edaa6:	74 01                	je     0xedaa9
   edaa8:	90                   	nop
   edaa9:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   edaae:	26 89 47 03          	mov    %ax,%es:0x3(%bx)
   edab2:	8c c8                	mov    %cs,%ax
   edab4:	8e d8                	mov    %ax,%ds
   edab6:	fa                   	cli
   edab7:	2e 8b 26 75 00       	mov    %cs:0x75,%sp
   edabc:	2e 8e 16 77 00       	mov    %cs:0x77,%ss
   edac1:	fb                   	sti
   edac2:	07                   	pop    %es
   edac3:	1f                   	pop    %ds
   edac4:	5d                   	pop    %bp
   edac5:	5f                   	pop    %di
   edac6:	5e                   	pop    %si
   edac7:	5a                   	pop    %dx
   edac8:	59                   	pop    %cx
   edac9:	5b                   	pop    %bx
   edaca:	58                   	pop    %ax
   edacb:	9d                   	popf
   edacc:	cb                   	lret
   edacd:	b8 03 80             	mov    $0x8003,%ax
   edad0:	8a 1e 06 01          	mov    0x106,%bl
   edad4:	f6 c3 02             	test   $0x2,%bl
   edad7:	75 02                	jne    0xedadb
   edad9:	eb b2                	jmp    0xeda8d
   edadb:	eb ad                	jmp    0xeda8a
   edadd:	33 c0                	xor    %ax,%ax
   edadf:	c6 06 f8 00 01       	movb   $0x1,0xf8
   edae4:	e8 3a 15             	call   0xef021
   edae7:	3c 00                	cmp    $0x0,%al
   edae9:	74 03                	je     0xedaee
   edaeb:	b0 ff                	mov    $0xff,%al
   edaed:	c3                   	ret
   edaee:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   edaf3:	e8 e7 2d             	call   0xe08dd
   edaf6:	8b 16 61 00          	mov    0x61,%dx
   edafa:	b0 dc                	mov    $0xdc,%al
   edafc:	ee                   	out    %al,(%dx)
   edafd:	eb 00                	jmp    0xedaff
   edaff:	e8 4a 2e             	call   0xe094c
   edb02:	3c ff                	cmp    $0xff,%al
   edb04:	75 0a                	jne    0xedb10
   edb06:	fe 0e c8 03          	decb   0x3c8
   edb0a:	75 e7                	jne    0xedaf3
   edb0c:	e8 d4 01             	call   0xedce3
   edb0f:	c3                   	ret
   edb10:	88 1e 06 01          	mov    %bl,0x106
   edb14:	f6 c3 01             	test   $0x1,%bl
   edb17:	74 03                	je     0xedb1c
   edb19:	b0 04                	mov    $0x4,%al
   edb1b:	c3                   	ret
   edb1c:	e8 2d 2e             	call   0xe094c
   edb1f:	3c ff                	cmp    $0xff,%al
   edb21:	75 0a                	jne    0xedb2d
   edb23:	fe 0e c8 03          	decb   0x3c8
   edb27:	75 ca                	jne    0xedaf3
   edb29:	e8 b7 01             	call   0xedce3
   edb2c:	c3                   	ret
   edb2d:	88 1e be 03          	mov    %bl,0x3be
   edb31:	e8 18 2e             	call   0xe094c
   edb34:	3c ff                	cmp    $0xff,%al
   edb36:	75 0a                	jne    0xedb42
   edb38:	fe 0e c8 03          	decb   0x3c8
   edb3c:	75 b5                	jne    0xedaf3
   edb3e:	e8 a2 01             	call   0xedce3
   edb41:	c3                   	ret
   edb42:	88 1e bf 03          	mov    %bl,0x3bf
   edb46:	a0 06 01             	mov    0x106,%al
   edb49:	a8 40                	test   $0x40,%al
   edb4b:	75 0a                	jne    0xedb57
   edb4d:	a8 80                	test   $0x80,%al
   edb4f:	75 03                	jne    0xedb54
   edb51:	b0 02                	mov    $0x2,%al
   edb53:	c3                   	ret
   edb54:	b0 03                	mov    $0x3,%al
   edb56:	c3                   	ret
   edb57:	a8 20                	test   $0x20,%al
   edb59:	74 0f                	je     0xedb6a
   edb5b:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   edb60:	c6 06 01 05 01       	movb   $0x1,0x501
   edb65:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   edb6a:	a8 02                	test   $0x2,%al
   edb6c:	74 03                	je     0xedb71
   edb6e:	b0 01                	mov    $0x1,%al
   edb70:	c3                   	ret
   edb71:	33 c0                	xor    %ax,%ax
   edb73:	c3                   	ret
   edb74:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edb79:	e8 85 1a             	call   0xef601
   edb7c:	3c 01                	cmp    $0x1,%al
   edb7e:	74 06                	je     0xedb86
   edb80:	b8 03 80             	mov    $0x8003,%ax
   edb83:	e9 07 ff             	jmp    0xeda8d
   edb86:	b8 03 80             	mov    $0x8003,%ax
   edb89:	e9 fe fe             	jmp    0xeda8a
   edb8c:	e8 01 23             	call   0xefe90
   edb8f:	3c 01                	cmp    $0x1,%al
   edb91:	74 02                	je     0xedb95
   edb93:	eb 07                	jmp    0xedb9c
   edb95:	e8 69 1a             	call   0xef601
   edb98:	3c 01                	cmp    $0x1,%al
   edb9a:	74 05                	je     0xedba1
   edb9c:	33 c0                	xor    %ax,%ax
   edb9e:	e9 ec fe             	jmp    0xeda8d
   edba1:	33 c0                	xor    %ax,%ax
   edba3:	e9 e4 fe             	jmp    0xeda8a
   edba6:	e8 e7 22             	call   0xefe90
   edba9:	3c 01                	cmp    $0x1,%al
   edbab:	74 02                	je     0xedbaf
   edbad:	eb 1d                	jmp    0xedbcc
   edbaf:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edbb4:	c6 06 f8 00 00       	movb   $0x0,0xf8
   edbb9:	c7 06 ed 00 00 00    	movw   $0x0,0xed
   edbbf:	c7 06 ef 00 00 00    	movw   $0x0,0xef
   edbc5:	e8 39 1a             	call   0xef601
   edbc8:	3c 01                	cmp    $0x1,%al
   edbca:	74 02                	je     0xedbce
   edbcc:	eb ce                	jmp    0xedb9c
   edbce:	eb d1                	jmp    0xedba1
   edbd0:	be 59 05             	mov    $0x559,%si
   edbd3:	b1 06                	mov    $0x6,%cl
   edbd5:	26 c4 7f 0e          	les    %es:0xe(%bx),%di
   edbd9:	32 e4                	xor    %ah,%ah
   edbdb:	26 8a 05             	mov    %es:(%di),%al
   edbde:	47                   	inc    %di
   edbdf:	3a c1                	cmp    %cl,%al
   edbe1:	76 0d                	jbe    0xedbf0
   edbe3:	3c fe                	cmp    $0xfe,%al
   edbe5:	75 03                	jne    0xedbea
   edbe7:	e9 55 03             	jmp    0xedf3f
   edbea:	b8 03 80             	mov    $0x8003,%ax
   edbed:	e9 9d fe             	jmp    0xeda8d
   edbf0:	d1 e0                	shl    $1,%ax
   edbf2:	03 f0                	add    %ax,%si
   edbf4:	ff 24                	jmp    *(%si)
   edbf6:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edbfb:	33 c0                	xor    %ax,%ax
   edbfd:	e8 dd fe             	call   0xedadd
   edc00:	3c ff                	cmp    $0xff,%al
   edc02:	75 03                	jne    0xedc07
   edc04:	e9 16 05             	jmp    0xee11d
   edc07:	3c 04                	cmp    $0x4,%al
   edc09:	75 03                	jne    0xedc0e
   edc0b:	e9 bf fe             	jmp    0xedacd
   edc0e:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   edc13:	8b 16 61 00          	mov    0x61,%dx
   edc17:	b0 f6                	mov    $0xf6,%al
   edc19:	ee                   	out    %al,(%dx)
   edc1a:	eb 00                	jmp    0xedc1c
   edc1c:	e8 e2 19             	call   0xef601
   edc1f:	3c ff                	cmp    $0xff,%al
   edc21:	75 0c                	jne    0xedc2f
   edc23:	fe 0e c8 03          	decb   0x3c8
   edc27:	75 ea                	jne    0xedc13
   edc29:	e8 b7 00             	call   0xedce3
   edc2c:	e9 ee 04             	jmp    0xee11d
   edc2f:	88 1e 06 01          	mov    %bl,0x106
   edc33:	f6 c3 01             	test   $0x1,%bl
   edc36:	74 03                	je     0xedc3b
   edc38:	e9 92 fe             	jmp    0xedacd
   edc3b:	e9 5e ff             	jmp    0xedb9c
   edc3e:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edc43:	33 c0                	xor    %ax,%ax
   edc45:	e8 95 fe             	call   0xedadd
   edc48:	3c ff                	cmp    $0xff,%al
   edc4a:	75 03                	jne    0xedc4f
   edc4c:	e9 ce 04             	jmp    0xee11d
   edc4f:	3c 04                	cmp    $0x4,%al
   edc51:	75 03                	jne    0xedc56
   edc53:	e9 77 fe             	jmp    0xedacd
   edc56:	26 8a 05             	mov    %es:(%di),%al
   edc59:	a2 bd 03             	mov    %al,0x3bd
   edc5c:	3c 01                	cmp    $0x1,%al
   edc5e:	74 0c                	je     0xedc6c
   edc60:	3c 00                	cmp    $0x0,%al
   edc62:	74 08                	je     0xedc6c
   edc64:	c6 06 bd 03 00       	movb   $0x0,0x3bd
   edc69:	e9 61 fe             	jmp    0xedacd
   edc6c:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   edc71:	e8 3d 00             	call   0xedcb1
   edc74:	3c ff                	cmp    $0xff,%al
   edc76:	75 0c                	jne    0xedc84
   edc78:	fe 0e c8 03          	decb   0x3c8
   edc7c:	75 f3                	jne    0xedc71
   edc7e:	e8 62 00             	call   0xedce3
   edc81:	e9 99 04             	jmp    0xee11d
   edc84:	88 1e 06 01          	mov    %bl,0x106
   edc88:	f6 c3 01             	test   $0x1,%bl
   edc8b:	74 03                	je     0xedc90
   edc8d:	e9 3d fe             	jmp    0xedacd
   edc90:	f6 c3 20             	test   $0x20,%bl
   edc93:	74 0f                	je     0xedca4
   edc95:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   edc9a:	c6 06 01 05 01       	movb   $0x1,0x501
   edc9f:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   edca4:	33 c0                	xor    %ax,%ax
   edca6:	f6 c3 02             	test   $0x2,%bl
   edca9:	74 03                	je     0xedcae
   edcab:	e9 dc fd             	jmp    0xeda8a
   edcae:	e9 dc fd             	jmp    0xeda8d
   edcb1:	8b 16 61 00          	mov    0x61,%dx
   edcb5:	b0 fe                	mov    $0xfe,%al
   edcb7:	9c                   	pushf
   edcb8:	fa                   	cli
   edcb9:	ee                   	out    %al,(%dx)
   edcba:	a0 bd 03             	mov    0x3bd,%al
   edcbd:	ee                   	out    %al,(%dx)
   edcbe:	9d                   	popf
   edcbf:	e8 8a 2c             	call   0xe094c
   edcc2:	c3                   	ret
   edcc3:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edcc8:	32 c0                	xor    %al,%al
   edcca:	a2 bd 03             	mov    %al,0x3bd
   edccd:	c6 06 b5 03 01       	movb   $0x1,0x3b5
   edcd2:	a2 b6 03             	mov    %al,0x3b6
   edcd5:	c6 06 b7 03 01       	movb   $0x1,0x3b7
   edcda:	a2 b8 03             	mov    %al,0x3b8
   edcdd:	e8 03 00             	call   0xedce3
   edce0:	e9 b9 fe             	jmp    0xedb9c
   edce3:	50                   	push   %ax
   edce4:	33 c0                	xor    %ax,%ax
   edce6:	8b 16 65 00          	mov    0x65,%dx
   edcea:	ee                   	out    %al,(%dx)
   edceb:	eb 00                	jmp    0xedced
   edced:	51                   	push   %cx
   edcee:	b9 02 00             	mov    $0x2,%cx
   edcf1:	8b 16 61 00          	mov    0x61,%dx
   edcf5:	b0 40                	mov    $0x40,%al
   edcf7:	ee                   	out    %al,(%dx)
   edcf8:	eb 00                	jmp    0xedcfa
   edcfa:	e8 4f 2c             	call   0xe094c
   edcfd:	3c ff                	cmp    $0xff,%al
   edcff:	75 03                	jne    0xedd04
   edd01:	49                   	dec    %cx
   edd02:	75 ed                	jne    0xedcf1
   edd04:	59                   	pop    %cx
   edd05:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   edd0a:	c6 06 01 05 01       	movb   $0x1,0x501
   edd0f:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   edd14:	e8 9a ff             	call   0xedcb1
   edd17:	e8 9d 01             	call   0xedeb7
   edd1a:	e8 c8 20             	call   0xefde5
   edd1d:	e8 48 02             	call   0xedf68
   edd20:	58                   	pop    %ax
   edd21:	c3                   	ret
   edd22:	c6 06 b5 03 00       	movb   $0x0,0x3b5
   edd27:	c6 06 b6 03 00       	movb   $0x0,0x3b6
   edd2c:	c6 06 b7 03 00       	movb   $0x0,0x3b7
   edd31:	c6 06 b8 03 00       	movb   $0x0,0x3b8
   edd36:	c6 06 c6 03 00       	movb   $0x0,0x3c6
   edd3b:	c6 06 c7 03 00       	movb   $0x0,0x3c7
   edd40:	e8 9a fd             	call   0xedadd
   edd43:	3c ff                	cmp    $0xff,%al
   edd45:	75 03                	jne    0xedd4a
   edd47:	e9 d3 03             	jmp    0xee11d
   edd4a:	3c 04                	cmp    $0x4,%al
   edd4c:	75 03                	jne    0xedd51
   edd4e:	e9 7c fd             	jmp    0xedacd
   edd51:	26 8a 05             	mov    %es:(%di),%al
   edd54:	3c 00                	cmp    $0x0,%al
   edd56:	75 09                	jne    0xedd61
   edd58:	47                   	inc    %di
   edd59:	26 8a 05             	mov    %es:(%di),%al
   edd5c:	a2 b5 03             	mov    %al,0x3b5
   edd5f:	eb 1e                	jmp    0xedd7f
   edd61:	3c 01                	cmp    $0x1,%al
   edd63:	75 09                	jne    0xedd6e
   edd65:	47                   	inc    %di
   edd66:	26 8a 05             	mov    %es:(%di),%al
   edd69:	a2 b8 03             	mov    %al,0x3b8
   edd6c:	eb 11                	jmp    0xedd7f
   edd6e:	3c 02                	cmp    $0x2,%al
   edd70:	75 03                	jne    0xedd75
   edd72:	e9 22 01             	jmp    0xede97
   edd75:	3c 03                	cmp    $0x3,%al
   edd77:	75 03                	jne    0xedd7c
   edd79:	e9 1b 01             	jmp    0xede97
   edd7c:	e9 98 03             	jmp    0xee117
   edd7f:	47                   	inc    %di
   edd80:	26 8a 05             	mov    %es:(%di),%al
   edd83:	3c 00                	cmp    $0x0,%al
   edd85:	75 09                	jne    0xedd90
   edd87:	47                   	inc    %di
   edd88:	26 8a 05             	mov    %es:(%di),%al
   edd8b:	a2 b6 03             	mov    %al,0x3b6
   edd8e:	eb 1e                	jmp    0xeddae
   edd90:	3c 01                	cmp    $0x1,%al
   edd92:	75 09                	jne    0xedd9d
   edd94:	47                   	inc    %di
   edd95:	26 8a 05             	mov    %es:(%di),%al
   edd98:	a2 b7 03             	mov    %al,0x3b7
   edd9b:	eb 11                	jmp    0xeddae
   edd9d:	3c 02                	cmp    $0x2,%al
   edd9f:	75 03                	jne    0xedda4
   edda1:	e9 f3 00             	jmp    0xede97
   edda4:	3c 03                	cmp    $0x3,%al
   edda6:	75 03                	jne    0xeddab
   edda8:	e9 ec 00             	jmp    0xede97
   eddab:	e9 69 03             	jmp    0xee117
   eddae:	80 3e f3 04 00       	cmpb   $0x0,0x4f3
   eddb3:	74 56                	je     0xede0b
   eddb5:	80 3e b5 03 00       	cmpb   $0x0,0x3b5
   eddba:	74 16                	je     0xeddd2
   eddbc:	80 3e b7 03 00       	cmpb   $0x0,0x3b7
   eddc1:	75 48                	jne    0xede0b
   eddc3:	80 3e b6 03 00       	cmpb   $0x0,0x3b6
   eddc8:	75 41                	jne    0xede0b
   eddca:	a0 b5 03             	mov    0x3b5,%al
   eddcd:	a2 b6 03             	mov    %al,0x3b6
   eddd0:	eb 39                	jmp    0xede0b
   eddd2:	80 3e b8 03 00       	cmpb   $0x0,0x3b8
   eddd7:	74 16                	je     0xeddef
   eddd9:	80 3e b7 03 00       	cmpb   $0x0,0x3b7
   eddde:	75 2b                	jne    0xede0b
   edde0:	80 3e b6 03 00       	cmpb   $0x0,0x3b6
   edde5:	75 24                	jne    0xede0b
   edde7:	a0 b8 03             	mov    0x3b8,%al
   eddea:	a2 b7 03             	mov    %al,0x3b7
   edded:	eb 1c                	jmp    0xede0b
   eddef:	80 3e b6 03 00       	cmpb   $0x0,0x3b6
   eddf4:	74 08                	je     0xeddfe
   eddf6:	a0 b6 03             	mov    0x3b6,%al
   eddf9:	a2 b5 03             	mov    %al,0x3b5
   eddfc:	eb 0d                	jmp    0xede0b
   eddfe:	80 3e b7 03 00       	cmpb   $0x0,0x3b7
   ede03:	74 06                	je     0xede0b
   ede05:	a0 b7 03             	mov    0x3b7,%al
   ede08:	a2 b8 03             	mov    %al,0x3b8
   ede0b:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ede10:	e8 ca 2a             	call   0xe08dd
   ede13:	e8 a1 00             	call   0xedeb7
   ede16:	3c ff                	cmp    $0xff,%al
   ede18:	75 0c                	jne    0xede26
   ede1a:	fe 0e c8 03          	decb   0x3c8
   ede1e:	75 f0                	jne    0xede10
   ede20:	e8 c0 fe             	call   0xedce3
   ede23:	e9 f7 02             	jmp    0xee11d
   ede26:	f6 c3 01             	test   $0x1,%bl
   ede29:	74 03                	je     0xede2e
   ede2b:	e9 ba 06             	jmp    0xee4e8
   ede2e:	88 1e 06 01          	mov    %bl,0x106
   ede32:	c6 06 af 03 01       	movb   $0x1,0x3af
   ede37:	e8 12 2b             	call   0xe094c
   ede3a:	3c ff                	cmp    $0xff,%al
   ede3c:	75 0c                	jne    0xede4a
   ede3e:	fe 0e c8 03          	decb   0x3c8
   ede42:	75 cc                	jne    0xede10
   ede44:	e8 9c fe             	call   0xedce3
   ede47:	e9 d3 02             	jmp    0xee11d
   ede4a:	88 1e b9 03          	mov    %bl,0x3b9
   ede4e:	e8 fb 2a             	call   0xe094c
   ede51:	3c ff                	cmp    $0xff,%al
   ede53:	75 0c                	jne    0xede61
   ede55:	fe 0e c8 03          	decb   0x3c8
   ede59:	75 b5                	jne    0xede10
   ede5b:	e8 85 fe             	call   0xedce3
   ede5e:	e9 bc 02             	jmp    0xee11d
   ede61:	88 1e ba 03          	mov    %bl,0x3ba
   ede65:	e8 e4 2a             	call   0xe094c
   ede68:	3c ff                	cmp    $0xff,%al
   ede6a:	75 0e                	jne    0xede7a
   ede6c:	fe 0e c8 03          	decb   0x3c8
   ede70:	74 02                	je     0xede74
   ede72:	eb 9c                	jmp    0xede10
   ede74:	e8 6c fe             	call   0xedce3
   ede77:	e9 a3 02             	jmp    0xee11d
   ede7a:	88 1e bb 03          	mov    %bl,0x3bb
   ede7e:	e8 cb 2a             	call   0xe094c
   ede81:	3c ff                	cmp    $0xff,%al
   ede83:	75 0e                	jne    0xede93
   ede85:	fe 0e c8 03          	decb   0x3c8
   ede89:	74 02                	je     0xede8d
   ede8b:	eb 83                	jmp    0xede10
   ede8d:	e8 53 fe             	call   0xedce3
   ede90:	e9 8a 02             	jmp    0xee11d
   ede93:	88 1e bc 03          	mov    %bl,0x3bc
   ede97:	a0 06 01             	mov    0x106,%al
   ede9a:	a8 20                	test   $0x20,%al
   ede9c:	74 0f                	je     0xedead
   ede9e:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   edea3:	c6 06 01 05 01       	movb   $0x1,0x501
   edea8:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   edead:	a8 02                	test   $0x2,%al
   edeaf:	74 03                	je     0xedeb4
   edeb1:	e9 ed fc             	jmp    0xedba1
   edeb4:	e9 e5 fc             	jmp    0xedb9c
   edeb7:	8b 16 61 00          	mov    0x61,%dx
   edebb:	b0 ae                	mov    $0xae,%al
   edebd:	9c                   	pushf
   edebe:	fa                   	cli
   edebf:	ee                   	out    %al,(%dx)
   edec0:	a0 b5 03             	mov    0x3b5,%al
   edec3:	ee                   	out    %al,(%dx)
   edec4:	eb 00                	jmp    0xedec6
   edec6:	a0 b6 03             	mov    0x3b6,%al
   edec9:	ee                   	out    %al,(%dx)
   edeca:	eb 00                	jmp    0xedecc
   edecc:	a0 b7 03             	mov    0x3b7,%al
   edecf:	ee                   	out    %al,(%dx)
   eded0:	eb 00                	jmp    0xeded2
   eded2:	a0 b8 03             	mov    0x3b8,%al
   eded5:	ee                   	out    %al,(%dx)
   eded6:	9d                   	popf
   eded7:	e8 72 2a             	call   0xe094c
   ededa:	c3                   	ret
   ededb:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   edee0:	33 c0                	xor    %ax,%ax
   edee2:	e8 f8 fb             	call   0xedadd
   edee5:	3c ff                	cmp    $0xff,%al
   edee7:	75 03                	jne    0xedeec
   edee9:	e9 31 02             	jmp    0xee11d
   edeec:	3c 04                	cmp    $0x4,%al
   edeee:	75 03                	jne    0xedef3
   edef0:	e9 da fb             	jmp    0xedacd
   edef3:	c6 06 c8 03 06       	movb   $0x6,0x3c8
   edef8:	8b 16 61 00          	mov    0x61,%dx
   edefc:	b0 f8                	mov    $0xf8,%al
   edefe:	ee                   	out    %al,(%dx)
   edeff:	eb 00                	jmp    0xedf01
   edf01:	e8 fd 16             	call   0xef601
   edf04:	3c ff                	cmp    $0xff,%al
   edf06:	75 0c                	jne    0xedf14
   edf08:	fe 0e c8 03          	decb   0x3c8
   edf0c:	75 ea                	jne    0xedef8
   edf0e:	e8 d2 fd             	call   0xedce3
   edf11:	e9 09 02             	jmp    0xee11d
   edf14:	88 1e 06 01          	mov    %bl,0x106
   edf18:	f6 c3 01             	test   $0x1,%bl
   edf1b:	74 03                	je     0xedf20
   edf1d:	e9 ad fb             	jmp    0xedacd
   edf20:	f6 c3 20             	test   $0x20,%bl
   edf23:	74 0f                	je     0xedf34
   edf25:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   edf2a:	c6 06 01 05 01       	movb   $0x1,0x501
   edf2f:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   edf34:	f6 c3 02             	test   $0x2,%bl
   edf37:	74 03                	je     0xedf3c
   edf39:	e9 4e fb             	jmp    0xeda8a
   edf3c:	e9 4e fb             	jmp    0xeda8d
   edf3f:	06                   	push   %es
   edf40:	57                   	push   %di
   edf41:	c4 1e 0e 05          	les    0x50e,%bx
   edf45:	8c c0                	mov    %es,%ax
   edf47:	0b d8                	or     %ax,%bx
   edf49:	75 16                	jne    0xedf61
   edf4b:	5f                   	pop    %di
   edf4c:	07                   	pop    %es
   edf4d:	06                   	push   %es
   edf4e:	57                   	push   %di
   edf4f:	26 c4 1d             	les    %es:(%di),%bx
   edf52:	b8 0e 05             	mov    $0x50e,%ax
   edf55:	8b f8                	mov    %ax,%di
   edf57:	89 1d                	mov    %bx,(%di)
   edf59:	8c c0                	mov    %es,%ax
   edf5b:	89 45 02             	mov    %ax,0x2(%di)
   edf5e:	e8 07 00             	call   0xedf68
   edf61:	5f                   	pop    %di
   edf62:	07                   	pop    %es
   edf63:	33 c0                	xor    %ax,%ax
   edf65:	e9 25 fb             	jmp    0xeda8d
   edf68:	53                   	push   %bx
   edf69:	51                   	push   %cx
   edf6a:	52                   	push   %dx
   edf6b:	56                   	push   %si
   edf6c:	57                   	push   %di
   edf6d:	55                   	push   %bp
   edf6e:	1e                   	push   %ds
   edf6f:	06                   	push   %es
   edf70:	e8 6a 29             	call   0xe08dd
   edf73:	8b 16 61 00          	mov    0x61,%dx
   edf77:	b0 90                	mov    $0x90,%al
   edf79:	9c                   	pushf
   edf7a:	fa                   	cli
   edf7b:	ee                   	out    %al,(%dx)
   edf7c:	b0 10                	mov    $0x10,%al
   edf7e:	ee                   	out    %al,(%dx)
   edf7f:	eb 00                	jmp    0xedf81
   edf81:	b0 0e                	mov    $0xe,%al
   edf83:	ee                   	out    %al,(%dx)
   edf84:	9d                   	popf
   edf85:	e8 c4 29             	call   0xe094c
   edf88:	07                   	pop    %es
   edf89:	1f                   	pop    %ds
   edf8a:	5d                   	pop    %bp
   edf8b:	5f                   	pop    %di
   edf8c:	5e                   	pop    %si
   edf8d:	5a                   	pop    %dx
   edf8e:	59                   	pop    %cx
   edf8f:	5b                   	pop    %bx
   edf90:	c3                   	ret
   edf91:	89 1e db 00          	mov    %bx,0xdb
   edf95:	a3 d9 00             	mov    %ax,0xd9
   edf98:	8a f4                	mov    %ah,%dh
   edf9a:	80 e6 f0             	and    $0xf0,%dh
   edf9d:	d1 e0                	shl    $1,%ax
   edf9f:	d1 e0                	shl    $1,%ax
   edfa1:	d1 e0                	shl    $1,%ax
   edfa3:	d1 e0                	shl    $1,%ax
   edfa5:	03 d8                	add    %ax,%bx
   edfa7:	89 1e d7 00          	mov    %bx,0xd7
   edfab:	72 02                	jb     0xedfaf
   edfad:	eb 03                	jmp    0xedfb2
   edfaf:	80 c6 10             	add    $0x10,%dh
   edfb2:	8a e6                	mov    %dh,%ah
   edfb4:	b0 00                	mov    $0x0,%al
   edfb6:	a3 d5 00             	mov    %ax,0xd5
   edfb9:	8b 1e d7 00          	mov    0xd7,%bx
   edfbd:	8b 16 d5 00          	mov    0xd5,%dx
   edfc1:	03 1e 03 01          	add    0x103,%bx
   edfc5:	72 02                	jb     0xedfc9
   edfc7:	eb 05                	jmp    0xedfce
   edfc9:	80 c6 10             	add    $0x10,%dh
   edfcc:	eb 04                	jmp    0xedfd2
   edfce:	8b 1e d7 00          	mov    0xd7,%bx
   edfd2:	81 3e 03 01 30 09    	cmpw   $0x930,0x103
   edfd8:	75 0c                	jne    0xedfe6
   edfda:	3e 89 9e 87 01       	mov    %bx,%ds:0x187(%bp)
   edfdf:	3e 89 96 c7 01       	mov    %dx,%ds:0x1c7(%bp)
   edfe4:	eb 0a                	jmp    0xedff0
   edfe6:	3e 89 9e 07 01       	mov    %bx,%ds:0x107(%bp)
   edfeb:	3e 89 96 47 01       	mov    %dx,%ds:0x147(%bp)
   edff0:	49                   	dec    %cx
   edff1:	03 1e 03 01          	add    0x103,%bx
   edff5:	8b c3                	mov    %bx,%ax
   edff7:	03 1e 03 01          	add    0x103,%bx
   edffb:	45                   	inc    %bp
   edffc:	45                   	inc    %bp
   edffd:	72 02                	jb     0xee001
   edfff:	eb 05                	jmp    0xee006
   ee001:	80 c6 10             	add    $0x10,%dh
   ee004:	eb 02                	jmp    0xee008
   ee006:	8b d8                	mov    %ax,%bx
   ee008:	81 3e 03 01 30 09    	cmpw   $0x930,0x103
   ee00e:	75 0c                	jne    0xee01c
   ee010:	3e 89 9e 87 01       	mov    %bx,%ds:0x187(%bp)
   ee015:	3e 89 96 c7 01       	mov    %dx,%ds:0x1c7(%bp)
   ee01a:	eb 0a                	jmp    0xee026
   ee01c:	3e 89 9e 07 01       	mov    %bx,%ds:0x107(%bp)
   ee021:	3e 89 96 47 01       	mov    %dx,%ds:0x147(%bp)
   ee026:	e2 c9                	loop   0xedff1
   ee028:	c3                   	ret
   ee029:	e9 48 fb             	jmp    0xedb74
   ee02c:	c6 06 01 05 00       	movb   $0x0,0x501
   ee031:	e9 40 fb             	jmp    0xedb74
   ee034:	be 67 05             	mov    $0x567,%si
   ee037:	b1 0f                	mov    $0xf,%cl
   ee039:	26 c4 7f 0e          	les    %es:0xe(%bx),%di
   ee03d:	32 e4                	xor    %ah,%ah
   ee03f:	26 8a 05             	mov    %es:(%di),%al
   ee042:	32 e4                	xor    %ah,%ah
   ee044:	47                   	inc    %di
   ee045:	3a c1                	cmp    %cl,%al
   ee047:	76 06                	jbe    0xee04f
   ee049:	b8 03 80             	mov    $0x8003,%ax
   ee04c:	e9 3e fa             	jmp    0xeda8d
   ee04f:	d1 e0                	shl    $1,%ax
   ee051:	03 f0                	add    %ax,%si
   ee053:	ff 24                	jmp    *(%si)
   ee055:	b8 00 00             	mov    $0x0,%ax
   ee058:	26 89 05             	mov    %ax,%es:(%di)
   ee05b:	8c c8                	mov    %cs,%ax
   ee05d:	26 89 45 02          	mov    %ax,%es:0x2(%di)
   ee061:	e8 2c 1e             	call   0xefe90
   ee064:	3c 01                	cmp    $0x1,%al
   ee066:	74 02                	je     0xee06a
   ee068:	eb 07                	jmp    0xee071
   ee06a:	e8 94 15             	call   0xef601
   ee06d:	3c 01                	cmp    $0x1,%al
   ee06f:	74 03                	je     0xee074
   ee071:	e9 28 fb             	jmp    0xedb9c
   ee074:	e9 2a fb             	jmp    0xedba1
   ee077:	e8 16 1e             	call   0xefe90
   ee07a:	3c 01                	cmp    $0x1,%al
   ee07c:	74 03                	je     0xee081
   ee07e:	e9 6f 24             	jmp    0xe04f0
   ee081:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   ee086:	c6 06 f9 00 01       	movb   $0x1,0xf9
   ee08b:	e8 93 0f             	call   0xef021
   ee08e:	3c 00                	cmp    $0x0,%al
   ee090:	74 03                	je     0xee095
   ee092:	e9 88 00             	jmp    0xee11d
   ee095:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ee09a:	e8 cf 26             	call   0xe076c
   ee09d:	3c ff                	cmp    $0xff,%al
   ee09f:	75 13                	jne    0xee0b4
   ee0a1:	fe 0e c8 03          	decb   0x3c8
   ee0a5:	75 f3                	jne    0xee09a
   ee0a7:	e8 39 fc             	call   0xedce3
   ee0aa:	b0 00                	mov    $0x0,%al
   ee0ac:	a2 fe 00             	mov    %al,0xfe
   ee0af:	a2 ff 00             	mov    %al,0xff
   ee0b2:	eb 69                	jmp    0xee11d
   ee0b4:	3c 01                	cmp    $0x1,%al
   ee0b6:	74 59                	je     0xee111
   ee0b8:	a0 06 01             	mov    0x106,%al
   ee0bb:	a8 40                	test   $0x40,%al
   ee0bd:	75 02                	jne    0xee0c1
   ee0bf:	eb 5c                	jmp    0xee11d
   ee0c1:	26 80 3d 00          	cmpb   $0x0,%es:(%di)
   ee0c5:	74 5c                	je     0xee123
   ee0c7:	26 80 3d 01          	cmpb   $0x1,%es:(%di)
   ee0cb:	75 4a                	jne    0xee117
   ee0cd:	47                   	inc    %di
   ee0ce:	a0 a0 00             	mov    0xa0,%al
   ee0d1:	e8 ff 28             	call   0xe09d3
   ee0d4:	26 88 05             	mov    %al,%es:(%di)
   ee0d7:	47                   	inc    %di
   ee0d8:	a0 9f 00             	mov    0x9f,%al
   ee0db:	e8 f5 28             	call   0xe09d3
   ee0de:	26 88 05             	mov    %al,%es:(%di)
   ee0e1:	47                   	inc    %di
   ee0e2:	a0 9e 00             	mov    0x9e,%al
   ee0e5:	e8 eb 28             	call   0xe09d3
   ee0e8:	26 88 05             	mov    %al,%es:(%di)
   ee0eb:	47                   	inc    %di
   ee0ec:	32 c0                	xor    %al,%al
   ee0ee:	26 88 05             	mov    %al,%es:(%di)
   ee0f1:	a0 06 01             	mov    0x106,%al
   ee0f4:	a8 20                	test   $0x20,%al
   ee0f6:	74 0f                	je     0xee107
   ee0f8:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee0fd:	c6 06 01 05 01       	movb   $0x1,0x501
   ee102:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee107:	a8 02                	test   $0x2,%al
   ee109:	75 03                	jne    0xee10e
   ee10b:	e9 8e fa             	jmp    0xedb9c
   ee10e:	e9 90 fa             	jmp    0xedba1
   ee111:	b8 0b 80             	mov    $0x800b,%ax
   ee114:	e9 76 f9             	jmp    0xeda8d
   ee117:	b8 03 80             	mov    $0x8003,%ax
   ee11a:	e9 70 f9             	jmp    0xeda8d
   ee11d:	b8 02 80             	mov    $0x8002,%ax
   ee120:	e9 6a f9             	jmp    0xeda8d
   ee123:	a0 9e 00             	mov    0x9e,%al
   ee126:	e8 aa 28             	call   0xe09d3
   ee129:	8a d0                	mov    %al,%dl
   ee12b:	a0 9f 00             	mov    0x9f,%al
   ee12e:	e8 a2 28             	call   0xe09d3
   ee131:	8a f0                	mov    %al,%dh
   ee133:	a0 a0 00             	mov    0xa0,%al
   ee136:	e8 9a 28             	call   0xe09d3
   ee139:	8a e6                	mov    %dh,%ah
   ee13b:	e8 4d 07             	call   0xee88b
   ee13e:	2d 96 00             	sub    $0x96,%ax
   ee141:	83 da 00             	sbb    $0x0,%dx
   ee144:	a3 8c 00             	mov    %ax,0x8c
   ee147:	89 16 8e 00          	mov    %dx,0x8e
   ee14b:	47                   	inc    %di
   ee14c:	a1 8c 00             	mov    0x8c,%ax
   ee14f:	26 89 05             	mov    %ax,%es:(%di)
   ee152:	47                   	inc    %di
   ee153:	47                   	inc    %di
   ee154:	a1 8e 00             	mov    0x8e,%ax
   ee157:	26 89 05             	mov    %ax,%es:(%di)
   ee15a:	a0 06 01             	mov    0x106,%al
   ee15d:	a8 20                	test   $0x20,%al
   ee15f:	74 0f                	je     0xee170
   ee161:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee166:	c6 06 01 05 01       	movb   $0x1,0x501
   ee16b:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee170:	a8 02                	test   $0x2,%al
   ee172:	75 03                	jne    0xee177
   ee174:	e9 25 fa             	jmp    0xedb9c
   ee177:	e9 27 fa             	jmp    0xedba1
   ee17a:	c6 06 b3 03 00       	movb   $0x0,0x3b3
   ee17f:	c6 06 b4 03 01       	movb   $0x1,0x3b4
   ee184:	c6 06 c4 03 00       	movb   $0x0,0x3c4
   ee189:	c6 06 c5 03 00       	movb   $0x0,0x3c5
   ee18e:	33 c0                	xor    %ax,%ax
   ee190:	e8 4a f9             	call   0xedadd
   ee193:	3c ff                	cmp    $0xff,%al
   ee195:	75 02                	jne    0xee199
   ee197:	eb 84                	jmp    0xee11d
   ee199:	3c 04                	cmp    $0x4,%al
   ee19b:	75 03                	jne    0xee1a0
   ee19d:	e9 2d f9             	jmp    0xedacd
   ee1a0:	e8 3a 27             	call   0xe08dd
   ee1a3:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ee1a8:	8b 16 61 00          	mov    0x61,%dx
   ee1ac:	b0 8e                	mov    $0x8e,%al
   ee1ae:	ee                   	out    %al,(%dx)
   ee1af:	eb 00                	jmp    0xee1b1
   ee1b1:	e8 98 27             	call   0xe094c
   ee1b4:	3c ff                	cmp    $0xff,%al
   ee1b6:	75 0c                	jne    0xee1c4
   ee1b8:	fe 0e c8 03          	decb   0x3c8
   ee1bc:	75 ea                	jne    0xee1a8
   ee1be:	e8 22 fb             	call   0xedce3
   ee1c1:	e9 59 ff             	jmp    0xee11d
   ee1c4:	f6 c3 01             	test   $0x1,%bl
   ee1c7:	74 03                	je     0xee1cc
   ee1c9:	e9 1c 03             	jmp    0xee4e8
   ee1cc:	88 1e 06 01          	mov    %bl,0x106
   ee1d0:	c6 06 af 03 01       	movb   $0x1,0x3af
   ee1d5:	e8 74 27             	call   0xe094c
   ee1d8:	3c ff                	cmp    $0xff,%al
   ee1da:	75 0c                	jne    0xee1e8
   ee1dc:	fe 0e c8 03          	decb   0x3c8
   ee1e0:	75 c6                	jne    0xee1a8
   ee1e2:	e8 fe fa             	call   0xedce3
   ee1e5:	e9 35 ff             	jmp    0xee11d
   ee1e8:	80 fb 00             	cmp    $0x0,%bl
   ee1eb:	74 09                	je     0xee1f6
   ee1ed:	88 1e c4 03          	mov    %bl,0x3c4
   ee1f1:	c6 06 b3 03 00       	movb   $0x0,0x3b3
   ee1f6:	e8 53 27             	call   0xe094c
   ee1f9:	3c ff                	cmp    $0xff,%al
   ee1fb:	75 0c                	jne    0xee209
   ee1fd:	fe 0e c8 03          	decb   0x3c8
   ee201:	75 a5                	jne    0xee1a8
   ee203:	e8 dd fa             	call   0xedce3
   ee206:	e9 14 ff             	jmp    0xee11d
   ee209:	80 fb 00             	cmp    $0x0,%bl
   ee20c:	74 09                	je     0xee217
   ee20e:	88 1e c5 03          	mov    %bl,0x3c5
   ee212:	c6 06 b4 03 00       	movb   $0x0,0x3b4
   ee217:	e8 32 27             	call   0xe094c
   ee21a:	3c ff                	cmp    $0xff,%al
   ee21c:	75 0e                	jne    0xee22c
   ee21e:	fe 0e c8 03          	decb   0x3c8
   ee222:	74 02                	je     0xee226
   ee224:	eb 82                	jmp    0xee1a8
   ee226:	e8 ba fa             	call   0xedce3
   ee229:	e9 f1 fe             	jmp    0xee11d
   ee22c:	80 fb 00             	cmp    $0x0,%bl
   ee22f:	74 09                	je     0xee23a
   ee231:	88 1e c5 03          	mov    %bl,0x3c5
   ee235:	c6 06 b4 03 01       	movb   $0x1,0x3b4
   ee23a:	e8 0f 27             	call   0xe094c
   ee23d:	3c ff                	cmp    $0xff,%al
   ee23f:	75 0f                	jne    0xee250
   ee241:	fe 0e c8 03          	decb   0x3c8
   ee245:	74 03                	je     0xee24a
   ee247:	e9 5e ff             	jmp    0xee1a8
   ee24a:	e8 96 fa             	call   0xedce3
   ee24d:	e9 cd fe             	jmp    0xee11d
   ee250:	80 fb 00             	cmp    $0x0,%bl
   ee253:	74 09                	je     0xee25e
   ee255:	88 1e c4 03          	mov    %bl,0x3c4
   ee259:	c6 06 b3 03 01       	movb   $0x1,0x3b3
   ee25e:	a0 b3 03             	mov    0x3b3,%al
   ee261:	aa                   	stos   %al,%es:(%di)
   ee262:	a0 c4 03             	mov    0x3c4,%al
   ee265:	aa                   	stos   %al,%es:(%di)
   ee266:	a0 b4 03             	mov    0x3b4,%al
   ee269:	aa                   	stos   %al,%es:(%di)
   ee26a:	a0 c5 03             	mov    0x3c5,%al
   ee26d:	aa                   	stos   %al,%es:(%di)
   ee26e:	b0 02                	mov    $0x2,%al
   ee270:	aa                   	stos   %al,%es:(%di)
   ee271:	b0 00                	mov    $0x0,%al
   ee273:	aa                   	stos   %al,%es:(%di)
   ee274:	b0 03                	mov    $0x3,%al
   ee276:	aa                   	stos   %al,%es:(%di)
   ee277:	b0 00                	mov    $0x0,%al
   ee279:	aa                   	stos   %al,%es:(%di)
   ee27a:	a0 06 01             	mov    0x106,%al
   ee27d:	a8 20                	test   $0x20,%al
   ee27f:	74 0f                	je     0xee290
   ee281:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee286:	c6 06 01 05 01       	movb   $0x1,0x501
   ee28b:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee290:	a8 02                	test   $0x2,%al
   ee292:	74 03                	je     0xee297
   ee294:	e9 0a f9             	jmp    0xedba1
   ee297:	e9 02 f9             	jmp    0xedb9c
   ee29a:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   ee29f:	33 c0                	xor    %ax,%ax
   ee2a1:	26 88 05             	mov    %al,%es:(%di)
   ee2a4:	e9 ba fd             	jmp    0xee061
   ee2a7:	e8 e6 1b             	call   0xefe90
   ee2aa:	3c 02                	cmp    $0x2,%al
   ee2ac:	75 08                	jne    0xee2b6
   ee2ae:	b8 b7 1b             	mov    $0x1bb7,%ax
   ee2b1:	32 db                	xor    %bl,%bl
   ee2b3:	e9 a0 00             	jmp    0xee356
   ee2b6:	e8 48 13             	call   0xef601
   ee2b9:	3c ff                	cmp    $0xff,%al
   ee2bb:	75 03                	jne    0xee2c0
   ee2bd:	e9 5d fe             	jmp    0xee11d
   ee2c0:	8a c3                	mov    %bl,%al
   ee2c2:	a8 20                	test   $0x20,%al
   ee2c4:	74 0f                	je     0xee2d5
   ee2c6:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee2cb:	c6 06 01 05 01       	movb   $0x1,0x501
   ee2d0:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee2d5:	a8 40                	test   $0x40,%al
   ee2d7:	75 05                	jne    0xee2de
   ee2d9:	b9 00 08             	mov    $0x800,%cx
   ee2dc:	eb 03                	jmp    0xee2e1
   ee2de:	b9 00 00             	mov    $0x0,%cx
   ee2e1:	51                   	push   %cx
   ee2e2:	e8 f8 f7             	call   0xedadd
   ee2e5:	59                   	pop    %cx
   ee2e6:	3c 04                	cmp    $0x4,%al
   ee2e8:	75 08                	jne    0xee2f2
   ee2ea:	b8 96 12             	mov    $0x1296,%ax
   ee2ed:	0b c8                	or     %ax,%cx
   ee2ef:	eb 60                	jmp    0xee351
   ee2f1:	90                   	nop
   ee2f2:	3c 03                	cmp    $0x3,%al
   ee2f4:	75 05                	jne    0xee2fb
   ee2f6:	b9 00 08             	mov    $0x800,%cx
   ee2f9:	eb 00                	jmp    0xee2fb
   ee2fb:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ee300:	8b 16 61 00          	mov    0x61,%dx
   ee304:	b0 fe                	mov    $0xfe,%al
   ee306:	9c                   	pushf
   ee307:	fa                   	cli
   ee308:	ee                   	out    %al,(%dx)
   ee309:	b0 02                	mov    $0x2,%al
   ee30b:	ee                   	out    %al,(%dx)
   ee30c:	9d                   	popf
   ee30d:	e8 3c 26             	call   0xe094c
   ee310:	3c ff                	cmp    $0xff,%al
   ee312:	75 0b                	jne    0xee31f
   ee314:	fe 0e c8 03          	decb   0x3c8
   ee318:	75 e6                	jne    0xee300
   ee31a:	e8 c6 f9             	call   0xedce3
   ee31d:	eb 32                	jmp    0xee351
   ee31f:	88 1e 06 01          	mov    %bl,0x106
   ee323:	e8 26 26             	call   0xe094c
   ee326:	3c ff                	cmp    $0xff,%al
   ee328:	75 0b                	jne    0xee335
   ee32a:	fe 0e c8 03          	decb   0x3c8
   ee32e:	75 d0                	jne    0xee300
   ee330:	e8 b0 f9             	call   0xedce3
   ee333:	eb 1c                	jmp    0xee351
   ee335:	80 fb 01             	cmp    $0x1,%bl
   ee338:	75 06                	jne    0xee340
   ee33a:	81 c9 20 01          	or     $0x120,%cx
   ee33e:	eb 04                	jmp    0xee344
   ee340:	81 c9 22 01          	or     $0x122,%cx
   ee344:	8a 1e 06 01          	mov    0x106,%bl
   ee348:	f6 c3 80             	test   $0x80,%bl
   ee34b:	74 04                	je     0xee351
   ee34d:	81 c9 21 01          	or     $0x121,%cx
   ee351:	b8 94 12             	mov    $0x1294,%ax
   ee354:	0b c1                	or     %cx,%ax
   ee356:	80 3e ff 04 00       	cmpb   $0x0,0x4ff
   ee35b:	74 03                	je     0xee360
   ee35d:	25 df ff             	and    $0xffdf,%ax
   ee360:	26 89 05             	mov    %ax,%es:(%di)
   ee363:	33 c0                	xor    %ax,%ax
   ee365:	26 89 45 02          	mov    %ax,%es:0x2(%di)
   ee369:	8a c3                	mov    %bl,%al
   ee36b:	a8 02                	test   $0x2,%al
   ee36d:	74 03                	je     0xee372
   ee36f:	e9 2f f8             	jmp    0xedba1
   ee372:	e9 27 f8             	jmp    0xedb9c
   ee375:	33 c0                	xor    %ax,%ax
   ee377:	26 80 3d 00          	cmpb   $0x0,%es:(%di)
   ee37b:	74 14                	je     0xee391
   ee37d:	26 80 3d 01          	cmpb   $0x1,%es:(%di)
   ee381:	74 06                	je     0xee389
   ee383:	b8 03 80             	mov    $0x8003,%ax
   ee386:	e9 04 f7             	jmp    0xeda8d
   ee389:	26 c7 45 01 30 09    	movw   $0x930,%es:0x1(%di)
   ee38f:	eb 06                	jmp    0xee397
   ee391:	26 c7 45 01 00 08    	movw   $0x800,%es:0x1(%di)
   ee397:	e9 c7 fc             	jmp    0xee061
   ee39a:	e8 f3 1a             	call   0xefe90
   ee39d:	3c 01                	cmp    $0x1,%al
   ee39f:	74 03                	je     0xee3a4
   ee3a1:	e9 4c 21             	jmp    0xe04f0
   ee3a4:	c6 06 f9 00 01       	movb   $0x1,0xf9
   ee3a9:	e8 55 12             	call   0xef601
   ee3ac:	88 1e 06 01          	mov    %bl,0x106
   ee3b0:	3c ff                	cmp    $0xff,%al
   ee3b2:	75 03                	jne    0xee3b7
   ee3b4:	e9 66 fd             	jmp    0xee11d
   ee3b7:	3c 02                	cmp    $0x2,%al
   ee3b9:	74 24                	je     0xee3df
   ee3bb:	e8 1f 25             	call   0xe08dd
   ee3be:	e8 f1 0b             	call   0xeefb2
   ee3c1:	3c ff                	cmp    $0xff,%al
   ee3c3:	75 03                	jne    0xee3c8
   ee3c5:	e9 28 21             	jmp    0xe04f0
   ee3c8:	3c 01                	cmp    $0x1,%al
   ee3ca:	75 0b                	jne    0xee3d7
   ee3cc:	b0 00                	mov    $0x0,%al
   ee3ce:	a2 fe 00             	mov    %al,0xfe
   ee3d1:	a2 ff 00             	mov    %al,0xff
   ee3d4:	e9 68 02             	jmp    0xee63f
   ee3d7:	a1 84 00             	mov    0x84,%ax
   ee3da:	ab                   	stos   %ax,%es:(%di)
   ee3db:	a1 86 00             	mov    0x86,%ax
   ee3de:	ab                   	stos   %ax,%es:(%di)
   ee3df:	33 c0                	xor    %ax,%ax
   ee3e1:	a0 06 01             	mov    0x106,%al
   ee3e4:	a8 40                	test   $0x40,%al
   ee3e6:	75 03                	jne    0xee3eb
   ee3e8:	e9 32 fd             	jmp    0xee11d
   ee3eb:	a8 20                	test   $0x20,%al
   ee3ed:	74 0f                	je     0xee3fe
   ee3ef:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee3f4:	c6 06 01 05 01       	movb   $0x1,0x501
   ee3f9:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee3fe:	80 3e 01 05 00       	cmpb   $0x0,0x501
   ee403:	74 12                	je     0xee417
   ee405:	e8 e6 00             	call   0xee4ee
   ee408:	e8 af 0c             	call   0xef0ba
   ee40b:	3c ff                	cmp    $0xff,%al
   ee40d:	74 05                	je     0xee414
   ee40f:	c6 06 01 05 00       	movb   $0x0,0x501
   ee414:	a0 06 01             	mov    0x106,%al
   ee417:	a8 02                	test   $0x2,%al
   ee419:	75 03                	jne    0xee41e
   ee41b:	e9 7e f7             	jmp    0xedb9c
   ee41e:	32 c0                	xor    %al,%al
   ee420:	e9 67 f6             	jmp    0xeda8a
   ee423:	e8 6a 1a             	call   0xefe90
   ee426:	3c 01                	cmp    $0x1,%al
   ee428:	74 06                	je     0xee430
   ee42a:	b0 ff                	mov    $0xff,%al
   ee42c:	aa                   	stos   %al,%es:(%di)
   ee42d:	e9 ed fc             	jmp    0xee11d
   ee430:	80 3e f8 00 01       	cmpb   $0x1,0xf8
   ee435:	74 03                	je     0xee43a
   ee437:	e9 8f 00             	jmp    0xee4c9
   ee43a:	c6 06 f9 00 01       	movb   $0x1,0xf9
   ee43f:	e8 bf 11             	call   0xef601
   ee442:	8a c3                	mov    %bl,%al
   ee444:	a8 40                	test   $0x40,%al
   ee446:	75 14                	jne    0xee45c
   ee448:	e8 a3 00             	call   0xee4ee
   ee44b:	b0 ff                	mov    $0xff,%al
   ee44d:	aa                   	stos   %al,%es:(%di)
   ee44e:	b0 01                	mov    $0x1,%al
   ee450:	a2 f4 04             	mov    %al,0x4f4
   ee453:	a2 01 05             	mov    %al,0x501
   ee456:	a2 a8 03             	mov    %al,0x3a8
   ee459:	e9 40 f7             	jmp    0xedb9c
   ee45c:	80 3e a8 03 00       	cmpb   $0x0,0x3a8
   ee461:	74 09                	je     0xee46c
   ee463:	80 3e 01 05 00       	cmpb   $0x0,0x501
   ee468:	74 02                	je     0xee46c
   ee46a:	eb 2c                	jmp    0xee498
   ee46c:	a8 20                	test   $0x20,%al
   ee46e:	75 28                	jne    0xee498
   ee470:	8b 0e 84 00          	mov    0x84,%cx
   ee474:	8b 1e 86 00          	mov    0x86,%bx
   ee478:	51                   	push   %cx
   ee479:	53                   	push   %bx
   ee47a:	e8 35 0b             	call   0xeefb2
   ee47d:	5b                   	pop    %bx
   ee47e:	59                   	pop    %cx
   ee47f:	3c ff                	cmp    $0xff,%al
   ee481:	74 15                	je     0xee498
   ee483:	80 3e a8 03 01       	cmpb   $0x1,0x3a8
   ee488:	74 0e                	je     0xee498
   ee48a:	3b 0e 84 00          	cmp    0x84,%cx
   ee48e:	75 08                	jne    0xee498
   ee490:	3b 1e 86 00          	cmp    0x86,%bx
   ee494:	75 02                	jne    0xee498
   ee496:	eb 31                	jmp    0xee4c9
   ee498:	b0 ff                	mov    $0xff,%al
   ee49a:	aa                   	stos   %al,%es:(%di)
   ee49b:	e8 50 00             	call   0xee4ee
   ee49e:	b0 00                	mov    $0x0,%al
   ee4a0:	a2 fe 00             	mov    %al,0xfe
   ee4a3:	a2 ff 00             	mov    %al,0xff
   ee4a6:	e8 11 0c             	call   0xef0ba
   ee4a9:	3c ff                	cmp    $0xff,%al
   ee4ab:	75 11                	jne    0xee4be
   ee4ad:	e8 3e 00             	call   0xee4ee
   ee4b0:	b0 01                	mov    $0x1,%al
   ee4b2:	a2 f4 04             	mov    %al,0x4f4
   ee4b5:	a2 01 05             	mov    %al,0x501
   ee4b8:	a2 a8 03             	mov    %al,0x3a8
   ee4bb:	e9 de f6             	jmp    0xedb9c
   ee4be:	b0 00                	mov    $0x0,%al
   ee4c0:	a2 a8 03             	mov    %al,0x3a8
   ee4c3:	a2 01 05             	mov    %al,0x501
   ee4c6:	e9 d3 f6             	jmp    0xedb9c
   ee4c9:	32 c0                	xor    %al,%al
   ee4cb:	33 f6                	xor    %si,%si
   ee4cd:	8a 84 9a 03          	mov    0x39a(%si),%al
   ee4d1:	b9 0c 00             	mov    $0xc,%cx
   ee4d4:	46                   	inc    %si
   ee4d5:	22 84 9a 03          	and    0x39a(%si),%al
   ee4d9:	e2 f9                	loop   0xee4d4
   ee4db:	3c ff                	cmp    $0xff,%al
   ee4dd:	74 02                	je     0xee4e1
   ee4df:	eb b7                	jmp    0xee498
   ee4e1:	b8 01 00             	mov    $0x1,%ax
   ee4e4:	aa                   	stos   %al,%es:(%di)
   ee4e5:	e9 b4 f6             	jmp    0xedb9c
   ee4e8:	b8 0c 80             	mov    $0x800c,%ax
   ee4eb:	e9 9f f5             	jmp    0xeda8d
   ee4ee:	06                   	push   %es
   ee4ef:	57                   	push   %di
   ee4f0:	8c c8                	mov    %cs,%ax
   ee4f2:	8e c0                	mov    %ax,%es
   ee4f4:	bf 9a 03             	mov    $0x39a,%di
   ee4f7:	b9 0d 00             	mov    $0xd,%cx
   ee4fa:	32 c0                	xor    %al,%al
   ee4fc:	fc                   	cld
   ee4fd:	aa                   	stos   %al,%es:(%di)
   ee4fe:	e2 fd                	loop   0xee4fd
   ee500:	5f                   	pop    %di
   ee501:	07                   	pop    %es
   ee502:	c3                   	ret
   ee503:	e8 8a 19             	call   0xefe90
   ee506:	3c 01                	cmp    $0x1,%al
   ee508:	74 03                	je     0xee50d
   ee50a:	e9 e3 1f             	jmp    0xe04f0
   ee50d:	e8 11 0b             	call   0xef021
   ee510:	3c 00                	cmp    $0x0,%al
   ee512:	74 03                	je     0xee517
   ee514:	e9 06 fc             	jmp    0xee11d
   ee517:	e8 c3 23             	call   0xe08dd
   ee51a:	e8 95 0a             	call   0xeefb2
   ee51d:	3c ff                	cmp    $0xff,%al
   ee51f:	75 03                	jne    0xee524
   ee521:	e9 cc 1f             	jmp    0xe04f0
   ee524:	3c 01                	cmp    $0x1,%al
   ee526:	75 0b                	jne    0xee533
   ee528:	b0 00                	mov    $0x0,%al
   ee52a:	a2 fe 00             	mov    %al,0xfe
   ee52d:	a2 ff 00             	mov    %al,0xff
   ee530:	e9 0c 01             	jmp    0xee63f
   ee533:	a0 7c 00             	mov    0x7c,%al
   ee536:	e8 9a 24             	call   0xe09d3
   ee539:	aa                   	stos   %al,%es:(%di)
   ee53a:	a0 7d 00             	mov    0x7d,%al
   ee53d:	e8 93 24             	call   0xe09d3
   ee540:	aa                   	stos   %al,%es:(%di)
   ee541:	a0 80 00             	mov    0x80,%al
   ee544:	e8 8c 24             	call   0xe09d3
   ee547:	aa                   	stos   %al,%es:(%di)
   ee548:	a0 7f 00             	mov    0x7f,%al
   ee54b:	e8 85 24             	call   0xe09d3
   ee54e:	aa                   	stos   %al,%es:(%di)
   ee54f:	a0 7e 00             	mov    0x7e,%al
   ee552:	e8 7e 24             	call   0xe09d3
   ee555:	aa                   	stos   %al,%es:(%di)
   ee556:	33 c0                	xor    %ax,%ax
   ee558:	aa                   	stos   %al,%es:(%di)
   ee559:	a0 06 01             	mov    0x106,%al
   ee55c:	a8 40                	test   $0x40,%al
   ee55e:	75 03                	jne    0xee563
   ee560:	e9 ba fb             	jmp    0xee11d
   ee563:	a8 20                	test   $0x20,%al
   ee565:	74 0f                	je     0xee576
   ee567:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee56c:	c6 06 01 05 01       	movb   $0x1,0x501
   ee571:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee576:	a8 02                	test   $0x2,%al
   ee578:	75 05                	jne    0xee57f
   ee57a:	32 c0                	xor    %al,%al
   ee57c:	e9 0e f5             	jmp    0xeda8d
   ee57f:	32 c0                	xor    %al,%al
   ee581:	e9 06 f5             	jmp    0xeda8a
   ee584:	b8 03 80             	mov    $0x8003,%ax
   ee587:	e9 03 f5             	jmp    0xeda8d
   ee58a:	e8 03 19             	call   0xefe90
   ee58d:	3c 01                	cmp    $0x1,%al
   ee58f:	74 03                	je     0xee594
   ee591:	e9 5c 1f             	jmp    0xe04f0
   ee594:	56                   	push   %si
   ee595:	55                   	push   %bp
   ee596:	33 f6                	xor    %si,%si
   ee598:	8a 84 9a 03          	mov    0x39a(%si),%al
   ee59c:	b9 0c 00             	mov    $0xc,%cx
   ee59f:	46                   	inc    %si
   ee5a0:	22 84 9a 03          	and    0x39a(%si),%al
   ee5a4:	e2 f9                	loop   0xee59f
   ee5a6:	3c ff                	cmp    $0xff,%al
   ee5a8:	74 22                	je     0xee5cc
   ee5aa:	e8 0d 0b             	call   0xef0ba
   ee5ad:	3c ff                	cmp    $0xff,%al
   ee5af:	75 05                	jne    0xee5b6
   ee5b1:	5d                   	pop    %bp
   ee5b2:	5e                   	pop    %si
   ee5b3:	e9 3a 1f             	jmp    0xe04f0
   ee5b6:	3c 01                	cmp    $0x1,%al
   ee5b8:	75 0a                	jne    0xee5c4
   ee5ba:	b0 00                	mov    $0x0,%al
   ee5bc:	a2 fe 00             	mov    %al,0xfe
   ee5bf:	a2 ff 00             	mov    %al,0xff
   ee5c2:	eb 7b                	jmp    0xee63f
   ee5c4:	b0 00                	mov    $0x0,%al
   ee5c6:	a2 fe 00             	mov    %al,0xfe
   ee5c9:	a2 ff 00             	mov    %al,0xff
   ee5cc:	26 8a 05             	mov    %es:(%di),%al
   ee5cf:	a2 97 03             	mov    %al,0x397
   ee5d2:	33 c9                	xor    %cx,%cx
   ee5d4:	8a c8                	mov    %al,%cl
   ee5d6:	a0 7d 00             	mov    0x7d,%al
   ee5d9:	e8 f7 23             	call   0xe09d3
   ee5dc:	8a e1                	mov    %cl,%ah
   ee5de:	3a e0                	cmp    %al,%ah
   ee5e0:	77 54                	ja     0xee636
   ee5e2:	8a c4                	mov    %ah,%al
   ee5e4:	32 e4                	xor    %ah,%ah
   ee5e6:	b1 03                	mov    $0x3,%cl
   ee5e8:	f6 e1                	mul    %cl
   ee5ea:	40                   	inc    %ax
   ee5eb:	40                   	inc    %ax
   ee5ec:	8b e8                	mov    %ax,%bp
   ee5ee:	3e 8a 86 07 02       	mov    %ds:0x207(%bp),%al
   ee5f3:	e8 dd 23             	call   0xe09d3
   ee5f6:	47                   	inc    %di
   ee5f7:	aa                   	stos   %al,%es:(%di)
   ee5f8:	4d                   	dec    %bp
   ee5f9:	3e 8a 86 07 02       	mov    %ds:0x207(%bp),%al
   ee5fe:	e8 d2 23             	call   0xe09d3
   ee601:	aa                   	stos   %al,%es:(%di)
   ee602:	4d                   	dec    %bp
   ee603:	3e 8a 86 07 02       	mov    %ds:0x207(%bp),%al
   ee608:	e8 c8 23             	call   0xe09d3
   ee60b:	aa                   	stos   %al,%es:(%di)
   ee60c:	33 c0                	xor    %ax,%ax
   ee60e:	aa                   	stos   %al,%es:(%di)
   ee60f:	33 db                	xor    %bx,%bx
   ee611:	8a 1e 97 03          	mov    0x397,%bl
   ee615:	8a 87 33 03          	mov    0x333(%bx),%al
   ee619:	24 f0                	and    $0xf0,%al
   ee61b:	aa                   	stos   %al,%es:(%di)
   ee61c:	5d                   	pop    %bp
   ee61d:	5e                   	pop    %si
   ee61e:	e8 e0 0f             	call   0xef601
   ee621:	3c ff                	cmp    $0xff,%al
   ee623:	75 03                	jne    0xee628
   ee625:	e9 f5 fa             	jmp    0xee11d
   ee628:	3c 01                	cmp    $0x1,%al
   ee62a:	74 07                	je     0xee633
   ee62c:	3c 02                	cmp    $0x2,%al
   ee62e:	74 f5                	je     0xee625
   ee630:	e9 69 f5             	jmp    0xedb9c
   ee633:	e9 6b f5             	jmp    0xedba1
   ee636:	f8                   	clc
   ee637:	5d                   	pop    %bp
   ee638:	5e                   	pop    %si
   ee639:	b8 03 80             	mov    $0x8003,%ax
   ee63c:	e9 4e f4             	jmp    0xeda8d
   ee63f:	f8                   	clc
   ee640:	5d                   	pop    %bp
   ee641:	5e                   	pop    %si
   ee642:	b8 0b 80             	mov    $0x800b,%ax
   ee645:	e9 45 f4             	jmp    0xeda8d
   ee648:	e8 45 18             	call   0xefe90
   ee64b:	3c 01                	cmp    $0x1,%al
   ee64d:	74 03                	je     0xee652
   ee64f:	e9 9e 1e             	jmp    0xe04f0
   ee652:	80 3e fe 00 01       	cmpb   $0x1,0xfe
   ee657:	74 0a                	je     0xee663
   ee659:	e8 c5 09             	call   0xef021
   ee65c:	3c 00                	cmp    $0x0,%al
   ee65e:	74 03                	je     0xee663
   ee660:	e9 ba fa             	jmp    0xee11d
   ee663:	e8 06 21             	call   0xe076c
   ee666:	50                   	push   %ax
   ee667:	a0 97 00             	mov    0x97,%al
   ee66a:	aa                   	stos   %al,%es:(%di)
   ee66b:	a0 98 00             	mov    0x98,%al
   ee66e:	aa                   	stos   %al,%es:(%di)
   ee66f:	a0 99 00             	mov    0x99,%al
   ee672:	aa                   	stos   %al,%es:(%di)
   ee673:	a0 9a 00             	mov    0x9a,%al
   ee676:	e8 5a 23             	call   0xe09d3
   ee679:	aa                   	stos   %al,%es:(%di)
   ee67a:	a0 9b 00             	mov    0x9b,%al
   ee67d:	e8 53 23             	call   0xe09d3
   ee680:	aa                   	stos   %al,%es:(%di)
   ee681:	a0 9c 00             	mov    0x9c,%al
   ee684:	e8 4c 23             	call   0xe09d3
   ee687:	aa                   	stos   %al,%es:(%di)
   ee688:	a0 9d 00             	mov    0x9d,%al
   ee68b:	e8 45 23             	call   0xe09d3
   ee68e:	aa                   	stos   %al,%es:(%di)
   ee68f:	a0 9e 00             	mov    0x9e,%al
   ee692:	e8 3e 23             	call   0xe09d3
   ee695:	aa                   	stos   %al,%es:(%di)
   ee696:	a0 9f 00             	mov    0x9f,%al
   ee699:	e8 37 23             	call   0xe09d3
   ee69c:	aa                   	stos   %al,%es:(%di)
   ee69d:	a0 a0 00             	mov    0xa0,%al
   ee6a0:	e8 30 23             	call   0xe09d3
   ee6a3:	aa                   	stos   %al,%es:(%di)
   ee6a4:	58                   	pop    %ax
   ee6a5:	3c 00                	cmp    $0x0,%al
   ee6a7:	74 06                	je     0xee6af
   ee6a9:	3c 01                	cmp    $0x1,%al
   ee6ab:	74 29                	je     0xee6d6
   ee6ad:	eb 07                	jmp    0xee6b6
   ee6af:	a0 06 01             	mov    0x106,%al
   ee6b2:	a8 40                	test   $0x40,%al
   ee6b4:	75 03                	jne    0xee6b9
   ee6b6:	e9 64 fa             	jmp    0xee11d
   ee6b9:	a8 20                	test   $0x20,%al
   ee6bb:	74 0f                	je     0xee6cc
   ee6bd:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ee6c2:	c6 06 01 05 01       	movb   $0x1,0x501
   ee6c7:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ee6cc:	a8 02                	test   $0x2,%al
   ee6ce:	75 03                	jne    0xee6d3
   ee6d0:	e9 c9 f4             	jmp    0xedb9c
   ee6d3:	e9 cb f4             	jmp    0xedba1
   ee6d6:	e9 38 fa             	jmp    0xee111
   ee6d9:	c6 06 26 04 00       	movb   $0x0,0x426
   ee6de:	c6 06 27 04 00       	movb   $0x0,0x427
   ee6e3:	47                   	inc    %di
   ee6e4:	47                   	inc    %di
   ee6e5:	47                   	inc    %di
   ee6e6:	47                   	inc    %di
   ee6e7:	26 8b 05             	mov    %es:(%di),%ax
   ee6ea:	a3 f1 00             	mov    %ax,0xf1
   ee6ed:	47                   	inc    %di
   ee6ee:	47                   	inc    %di
   ee6ef:	26 8b 05             	mov    %es:(%di),%ax
   ee6f2:	a3 f3 00             	mov    %ax,0xf3
   ee6f5:	47                   	inc    %di
   ee6f6:	47                   	inc    %di
   ee6f7:	26 8a 05             	mov    %es:(%di),%al
   ee6fa:	a2 c9 03             	mov    %al,0x3c9
   ee6fd:	47                   	inc    %di
   ee6fe:	26 8a 05             	mov    %es:(%di),%al
   ee701:	a2 ca 03             	mov    %al,0x3ca
   ee704:	47                   	inc    %di
   ee705:	26 8a 05             	mov    %es:(%di),%al
   ee708:	a2 cb 03             	mov    %al,0x3cb
   ee70b:	47                   	inc    %di
   ee70c:	a0 c9 03             	mov    0x3c9,%al
   ee70f:	0a 06 ca 03          	or     0x3ca,%al
   ee713:	0a 06 cb 03          	or     0x3cb,%al
   ee717:	3c 00                	cmp    $0x0,%al
   ee719:	75 06                	jne    0xee721
   ee71b:	e8 89 01             	call   0xee8a7
   ee71e:	eb 7f                	jmp    0xee79f
   ee720:	90                   	nop
   ee721:	a0 c9 03             	mov    0x3c9,%al
   ee724:	8a 26 ca 03          	mov    0x3ca,%ah
   ee728:	a3 79 00             	mov    %ax,0x79
   ee72b:	32 f6                	xor    %dh,%dh
   ee72d:	8a 16 cb 03          	mov    0x3cb,%dl
   ee731:	88 16 7b 00          	mov    %dl,0x7b
   ee735:	01 06 cc 03          	add    %ax,0x3cc
   ee739:	11 16 ce 03          	adc    %dx,0x3ce
   ee73d:	2b 06 d0 03          	sub    0x3d0,%ax
   ee741:	1b 16 d2 03          	sbb    0x3d2,%dx
   ee745:	73 08                	jae    0xee74f
   ee747:	f8                   	clc
   ee748:	c6 06 d4 03 01       	movb   $0x1,0x3d4
   ee74d:	eb 05                	jmp    0xee754
   ee74f:	c6 06 d4 03 00       	movb   $0x0,0x3d4
   ee754:	bb 04 00             	mov    $0x4,%bx
   ee757:	ba e8 03             	mov    $0x3e8,%dx
   ee75a:	80 3e 27 04 03       	cmpb   $0x3,0x427
   ee75f:	75 02                	jne    0xee763
   ee761:	eb 3c                	jmp    0xee79f
   ee763:	e8 06 01             	call   0xee86c
   ee766:	3c 03                	cmp    $0x3,%al
   ee768:	7d 13                	jge    0xee77d
   ee76a:	b9 01 00             	mov    $0x1,%cx
   ee76d:	e8 86 22             	call   0xe09f6
   ee770:	4a                   	dec    %dx
   ee771:	75 e7                	jne    0xee75a
   ee773:	4b                   	dec    %bx
   ee774:	75 e1                	jne    0xee757
   ee776:	c6 06 26 04 02       	movb   $0x2,0x426
   ee77b:	eb 22                	jmp    0xee79f
   ee77d:	e8 f4 01             	call   0xee974
   ee780:	e8 b0 02             	call   0xeea33
   ee783:	e8 21 01             	call   0xee8a7
   ee786:	ff 0e 79 00          	decw   0x79
   ee78a:	75 cb                	jne    0xee757
   ee78c:	80 3e 7b 00 00       	cmpb   $0x0,0x7b
   ee791:	74 0c                	je     0xee79f
   ee793:	fe 0e 7b 00          	decb   0x7b
   ee797:	c7 06 79 00 ff ff    	movw   $0xffff,0x79
   ee79d:	eb b8                	jmp    0xee757
   ee79f:	80 3e 26 04 02       	cmpb   $0x2,0x426
   ee7a4:	75 1a                	jne    0xee7c0
   ee7a6:	83 ef 03             	sub    $0x3,%di
   ee7a9:	a0 c9 03             	mov    0x3c9,%al
   ee7ac:	8a 26 ca 03          	mov    0x3ca,%ah
   ee7b0:	8a 16 cb 03          	mov    0x3cb,%dl
   ee7b4:	2b 06 79 00          	sub    0x79,%ax
   ee7b8:	1a 16 7b 00          	sbb    0x7b,%dl
   ee7bc:	ab                   	stos   %ax,%es:(%di)
   ee7bd:	8a c2                	mov    %dl,%al
   ee7bf:	aa                   	stos   %al,%es:(%di)
   ee7c0:	32 e4                	xor    %ah,%ah
   ee7c2:	b0 22                	mov    $0x22,%al
   ee7c4:	47                   	inc    %di
   ee7c5:	ab                   	stos   %ax,%es:(%di)
   ee7c6:	e8 a3 00             	call   0xee86c
   ee7c9:	3c 02                	cmp    $0x2,%al
   ee7cb:	72 04                	jb     0xee7d1
   ee7cd:	2c 02                	sub    $0x2,%al
   ee7cf:	eb 02                	jmp    0xee7d3
   ee7d1:	33 c0                	xor    %ax,%ax
   ee7d3:	ab                   	stos   %ax,%es:(%di)
   ee7d4:	33 d2                	xor    %dx,%dx
   ee7d6:	a0 dd 03             	mov    0x3dd,%al
   ee7d9:	8a 26 de 03          	mov    0x3de,%ah
   ee7dd:	8a 16 df 03          	mov    0x3df,%dl
   ee7e1:	80 3e d5 03 01       	cmpb   $0x1,0x3d5
   ee7e6:	74 09                	je     0xee7f1
   ee7e8:	e8 a0 00             	call   0xee88b
   ee7eb:	2d 96 00             	sub    $0x96,%ax
   ee7ee:	83 da 00             	sbb    $0x0,%dx
   ee7f1:	ab                   	stos   %ax,%es:(%di)
   ee7f2:	8a c2                	mov    %dl,%al
   ee7f4:	32 e4                	xor    %ah,%ah
   ee7f6:	ab                   	stos   %ax,%es:(%di)
   ee7f7:	32 c0                	xor    %al,%al
   ee7f9:	80 3e 26 04 02       	cmpb   $0x2,0x426
   ee7fe:	74 07                	je     0xee807
   ee800:	80 3e d4 03 01       	cmpb   $0x1,0x3d4
   ee805:	74 1e                	je     0xee825
   ee807:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   ee80c:	e8 f2 0d             	call   0xef601
   ee80f:	3c ff                	cmp    $0xff,%al
   ee811:	74 15                	je     0xee828
   ee813:	80 3e 26 04 02       	cmpb   $0x2,0x426
   ee818:	74 17                	je     0xee831
   ee81a:	3c 02                	cmp    $0x2,%al
   ee81c:	74 0a                	je     0xee828
   ee81e:	3c 01                	cmp    $0x1,%al
   ee820:	74 03                	je     0xee825
   ee822:	e9 77 f3             	jmp    0xedb9c
   ee825:	e9 79 f3             	jmp    0xedba1
   ee828:	e9 f2 f8             	jmp    0xee11d
   ee82b:	e9 e3 f8             	jmp    0xee111
   ee82e:	e9 b7 fc             	jmp    0xee4e8
   ee831:	b8 08 80             	mov    $0x8008,%ax
   ee834:	f6 c3 02             	test   $0x2,%bl
   ee837:	75 03                	jne    0xee83c
   ee839:	e9 51 f2             	jmp    0xeda8d
   ee83c:	e9 4b f2             	jmp    0xeda8a
   ee83f:	c6 06 26 04 00       	movb   $0x0,0x426
   ee844:	c6 06 27 04 00       	movb   $0x0,0x427
   ee849:	e8 91 20             	call   0xe08dd
   ee84c:	8b 16 61 00          	mov    0x61,%dx
   ee850:	b0 b0                	mov    $0xb0,%al
   ee852:	ee                   	out    %al,(%dx)
   ee853:	a0 6f 00             	mov    0x6f,%al
   ee856:	ee                   	out    %al,(%dx)
   ee857:	a0 70 00             	mov    0x70,%al
   ee85a:	ee                   	out    %al,(%dx)
   ee85b:	a0 71 00             	mov    0x71,%al
   ee85e:	ee                   	out    %al,(%dx)
   ee85f:	a0 72 00             	mov    0x72,%al
   ee862:	ee                   	out    %al,(%dx)
   ee863:	a0 73 00             	mov    0x73,%al
   ee866:	ee                   	out    %al,(%dx)
   ee867:	a0 74 00             	mov    0x74,%al
   ee86a:	ee                   	out    %al,(%dx)
   ee86b:	c3                   	ret
   ee86c:	33 c0                	xor    %ax,%ax
   ee86e:	a0 db 03             	mov    0x3db,%al
   ee871:	3a 06 dc 03          	cmp    0x3dc,%al
   ee875:	77 09                	ja     0xee880
   ee877:	a0 dc 03             	mov    0x3dc,%al
   ee87a:	2a 06 db 03          	sub    0x3db,%al
   ee87e:	eb 0a                	jmp    0xee88a
   ee880:	b0 21                	mov    $0x21,%al
   ee882:	2a 06 db 03          	sub    0x3db,%al
   ee886:	02 06 dc 03          	add    0x3dc,%al
   ee88a:	c3                   	ret
   ee88b:	32 f6                	xor    %dh,%dh
   ee88d:	8b d8                	mov    %ax,%bx
   ee88f:	8a c2                	mov    %dl,%al
   ee891:	b1 3c                	mov    $0x3c,%cl
   ee893:	f6 e1                	mul    %cl
   ee895:	02 c7                	add    %bh,%al
   ee897:	80 d4 00             	adc    $0x0,%ah
   ee89a:	b9 4b 00             	mov    $0x4b,%cx
   ee89d:	f7 e1                	mul    %cx
   ee89f:	32 ff                	xor    %bh,%bh
   ee8a1:	03 c3                	add    %bx,%ax
   ee8a3:	83 d2 00             	adc    $0x0,%dx
   ee8a6:	c3                   	ret
   ee8a7:	06                   	push   %es
   ee8a8:	1e                   	push   %ds
   ee8a9:	57                   	push   %di
   ee8aa:	56                   	push   %si
   ee8ab:	50                   	push   %ax
   ee8ac:	53                   	push   %bx
   ee8ad:	51                   	push   %cx
   ee8ae:	80 3e 26 04 00       	cmpb   $0x0,0x426
   ee8b3:	75 73                	jne    0xee928
   ee8b5:	33 db                	xor    %bx,%bx
   ee8b7:	8a 1e db 03          	mov    0x3db,%bl
   ee8bb:	d1 e3                	shl    $1,%bx
   ee8bd:	8b bf e0 03          	mov    0x3e0(%bx),%di
   ee8c1:	8c c8                	mov    %cs,%ax
   ee8c3:	8e c0                	mov    %ax,%es
   ee8c5:	83 c7 39             	add    $0x39,%di
   ee8c8:	c6 06 d6 03 08       	movb   $0x8,0x3d6
   ee8cd:	c6 06 d7 03 03       	movb   $0x3,0x3d7
   ee8d2:	33 d2                	xor    %dx,%dx
   ee8d4:	26 8a 05             	mov    %es:(%di),%al
   ee8d7:	47                   	inc    %di
   ee8d8:	a8 40                	test   $0x40,%al
   ee8da:	74 0c                	je     0xee8e8
   ee8dc:	8a 0e d6 03          	mov    0x3d6,%cl
   ee8e0:	fe c9                	dec    %cl
   ee8e2:	b0 01                	mov    $0x1,%al
   ee8e4:	d2 e0                	shl    %cl,%al
   ee8e6:	0a d0                	or     %al,%dl
   ee8e8:	fe 0e d6 03          	decb   0x3d6
   ee8ec:	75 e6                	jne    0xee8d4
   ee8ee:	c6 06 d6 03 08       	movb   $0x8,0x3d6
   ee8f3:	fe 0e d7 03          	decb   0x3d7
   ee8f7:	33 db                	xor    %bx,%bx
   ee8f9:	8a 1e d7 03          	mov    0x3d7,%bl
   ee8fd:	8a c2                	mov    %dl,%al
   ee8ff:	e8 d1 20             	call   0xe09d3
   ee902:	88 87 dd 03          	mov    %al,0x3dd(%bx)
   ee906:	32 d2                	xor    %dl,%dl
   ee908:	80 3e d7 03 00       	cmpb   $0x0,0x3d7
   ee90d:	75 c5                	jne    0xee8d4
   ee90f:	c6 06 26 04 01       	movb   $0x1,0x426
   ee914:	c6 06 27 04 02       	movb   $0x2,0x427
   ee919:	a0 c9 03             	mov    0x3c9,%al
   ee91c:	0a 06 ca 03          	or     0x3ca,%al
   ee920:	0a 06 cb 03          	or     0x3cb,%al
   ee924:	75 02                	jne    0xee928
   ee926:	eb 44                	jmp    0xee96c
   ee928:	8b 3e f1 00          	mov    0xf1,%di
   ee92c:	a1 f3 00             	mov    0xf3,%ax
   ee92f:	8e c0                	mov    %ax,%es
   ee931:	b9 60 00             	mov    $0x60,%cx
   ee934:	8b 36 24 04          	mov    0x424,%si
   ee938:	8c c8                	mov    %cs,%ax
   ee93a:	8e d8                	mov    %ax,%ds
   ee93c:	fc                   	cld
   ee93d:	8a 04                	mov    (%si),%al
   ee93f:	a4                   	movsb  %ds:(%si),%es:(%di)
   ee940:	83 ff 00             	cmp    $0x0,%di
   ee943:	75 08                	jne    0xee94d
   ee945:	8c c0                	mov    %es,%ax
   ee947:	80 c4 10             	add    $0x10,%ah
   ee94a:	8e c0                	mov    %ax,%es
   ee94c:	46                   	inc    %si
   ee94d:	e2 ee                	loop   0xee93d
   ee94f:	8c c8                	mov    %cs,%ax
   ee951:	8e d8                	mov    %ax,%ds
   ee953:	33 c0                	xor    %ax,%ax
   ee955:	a0 db 03             	mov    0x3db,%al
   ee958:	fe c0                	inc    %al
   ee95a:	3c 21                	cmp    $0x21,%al
   ee95c:	76 02                	jbe    0xee960
   ee95e:	33 c0                	xor    %ax,%ax
   ee960:	a2 db 03             	mov    %al,0x3db
   ee963:	89 3e f1 00          	mov    %di,0xf1
   ee967:	8c c0                	mov    %es,%ax
   ee969:	a3 f3 00             	mov    %ax,0xf3
   ee96c:	59                   	pop    %cx
   ee96d:	5b                   	pop    %bx
   ee96e:	58                   	pop    %ax
   ee96f:	5e                   	pop    %si
   ee970:	5f                   	pop    %di
   ee971:	1f                   	pop    %ds
   ee972:	07                   	pop    %es
   ee973:	c3                   	ret
   ee974:	06                   	push   %es
   ee975:	1e                   	push   %ds
   ee976:	57                   	push   %di
   ee977:	56                   	push   %si
   ee978:	50                   	push   %ax
   ee979:	53                   	push   %bx
   ee97a:	51                   	push   %cx
   ee97b:	33 db                	xor    %bx,%bx
   ee97d:	8a 1e db 03          	mov    0x3db,%bl
   ee981:	d1 e3                	shl    $1,%bx
   ee983:	8b bf e0 03          	mov    0x3e0(%bx),%di
   ee987:	47                   	inc    %di
   ee988:	8b 36 24 04          	mov    0x424,%si
   ee98c:	b9 04 00             	mov    $0x4,%cx
   ee98f:	c6 06 3d 04 00       	movb   $0x0,0x43d
   ee994:	e8 11 00             	call   0xee9a8
   ee997:	83 c7 18             	add    $0x18,%di
   ee99a:	fe 06 3d 04          	incb   0x43d
   ee99e:	e2 f4                	loop   0xee994
   ee9a0:	59                   	pop    %cx
   ee9a1:	5b                   	pop    %bx
   ee9a2:	58                   	pop    %ax
   ee9a3:	5e                   	pop    %si
   ee9a4:	5f                   	pop    %di
   ee9a5:	1f                   	pop    %ds
   ee9a6:	07                   	pop    %es
   ee9a7:	c3                   	ret
   ee9a8:	50                   	push   %ax
   ee9a9:	53                   	push   %bx
   ee9aa:	51                   	push   %cx
   ee9ab:	52                   	push   %dx
   ee9ac:	55                   	push   %bp
   ee9ad:	b6 18                	mov    $0x18,%dh
   ee9af:	b9 00 00             	mov    $0x0,%cx
   ee9b2:	bb bd 04             	mov    $0x4bd,%bx
   ee9b5:	8a c1                	mov    %cl,%al
   ee9b7:	d7                   	xlat   %ds:(%bx)
   ee9b8:	e8 24 00             	call   0xee9df
   ee9bb:	f6 e6                	mul    %dh
   ee9bd:	03 ef                	add    %di,%bp
   ee9bf:	b4 00                	mov    $0x0,%ah
   ee9c1:	03 e8                	add    %ax,%bp
   ee9c3:	bb d5 04             	mov    $0x4d5,%bx
   ee9c6:	8a c1                	mov    %cl,%al
   ee9c8:	d7                   	xlat   %ds:(%bx)
   ee9c9:	b4 00                	mov    $0x0,%ah
   ee9cb:	03 e8                	add    %ax,%bp
   ee9cd:	8a 46 00             	mov    0x0(%bp),%al
   ee9d0:	88 04                	mov    %al,(%si)
   ee9d2:	46                   	inc    %si
   ee9d3:	41                   	inc    %cx
   ee9d4:	83 f9 17             	cmp    $0x17,%cx
   ee9d7:	76 d9                	jbe    0xee9b2
   ee9d9:	5d                   	pop    %bp
   ee9da:	5a                   	pop    %dx
   ee9db:	59                   	pop    %cx
   ee9dc:	5b                   	pop    %bx
   ee9dd:	58                   	pop    %ax
   ee9de:	c3                   	ret
   ee9df:	bd 00 00             	mov    $0x0,%bp
   ee9e2:	80 3e 3d 04 00       	cmpb   $0x0,0x43d
   ee9e7:	74 15                	je     0xee9fe
   ee9e9:	80 3e 3d 04 01       	cmpb   $0x1,0x43d
   ee9ee:	74 16                	je     0xeea06
   ee9f0:	80 3e 3d 04 02       	cmpb   $0x2,0x43d
   ee9f5:	74 1e                	je     0xeea15
   ee9f7:	80 3e 3d 04 03       	cmpb   $0x3,0x43d
   ee9fc:	74 26                	je     0xeea24
   ee9fe:	3c 03                	cmp    $0x3,%al
   eea00:	76 03                	jbe    0xeea05
   eea02:	83 c5 02             	add    $0x2,%bp
   eea05:	c3                   	ret
   eea06:	3c 02                	cmp    $0x2,%al
   eea08:	76 0a                	jbe    0xeea14
   eea0a:	83 c5 02             	add    $0x2,%bp
   eea0d:	3c 06                	cmp    $0x6,%al
   eea0f:	76 03                	jbe    0xeea14
   eea11:	83 c5 02             	add    $0x2,%bp
   eea14:	c3                   	ret
   eea15:	3c 01                	cmp    $0x1,%al
   eea17:	76 0a                	jbe    0xeea23
   eea19:	83 c5 02             	add    $0x2,%bp
   eea1c:	3c 05                	cmp    $0x5,%al
   eea1e:	76 03                	jbe    0xeea23
   eea20:	83 c5 02             	add    $0x2,%bp
   eea23:	c3                   	ret
   eea24:	3c 00                	cmp    $0x0,%al
   eea26:	74 0a                	je     0xeea32
   eea28:	83 c5 02             	add    $0x2,%bp
   eea2b:	3c 04                	cmp    $0x4,%al
   eea2d:	76 03                	jbe    0xeea32
   eea2f:	83 c5 02             	add    $0x2,%bp
   eea32:	c3                   	ret
   eea33:	06                   	push   %es
   eea34:	1e                   	push   %ds
   eea35:	57                   	push   %di
   eea36:	56                   	push   %si
   eea37:	50                   	push   %ax
   eea38:	53                   	push   %bx
   eea39:	51                   	push   %cx
   eea3a:	8b 36 24 04          	mov    0x424,%si
   eea3e:	fc                   	cld
   eea3f:	bb 3f 3f             	mov    $0x3f3f,%bx
   eea42:	b9 30 00             	mov    $0x30,%cx
   eea45:	56                   	push   %si
   eea46:	ad                   	lods   %ds:(%si),%ax
   eea47:	23 c3                	and    %bx,%ax
   eea49:	89 44 fe             	mov    %ax,-0x2(%si)
   eea4c:	e2 f8                	loop   0xeea46
   eea4e:	5e                   	pop    %si
   eea4f:	b9 04 00             	mov    $0x4,%cx
   eea52:	c6 06 3d 04 00       	movb   $0x0,0x43d
   eea57:	c6 06 37 04 00       	movb   $0x0,0x437
   eea5c:	c6 06 38 04 00       	movb   $0x0,0x438
   eea61:	e8 34 00             	call   0xeea98
   eea64:	3c 00                	cmp    $0x0,%al
   eea66:	74 03                	je     0xeea6b
   eea68:	a2 37 04             	mov    %al,0x437
   eea6b:	e8 0a 01             	call   0xeeb78
   eea6e:	3c 00                	cmp    $0x0,%al
   eea70:	74 03                	je     0xeea75
   eea72:	a2 38 04             	mov    %al,0x438
   eea75:	83 c6 18             	add    $0x18,%si
   eea78:	fe 06 3d 04          	incb   0x43d
   eea7c:	e2 e3                	loop   0xeea61
   eea7e:	80 3e 37 04 00       	cmpb   $0x0,0x437
   eea83:	74 02                	je     0xeea87
   eea85:	b0 01                	mov    $0x1,%al
   eea87:	80 3e 38 04 00       	cmpb   $0x0,0x438
   eea8c:	74 02                	je     0xeea90
   eea8e:	b0 01                	mov    $0x1,%al
   eea90:	59                   	pop    %cx
   eea91:	5b                   	pop    %bx
   eea92:	58                   	pop    %ax
   eea93:	5e                   	pop    %si
   eea94:	5f                   	pop    %di
   eea95:	1f                   	pop    %ds
   eea96:	07                   	pop    %es
   eea97:	c3                   	ret
   eea98:	53                   	push   %bx
   eea99:	51                   	push   %cx
   eea9a:	52                   	push   %dx
   eea9b:	b9 18 00             	mov    $0x18,%cx
   eea9e:	e8 7a 02             	call   0xeed1b
   eeaa1:	88 16 28 04          	mov    %dl,0x428
   eeaa5:	b9 17 00             	mov    $0x17,%cx
   eeaa8:	c6 06 3a 04 01       	movb   $0x1,0x43a
   eeaad:	e8 80 02             	call   0xeed30
   eeab0:	88 16 29 04          	mov    %dl,0x429
   eeab4:	b9 17 00             	mov    $0x17,%cx
   eeab7:	c6 06 3a 04 02       	movb   $0x2,0x43a
   eeabc:	e8 71 02             	call   0xeed30
   eeabf:	88 16 2a 04          	mov    %dl,0x42a
   eeac3:	b9 17 00             	mov    $0x17,%cx
   eeac6:	c6 06 3a 04 03       	movb   $0x3,0x43a
   eeacb:	e8 62 02             	call   0xeed30
   eeace:	88 16 2b 04          	mov    %dl,0x42b
   eead2:	80 3e 28 04 00       	cmpb   $0x0,0x428
   eead7:	75 1b                	jne    0xeeaf4
   eead9:	80 3e 29 04 00       	cmpb   $0x0,0x429
   eeade:	75 14                	jne    0xeeaf4
   eeae0:	80 3e 2a 04 00       	cmpb   $0x0,0x42a
   eeae5:	75 0d                	jne    0xeeaf4
   eeae7:	80 3e 2b 04 00       	cmpb   $0x0,0x42b
   eeaec:	75 06                	jne    0xeeaf4
   eeaee:	b0 00                	mov    $0x0,%al
   eeaf0:	5a                   	pop    %dx
   eeaf1:	59                   	pop    %cx
   eeaf2:	5b                   	pop    %bx
   eeaf3:	c3                   	ret
   eeaf4:	8a 26 28 04          	mov    0x428,%ah
   eeaf8:	a0 2a 04             	mov    0x42a,%al
   eeafb:	e8 93 02             	call   0xeed91
   eeafe:	a2 2e 04             	mov    %al,0x42e
   eeb01:	8a 26 29 04          	mov    0x429,%ah
   eeb05:	a0 29 04             	mov    0x429,%al
   eeb08:	e8 86 02             	call   0xeed91
   eeb0b:	30 06 2e 04          	xor    %al,0x42e
   eeb0f:	8a 26 29 04          	mov    0x429,%ah
   eeb13:	a0 2a 04             	mov    0x42a,%al
   eeb16:	e8 78 02             	call   0xeed91
   eeb19:	a2 2f 04             	mov    %al,0x42f
   eeb1c:	8a 26 28 04          	mov    0x428,%ah
   eeb20:	a0 2b 04             	mov    0x42b,%al
   eeb23:	e8 6b 02             	call   0xeed91
   eeb26:	30 06 2f 04          	xor    %al,0x42f
   eeb2a:	8a 26 29 04          	mov    0x429,%ah
   eeb2e:	a0 2b 04             	mov    0x42b,%al
   eeb31:	e8 5d 02             	call   0xeed91
   eeb34:	a2 30 04             	mov    %al,0x430
   eeb37:	8a 26 2a 04          	mov    0x42a,%ah
   eeb3b:	a0 2a 04             	mov    0x42a,%al
   eeb3e:	e8 50 02             	call   0xeed91
   eeb41:	30 06 30 04          	xor    %al,0x430
   eeb45:	80 3e 2e 04 00       	cmpb   $0x0,0x42e
   eeb4a:	75 1f                	jne    0xeeb6b
   eeb4c:	80 3e 2f 04 00       	cmpb   $0x0,0x42f
   eeb51:	75 1f                	jne    0xeeb72
   eeb53:	80 3e 30 04 00       	cmpb   $0x0,0x430
   eeb58:	75 18                	jne    0xeeb72
   eeb5a:	8a 26 29 04          	mov    0x429,%ah
   eeb5e:	a0 28 04             	mov    0x428,%al
   eeb61:	bb 17 00             	mov    $0x17,%bx
   eeb64:	e8 52 00             	call   0xeebb9
   eeb67:	5a                   	pop    %dx
   eeb68:	59                   	pop    %cx
   eeb69:	5b                   	pop    %bx
   eeb6a:	c3                   	ret
   eeb6b:	e8 72 00             	call   0xeebe0
   eeb6e:	5a                   	pop    %dx
   eeb6f:	59                   	pop    %cx
   eeb70:	5b                   	pop    %bx
   eeb71:	c3                   	ret
   eeb72:	b0 01                	mov    $0x1,%al
   eeb74:	5a                   	pop    %dx
   eeb75:	59                   	pop    %cx
   eeb76:	5b                   	pop    %bx
   eeb77:	c3                   	ret
   eeb78:	53                   	push   %bx
   eeb79:	51                   	push   %cx
   eeb7a:	52                   	push   %dx
   eeb7b:	b9 04 00             	mov    $0x4,%cx
   eeb7e:	e8 9a 01             	call   0xeed1b
   eeb81:	88 16 2c 04          	mov    %dl,0x42c
   eeb85:	b9 03 00             	mov    $0x3,%cx
   eeb88:	c6 06 3a 04 01       	movb   $0x1,0x43a
   eeb8d:	e8 a0 01             	call   0xeed30
   eeb90:	88 16 2d 04          	mov    %dl,0x42d
   eeb94:	80 3e 2c 04 00       	cmpb   $0x0,0x42c
   eeb99:	75 0d                	jne    0xeeba8
   eeb9b:	80 3e 2d 04 00       	cmpb   $0x0,0x42d
   eeba0:	75 06                	jne    0xeeba8
   eeba2:	b0 00                	mov    $0x0,%al
   eeba4:	5a                   	pop    %dx
   eeba5:	59                   	pop    %cx
   eeba6:	5b                   	pop    %bx
   eeba7:	c3                   	ret
   eeba8:	8a 26 2d 04          	mov    0x42d,%ah
   eebac:	a0 2c 04             	mov    0x42c,%al
   eebaf:	bb 03 00             	mov    $0x3,%bx
   eebb2:	e8 04 00             	call   0xeebb9
   eebb5:	5a                   	pop    %dx
   eebb6:	59                   	pop    %cx
   eebb7:	5b                   	pop    %bx
   eebb8:	c3                   	ret
   eebb9:	52                   	push   %dx
   eebba:	8a d0                	mov    %al,%dl
   eebbc:	3c 00                	cmp    $0x0,%al
   eebbe:	74 1c                	je     0xeebdc
   eebc0:	e8 be 01             	call   0xeed81
   eebc3:	3a c3                	cmp    %bl,%al
   eebc5:	77 15                	ja     0xeebdc
   eebc7:	2a d8                	sub    %al,%bl
   eebc9:	8a e3                	mov    %bl,%ah
   eebcb:	b7 00                	mov    $0x0,%bh
   eebcd:	03 de                	add    %si,%bx
   eebcf:	8a 07                	mov    (%bx),%al
   eebd1:	32 c2                	xor    %dl,%al
   eebd3:	88 07                	mov    %al,(%bx)
   eebd5:	e8 db 01             	call   0xeedb3
   eebd8:	b0 00                	mov    $0x0,%al
   eebda:	5a                   	pop    %dx
   eebdb:	c3                   	ret
   eebdc:	b0 01                	mov    $0x1,%al
   eebde:	5a                   	pop    %dx
   eebdf:	c3                   	ret
   eebe0:	53                   	push   %bx
   eebe1:	51                   	push   %cx
   eebe2:	52                   	push   %dx
   eebe3:	c6 06 32 04 00       	movb   $0x0,0x432
   eebe8:	8a 26 2f 04          	mov    0x42f,%ah
   eebec:	a0 2e 04             	mov    0x42e,%al
   eebef:	e8 8f 01             	call   0xeed81
   eebf2:	a2 2f 04             	mov    %al,0x42f
   eebf5:	8a 26 30 04          	mov    0x430,%ah
   eebf9:	a0 2e 04             	mov    0x42e,%al
   eebfc:	e8 82 01             	call   0xeed81
   eebff:	a2 30 04             	mov    %al,0x430
   eec02:	80 3e 30 04 2d       	cmpb   $0x2d,0x430
   eec07:	77 0a                	ja     0xeec13
   eec09:	e8 91 00             	call   0xeec9d
   eec0c:	80 3e 32 04 00       	cmpb   $0x0,0x432
   eec11:	74 06                	je     0xeec19
   eec13:	b0 01                	mov    $0x1,%al
   eec15:	5a                   	pop    %dx
   eec16:	59                   	pop    %cx
   eec17:	5b                   	pop    %bx
   eec18:	c3                   	ret
   eec19:	a0 29 04             	mov    0x429,%al
   eec1c:	a2 35 04             	mov    %al,0x435
   eec1f:	a0 34 04             	mov    0x434,%al
   eec22:	bb 3e 04             	mov    $0x43e,%bx
   eec25:	d7                   	xlat   %ds:(%bx)
   eec26:	8a 26 28 04          	mov    0x428,%ah
   eec2a:	e8 64 01             	call   0xeed91
   eec2d:	30 06 35 04          	xor    %al,0x435
   eec31:	8a 26 35 04          	mov    0x435,%ah
   eec35:	a0 2f 04             	mov    0x42f,%al
   eec38:	d7                   	xlat   %ds:(%bx)
   eec39:	e8 45 01             	call   0xeed81
   eec3c:	d7                   	xlat   %ds:(%bx)
   eec3d:	a2 35 04             	mov    %al,0x435
   eec40:	a0 29 04             	mov    0x429,%al
   eec43:	a2 36 04             	mov    %al,0x436
   eec46:	a0 33 04             	mov    0x433,%al
   eec49:	bb 3e 04             	mov    $0x43e,%bx
   eec4c:	d7                   	xlat   %ds:(%bx)
   eec4d:	8a 26 28 04          	mov    0x428,%ah
   eec51:	e8 3d 01             	call   0xeed91
   eec54:	30 06 36 04          	xor    %al,0x436
   eec58:	8a 26 36 04          	mov    0x436,%ah
   eec5c:	a0 2f 04             	mov    0x42f,%al
   eec5f:	d7                   	xlat   %ds:(%bx)
   eec60:	e8 1e 01             	call   0xeed81
   eec63:	d7                   	xlat   %ds:(%bx)
   eec64:	a2 36 04             	mov    %al,0x436
   eec67:	a0 33 04             	mov    0x433,%al
   eec6a:	b4 17                	mov    $0x17,%ah
   eec6c:	2a e0                	sub    %al,%ah
   eec6e:	8a dc                	mov    %ah,%bl
   eec70:	b7 00                	mov    $0x0,%bh
   eec72:	03 de                	add    %si,%bx
   eec74:	8a 07                	mov    (%bx),%al
   eec76:	32 06 35 04          	xor    0x435,%al
   eec7a:	88 07                	mov    %al,(%bx)
   eec7c:	e8 34 01             	call   0xeedb3
   eec7f:	a0 34 04             	mov    0x434,%al
   eec82:	b4 17                	mov    $0x17,%ah
   eec84:	2a e0                	sub    %al,%ah
   eec86:	8a dc                	mov    %ah,%bl
   eec88:	b7 00                	mov    $0x0,%bh
   eec8a:	03 de                	add    %si,%bx
   eec8c:	8a 07                	mov    (%bx),%al
   eec8e:	32 06 36 04          	xor    0x436,%al
   eec92:	88 07                	mov    %al,(%bx)
   eec94:	e8 1c 01             	call   0xeedb3
   eec97:	b0 00                	mov    $0x0,%al
   eec99:	5a                   	pop    %dx
   eec9a:	59                   	pop    %cx
   eec9b:	5b                   	pop    %bx
   eec9c:	c3                   	ret
   eec9d:	50                   	push   %ax
   eec9e:	53                   	push   %bx
   eec9f:	51                   	push   %cx
   eeca0:	52                   	push   %dx
   eeca1:	c6 06 31 04 00       	movb   $0x0,0x431
   eeca6:	c6 06 33 04 ff       	movb   $0xff,0x433
   eecab:	c6 06 34 04 ff       	movb   $0xff,0x434
   eecb0:	c6 06 32 04 00       	movb   $0x0,0x432
   eecb5:	b9 17 00             	mov    $0x17,%cx
   eecb8:	bb 3e 04             	mov    $0x43e,%bx
   eecbb:	8a c1                	mov    %cl,%al
   eecbd:	02 c0                	add    %al,%al
   eecbf:	3c 3f                	cmp    $0x3f,%al
   eecc1:	72 02                	jb     0xeecc5
   eecc3:	2c 3f                	sub    $0x3f,%al
   eecc5:	d7                   	xlat   %ds:(%bx)
   eecc6:	8a d0                	mov    %al,%dl
   eecc8:	8a c1                	mov    %cl,%al
   eecca:	02 06 2f 04          	add    0x42f,%al
   eecce:	3c 3f                	cmp    $0x3f,%al
   eecd0:	72 02                	jb     0xeecd4
   eecd2:	2c 3f                	sub    $0x3f,%al
   eecd4:	d7                   	xlat   %ds:(%bx)
   eecd5:	32 d0                	xor    %al,%dl
   eecd7:	a0 30 04             	mov    0x430,%al
   eecda:	d7                   	xlat   %ds:(%bx)
   eecdb:	32 d0                	xor    %al,%dl
   eecdd:	75 21                	jne    0xeed00
   eecdf:	80 3e 31 04 00       	cmpb   $0x0,0x431
   eece4:	75 0b                	jne    0xeecf1
   eece6:	88 0e 33 04          	mov    %cl,0x433
   eecea:	c6 06 31 04 01       	movb   $0x1,0x431
   eecef:	eb 0f                	jmp    0xeed00
   eecf1:	80 3e 31 04 01       	cmpb   $0x1,0x431
   eecf6:	75 19                	jne    0xeed11
   eecf8:	88 0e 34 04          	mov    %cl,0x434
   eecfc:	fe 06 31 04          	incb   0x431
   eed00:	49                   	dec    %cx
   eed01:	7d b8                	jge    0xeecbb
   eed03:	80 3e 33 04 00       	cmpb   $0x0,0x433
   eed08:	7d 0c                	jge    0xeed16
   eed0a:	80 3e 34 04 00       	cmpb   $0x0,0x434
   eed0f:	7d 05                	jge    0xeed16
   eed11:	c6 06 32 04 01       	movb   $0x1,0x432
   eed16:	5a                   	pop    %dx
   eed17:	59                   	pop    %cx
   eed18:	5b                   	pop    %bx
   eed19:	58                   	pop    %ax
   eed1a:	c3                   	ret
   eed1b:	50                   	push   %ax
   eed1c:	56                   	push   %si
   eed1d:	ad                   	lods   %ds:(%si),%ax
   eed1e:	32 e0                	xor    %al,%ah
   eed20:	8a d4                	mov    %ah,%dl
   eed22:	83 e9 02             	sub    $0x2,%cx
   eed25:	ad                   	lods   %ds:(%si),%ax
   eed26:	32 e0                	xor    %al,%ah
   eed28:	32 d4                	xor    %ah,%dl
   eed2a:	49                   	dec    %cx
   eed2b:	e2 f8                	loop   0xeed25
   eed2d:	5e                   	pop    %si
   eed2e:	58                   	pop    %ax
   eed2f:	c3                   	ret
   eed30:	56                   	push   %si
   eed31:	50                   	push   %ax
   eed32:	8a c1                	mov    %cl,%al
   eed34:	f6 26 3a 04          	mulb   0x43a
   eed38:	a2 39 04             	mov    %al,0x439
   eed3b:	ac                   	lods   %ds:(%si),%al
   eed3c:	49                   	dec    %cx
   eed3d:	22 c0                	and    %al,%al
   eed3f:	74 16                	je     0xeed57
   eed41:	bb 7d 04             	mov    $0x47d,%bx
   eed44:	d7                   	xlat   %ds:(%bx)
   eed45:	02 06 39 04          	add    0x439,%al
   eed49:	bb 3e 04             	mov    $0x43e,%bx
   eed4c:	3c 3f                	cmp    $0x3f,%al
   eed4e:	72 02                	jb     0xeed52
   eed50:	2c 3f                	sub    $0x3f,%al
   eed52:	d7                   	xlat   %ds:(%bx)
   eed53:	8a d0                	mov    %al,%dl
   eed55:	eb 02                	jmp    0xeed59
   eed57:	b2 00                	mov    $0x0,%dl
   eed59:	8a c1                	mov    %cl,%al
   eed5b:	f6 26 3a 04          	mulb   0x43a
   eed5f:	a2 39 04             	mov    %al,0x439
   eed62:	ac                   	lods   %ds:(%si),%al
   eed63:	22 c0                	and    %al,%al
   eed65:	74 14                	je     0xeed7b
   eed67:	bb 7d 04             	mov    $0x47d,%bx
   eed6a:	d7                   	xlat   %ds:(%bx)
   eed6b:	02 06 39 04          	add    0x439,%al
   eed6f:	bb 3e 04             	mov    $0x43e,%bx
   eed72:	3c 3f                	cmp    $0x3f,%al
   eed74:	72 02                	jb     0xeed78
   eed76:	2c 3f                	sub    $0x3f,%al
   eed78:	d7                   	xlat   %ds:(%bx)
   eed79:	32 d0                	xor    %al,%dl
   eed7b:	49                   	dec    %cx
   eed7c:	7d db                	jge    0xeed59
   eed7e:	58                   	pop    %ax
   eed7f:	5e                   	pop    %si
   eed80:	c3                   	ret
   eed81:	53                   	push   %bx
   eed82:	bb 7d 04             	mov    $0x47d,%bx
   eed85:	d7                   	xlat   %ds:(%bx)
   eed86:	86 c4                	xchg   %al,%ah
   eed88:	d7                   	xlat   %ds:(%bx)
   eed89:	2a c4                	sub    %ah,%al
   eed8b:	73 02                	jae    0xeed8f
   eed8d:	04 3f                	add    $0x3f,%al
   eed8f:	5b                   	pop    %bx
   eed90:	c3                   	ret
   eed91:	53                   	push   %bx
   eed92:	22 c0                	and    %al,%al
   eed94:	74 19                	je     0xeedaf
   eed96:	22 e4                	and    %ah,%ah
   eed98:	74 15                	je     0xeedaf
   eed9a:	bb 7d 04             	mov    $0x47d,%bx
   eed9d:	d7                   	xlat   %ds:(%bx)
   eed9e:	86 e0                	xchg   %ah,%al
   eeda0:	d7                   	xlat   %ds:(%bx)
   eeda1:	02 c4                	add    %ah,%al
   eeda3:	bb 3e 04             	mov    $0x43e,%bx
   eeda6:	3c 3f                	cmp    $0x3f,%al
   eeda8:	72 02                	jb     0xeedac
   eedaa:	2c 3f                	sub    $0x3f,%al
   eedac:	d7                   	xlat   %ds:(%bx)
   eedad:	5b                   	pop    %bx
   eedae:	c3                   	ret
   eedaf:	b0 00                	mov    $0x0,%al
   eedb1:	5b                   	pop    %bx
   eedb2:	c3                   	ret
   eedb3:	50                   	push   %ax
   eedb4:	53                   	push   %bx
   eedb5:	55                   	push   %bp
   eedb6:	57                   	push   %di
   eedb7:	33 db                	xor    %bx,%bx
   eedb9:	8a 1e db 03          	mov    0x3db,%bl
   eedbd:	d1 e3                	shl    $1,%bx
   eedbf:	8b bf e0 03          	mov    0x3e0(%bx),%di
   eedc3:	80 3e 3d 04 00       	cmpb   $0x0,0x43d
   eedc8:	74 15                	je     0xeeddf
   eedca:	80 3e 3d 04 01       	cmpb   $0x1,0x43d
   eedcf:	74 17                	je     0xeede8
   eedd1:	80 3e 3d 04 02       	cmpb   $0x2,0x43d
   eedd6:	74 19                	je     0xeedf1
   eedd8:	80 3e 3d 04 03       	cmpb   $0x3,0x43d
   eeddd:	74 1b                	je     0xeedfa
   eeddf:	83 c7 01             	add    $0x1,%di
   eede2:	89 3e 3b 04          	mov    %di,0x43b
   eede6:	eb 1b                	jmp    0xeee03
   eede8:	83 c7 19             	add    $0x19,%di
   eedeb:	89 3e 3b 04          	mov    %di,0x43b
   eedef:	eb 12                	jmp    0xeee03
   eedf1:	83 c7 31             	add    $0x31,%di
   eedf4:	89 3e 3b 04          	mov    %di,0x43b
   eedf8:	eb 09                	jmp    0xeee03
   eedfa:	83 c7 49             	add    $0x49,%di
   eedfd:	89 3e 3b 04          	mov    %di,0x43b
   eee01:	eb 00                	jmp    0xeee03
   eee03:	86 e0                	xchg   %ah,%al
   eee05:	50                   	push   %ax
   eee06:	bb bd 04             	mov    $0x4bd,%bx
   eee09:	d7                   	xlat   %ds:(%bx)
   eee0a:	e8 d2 fb             	call   0xee9df
   eee0d:	b4 18                	mov    $0x18,%ah
   eee0f:	f6 e4                	mul    %ah
   eee11:	03 e8                	add    %ax,%bp
   eee13:	58                   	pop    %ax
   eee14:	50                   	push   %ax
   eee15:	b4 00                	mov    $0x0,%ah
   eee17:	bb d5 04             	mov    $0x4d5,%bx
   eee1a:	d7                   	xlat   %ds:(%bx)
   eee1b:	03 e8                	add    %ax,%bp
   eee1d:	03 2e 3b 04          	add    0x43b,%bp
   eee21:	58                   	pop    %ax
   eee22:	8a 46 00             	mov    0x0(%bp),%al
   eee25:	24 c0                	and    $0xc0,%al
   eee27:	0a e0                	or     %al,%ah
   eee29:	88 66 00             	mov    %ah,0x0(%bp)
   eee2c:	5f                   	pop    %di
   eee2d:	5d                   	pop    %bp
   eee2e:	5b                   	pop    %bx
   eee2f:	58                   	pop    %ax
   eee30:	90                   	nop
   eee31:	c3                   	ret
   eee32:	e8 5b 10             	call   0xefe90
   eee35:	3c 01                	cmp    $0x1,%al
   eee37:	74 03                	je     0xeee3c
   eee39:	e9 b4 16             	jmp    0xe04f0
   eee3c:	e8 e2 01             	call   0xef021
   eee3f:	3c 00                	cmp    $0x0,%al
   eee41:	74 03                	je     0xeee46
   eee43:	e9 d7 f2             	jmp    0xee11d
   eee46:	e8 94 1a             	call   0xe08dd
   eee49:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   eee4e:	8b 16 61 00          	mov    0x61,%dx
   eee52:	b0 40                	mov    $0x40,%al
   eee54:	ee                   	out    %al,(%dx)
   eee55:	eb 00                	jmp    0xeee57
   eee57:	e8 f2 1a             	call   0xe094c
   eee5a:	3c ff                	cmp    $0xff,%al
   eee5c:	75 05                	jne    0xeee63
   eee5e:	e8 82 ee             	call   0xedce3
   eee61:	eb 4c                	jmp    0xeeeaf
   eee63:	8a c3                	mov    %bl,%al
   eee65:	a8 40                	test   $0x40,%al
   eee67:	75 03                	jne    0xeee6c
   eee69:	e9 b1 f2             	jmp    0xee11d
   eee6c:	a8 20                	test   $0x20,%al
   eee6e:	74 0f                	je     0xeee7f
   eee70:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   eee75:	c6 06 01 05 01       	movb   $0x1,0x501
   eee7a:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   eee7f:	e8 21 05             	call   0xef3a3
   eee82:	3c ff                	cmp    $0xff,%al
   eee84:	75 0b                	jne    0xeee91
   eee86:	b0 00                	mov    $0x0,%al
   eee88:	a2 fe 00             	mov    %al,0xfe
   eee8b:	a2 ff 00             	mov    %al,0xff
   eee8e:	e9 8c f2             	jmp    0xee11d
   eee91:	3c 00                	cmp    $0x0,%al
   eee93:	74 02                	je     0xeee97
   eee95:	eb 18                	jmp    0xeeeaf
   eee97:	fc                   	cld
   eee98:	56                   	push   %si
   eee99:	be 97 00             	mov    $0x97,%si
   eee9c:	b9 0a 00             	mov    $0xa,%cx
   eee9f:	f3 a4                	rep movsb %ds:(%si),%es:(%di)
   eeea1:	5e                   	pop    %si
   eeea2:	a0 00 01             	mov    0x100,%al
   eeea5:	3c 00                	cmp    $0x0,%al
   eeea7:	74 03                	je     0xeeeac
   eeea9:	e9 f5 ec             	jmp    0xedba1
   eeeac:	e9 ed ec             	jmp    0xedb9c
   eeeaf:	a0 00 01             	mov    0x100,%al
   eeeb2:	3c 00                	cmp    $0x0,%al
   eeeb4:	74 06                	je     0xeeebc
   eeeb6:	b8 08 80             	mov    $0x8008,%ax
   eeeb9:	e9 ce eb             	jmp    0xeda8a
   eeebc:	b8 08 80             	mov    $0x8008,%ax
   eeebf:	e9 cb eb             	jmp    0xeda8d
   eeec2:	e8 cb 0f             	call   0xefe90
   eeec5:	3c 01                	cmp    $0x1,%al
   eeec7:	74 03                	je     0xeeecc
   eeec9:	e9 24 16             	jmp    0xe04f0
   eeecc:	e8 52 01             	call   0xef021
   eeecf:	3c 00                	cmp    $0x0,%al
   eeed1:	74 03                	je     0xeeed6
   eeed3:	e9 47 f2             	jmp    0xee11d
   eeed6:	e8 04 1a             	call   0xe08dd
   eeed9:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   eeede:	8b 16 61 00          	mov    0x61,%dx
   eeee2:	b0 40                	mov    $0x40,%al
   eeee4:	ee                   	out    %al,(%dx)
   eeee5:	eb 00                	jmp    0xeeee7
   eeee7:	e8 62 1a             	call   0xe094c
   eeeea:	3c ff                	cmp    $0xff,%al
   eeeec:	75 25                	jne    0xeef13
   eeeee:	fe 0e c8 03          	decb   0x3c8
   eeef2:	75 ea                	jne    0xeeede
   eeef4:	e8 ec ed             	call   0xedce3
   eeef7:	b0 00                	mov    $0x0,%al
   eeef9:	a2 fe 00             	mov    %al,0xfe
   eeefc:	a2 ff 00             	mov    %al,0xff
   eeeff:	c6 06 f8 00 01       	movb   $0x1,0xf8
   eef04:	c7 06 e1 00 00 00    	movw   $0x0,0xe1
   eef0a:	c7 06 e3 00 00 00    	movw   $0x0,0xe3
   eef10:	e9 0a f2             	jmp    0xee11d
   eef13:	8a c3                	mov    %bl,%al
   eef15:	a8 40                	test   $0x40,%al
   eef17:	75 03                	jne    0xeef1c
   eef19:	e9 01 f2             	jmp    0xee11d
   eef1c:	a8 20                	test   $0x20,%al
   eef1e:	74 0f                	je     0xeef2f
   eef20:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   eef25:	c6 06 01 05 01       	movb   $0x1,0x501
   eef2a:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   eef2f:	8a c3                	mov    %bl,%al
   eef31:	24 02                	and    $0x2,%al
   eef33:	3c 02                	cmp    $0x2,%al
   eef35:	74 07                	je     0xeef3e
   eef37:	c6 06 fe 00 00       	movb   $0x0,0xfe
   eef3c:	eb 0a                	jmp    0xeef48
   eef3e:	c6 06 fe 00 01       	movb   $0x1,0xfe
   eef43:	c6 06 ff 00 00       	movb   $0x0,0xff
   eef48:	80 3e fe 00 01       	cmpb   $0x1,0xfe
   eef4d:	74 1a                	je     0xeef69
   eef4f:	80 3e ff 00 01       	cmpb   $0x1,0xff
   eef54:	75 0a                	jne    0xeef60
   eef56:	b8 01 00             	mov    $0x1,%ax
   eef59:	c6 06 00 01 00       	movb   $0x0,0x100
   eef5e:	eb 44                	jmp    0xeefa4
   eef60:	33 c0                	xor    %ax,%ax
   eef62:	c6 06 00 01 00       	movb   $0x0,0x100
   eef67:	eb 3b                	jmp    0xeefa4
   eef69:	33 c0                	xor    %ax,%ax
   eef6b:	c6 06 00 01 01       	movb   $0x1,0x100
   eef70:	ab                   	stos   %ax,%es:(%di)
   eef71:	a0 6b 00             	mov    0x6b,%al
   eef74:	e8 5c 1a             	call   0xe09d3
   eef77:	aa                   	stos   %al,%es:(%di)
   eef78:	a0 6a 00             	mov    0x6a,%al
   eef7b:	e8 55 1a             	call   0xe09d3
   eef7e:	aa                   	stos   %al,%es:(%di)
   eef7f:	a0 69 00             	mov    0x69,%al
   eef82:	e8 4e 1a             	call   0xe09d3
   eef85:	aa                   	stos   %al,%es:(%di)
   eef86:	32 c0                	xor    %al,%al
   eef88:	aa                   	stos   %al,%es:(%di)
   eef89:	a0 6e 00             	mov    0x6e,%al
   eef8c:	e8 44 1a             	call   0xe09d3
   eef8f:	aa                   	stos   %al,%es:(%di)
   eef90:	a0 6d 00             	mov    0x6d,%al
   eef93:	e8 3d 1a             	call   0xe09d3
   eef96:	aa                   	stos   %al,%es:(%di)
   eef97:	a0 6c 00             	mov    0x6c,%al
   eef9a:	e8 36 1a             	call   0xe09d3
   eef9d:	aa                   	stos   %al,%es:(%di)
   eef9e:	32 c0                	xor    %al,%al
   eefa0:	aa                   	stos   %al,%es:(%di)
   eefa1:	e9 fd eb             	jmp    0xedba1
   eefa4:	ab                   	stos   %ax,%es:(%di)
   eefa5:	32 c0                	xor    %al,%al
   eefa7:	b9 08 00             	mov    $0x8,%cx
   eefaa:	f3 aa                	rep stos %al,%es:(%di)
   eefac:	e9 ed eb             	jmp    0xedb9c
   eefaf:	e9 c2 eb             	jmp    0xedb74
   eefb2:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   eefb7:	e8 61 18             	call   0xe081b
   eefba:	3c 01                	cmp    $0x1,%al
   eefbc:	75 01                	jne    0xeefbf
   eefbe:	c3                   	ret
   eefbf:	3c ff                	cmp    $0xff,%al
   eefc1:	75 0a                	jne    0xeefcd
   eefc3:	fe 0e c8 03          	decb   0x3c8
   eefc7:	75 ee                	jne    0xeefb7
   eefc9:	e8 17 ed             	call   0xedce3
   eefcc:	c3                   	ret
   eefcd:	3c 01                	cmp    $0x1,%al
   eefcf:	75 02                	jne    0xeefd3
   eefd1:	eb 4b                	jmp    0xef01e
   eefd3:	a0 7e 00             	mov    0x7e,%al
   eefd6:	e8 fa 19             	call   0xe09d3
   eefd9:	8a d0                	mov    %al,%dl
   eefdb:	a0 7f 00             	mov    0x7f,%al
   eefde:	e8 f2 19             	call   0xe09d3
   eefe1:	8a e8                	mov    %al,%ch
   eefe3:	a0 80 00             	mov    0x80,%al
   eefe6:	e8 ea 19             	call   0xe09d3
   eefe9:	8a e5                	mov    %ch,%ah
   eefeb:	e8 9d f8             	call   0xee88b
   eefee:	a3 a3 00             	mov    %ax,0xa3
   eeff1:	a3 84 00             	mov    %ax,0x84
   eeff4:	89 16 86 00          	mov    %dx,0x86
   eeff8:	89 16 a1 00          	mov    %dx,0xa1
   eeffc:	83 3e 86 00 00       	cmpw   $0x0,0x86
   ef001:	75 18                	jne    0xef01b
   ef003:	83 3e 84 00 00       	cmpw   $0x0,0x84
   ef008:	75 11                	jne    0xef01b
   ef00a:	fe 0e c8 03          	decb   0x3c8
   ef00e:	75 03                	jne    0xef013
   ef010:	b0 ff                	mov    $0xff,%al
   ef012:	c3                   	ret
   ef013:	b9 88 13             	mov    $0x1388,%cx
   ef016:	e8 dd 19             	call   0xe09f6
   ef019:	eb 9c                	jmp    0xeefb7
   ef01b:	32 c0                	xor    %al,%al
   ef01d:	c3                   	ret
   ef01e:	b0 01                	mov    $0x1,%al
   ef020:	c3                   	ret
   ef021:	bb 14 00             	mov    $0x14,%bx
   ef024:	8b 16 63 00          	mov    0x63,%dx
   ef028:	ec                   	in     (%dx),%al
   ef029:	24 0f                	and    $0xf,%al
   ef02b:	0c 0d                	or     $0xd,%al
   ef02d:	3c 0d                	cmp    $0xd,%al
   ef02f:	75 0b                	jne    0xef03c
   ef031:	b9 01 00             	mov    $0x1,%cx
   ef034:	e8 bf 19             	call   0xe09f6
   ef037:	4b                   	dec    %bx
   ef038:	75 ea                	jne    0xef024
   ef03a:	eb 22                	jmp    0xef05e
   ef03c:	bb 32 00             	mov    $0x32,%bx
   ef03f:	80 3e 08 05 01       	cmpb   $0x1,0x508
   ef044:	74 71                	je     0xef0b7
   ef046:	8b 16 63 00          	mov    0x63,%dx
   ef04a:	ec                   	in     (%dx),%al
   ef04b:	24 0f                	and    $0xf,%al
   ef04d:	0c 0d                	or     $0xd,%al
   ef04f:	3c 0d                	cmp    $0xd,%al
   ef051:	74 0b                	je     0xef05e
   ef053:	b9 01 00             	mov    $0x1,%cx
   ef056:	e8 9d 19             	call   0xe09f6
   ef059:	4b                   	dec    %bx
   ef05a:	75 ee                	jne    0xef04a
   ef05c:	eb 59                	jmp    0xef0b7
   ef05e:	bb 3c 00             	mov    $0x3c,%bx
   ef061:	8b 16 63 00          	mov    0x63,%dx
   ef065:	ec                   	in     (%dx),%al
   ef066:	24 0f                	and    $0xf,%al
   ef068:	0c 0d                	or     $0xd,%al
   ef06a:	3c 0d                	cmp    $0xd,%al
   ef06c:	75 0b                	jne    0xef079
   ef06e:	b9 01 00             	mov    $0x1,%cx
   ef071:	e8 82 19             	call   0xe09f6
   ef074:	4b                   	dec    %bx
   ef075:	75 ee                	jne    0xef065
   ef077:	eb 3b                	jmp    0xef0b4
   ef079:	bb 32 00             	mov    $0x32,%bx
   ef07c:	80 3e 08 05 01       	cmpb   $0x1,0x508
   ef081:	74 34                	je     0xef0b7
   ef083:	8b 16 63 00          	mov    0x63,%dx
   ef087:	ec                   	in     (%dx),%al
   ef088:	24 0f                	and    $0xf,%al
   ef08a:	0c 0d                	or     $0xd,%al
   ef08c:	3c 0d                	cmp    $0xd,%al
   ef08e:	74 0b                	je     0xef09b
   ef090:	b9 01 00             	mov    $0x1,%cx
   ef093:	e8 60 19             	call   0xe09f6
   ef096:	4b                   	dec    %bx
   ef097:	75 ee                	jne    0xef087
   ef099:	eb 1c                	jmp    0xef0b7
   ef09b:	bb 3c 00             	mov    $0x3c,%bx
   ef09e:	8b 16 63 00          	mov    0x63,%dx
   ef0a2:	ec                   	in     (%dx),%al
   ef0a3:	24 0f                	and    $0xf,%al
   ef0a5:	0c 0d                	or     $0xd,%al
   ef0a7:	3c 0d                	cmp    $0xd,%al
   ef0a9:	75 0c                	jne    0xef0b7
   ef0ab:	b9 01 00             	mov    $0x1,%cx
   ef0ae:	e8 45 19             	call   0xe09f6
   ef0b1:	4b                   	dec    %bx
   ef0b2:	75 ee                	jne    0xef0a2
   ef0b4:	b0 01                	mov    $0x1,%al
   ef0b6:	c3                   	ret
   ef0b7:	32 c0                	xor    %al,%al
   ef0b9:	c3                   	ret
   ef0ba:	e8 20 ea             	call   0xedadd
   ef0bd:	3c ff                	cmp    $0xff,%al
   ef0bf:	75 01                	jne    0xef0c2
   ef0c1:	c3                   	ret
   ef0c2:	3c 04                	cmp    $0x4,%al
   ef0c4:	75 11                	jne    0xef0d7
   ef0c6:	e8 38 05             	call   0xef601
   ef0c9:	3c ff                	cmp    $0xff,%al
   ef0cb:	75 01                	jne    0xef0ce
   ef0cd:	c3                   	ret
   ef0ce:	a0 06 01             	mov    0x106,%al
   ef0d1:	a8 40                	test   $0x40,%al
   ef0d3:	75 0c                	jne    0xef0e1
   ef0d5:	b0 ff                	mov    $0xff,%al
   ef0d7:	a0 06 01             	mov    0x106,%al
   ef0da:	a8 80                	test   $0x80,%al
   ef0dc:	74 03                	je     0xef0e1
   ef0de:	b0 ff                	mov    $0xff,%al
   ef0e0:	c3                   	ret
   ef0e1:	e8 f9 17             	call   0xe08dd
   ef0e4:	e8 cb fe             	call   0xeefb2
   ef0e7:	3c ff                	cmp    $0xff,%al
   ef0e9:	75 01                	jne    0xef0ec
   ef0eb:	c3                   	ret
   ef0ec:	3c 01                	cmp    $0x1,%al
   ef0ee:	75 01                	jne    0xef0f1
   ef0f0:	c3                   	ret
   ef0f1:	e8 cf 01             	call   0xef2c3
   ef0f4:	e8 e6 17             	call   0xe08dd
   ef0f7:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef0fc:	8b 16 61 00          	mov    0x61,%dx
   ef100:	b0 70                	mov    $0x70,%al
   ef102:	ee                   	out    %al,(%dx)
   ef103:	eb 00                	jmp    0xef105
   ef105:	e8 44 18             	call   0xe094c
   ef108:	3c ff                	cmp    $0xff,%al
   ef10a:	75 0f                	jne    0xef11b
   ef10c:	fe 0e c8 03          	decb   0x3c8
   ef110:	80 3e c8 03 01       	cmpb   $0x1,0x3c8
   ef115:	75 e5                	jne    0xef0fc
   ef117:	e8 c9 eb             	call   0xedce3
   ef11a:	c3                   	ret
   ef11b:	e8 bf 17             	call   0xe08dd
   ef11e:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef123:	8b 16 61 00          	mov    0x61,%dx
   ef127:	b0 50                	mov    $0x50,%al
   ef129:	9c                   	pushf
   ef12a:	fa                   	cli
   ef12b:	ee                   	out    %al,(%dx)
   ef12c:	b0 05                	mov    $0x5,%al
   ef12e:	ee                   	out    %al,(%dx)
   ef12f:	9d                   	popf
   ef130:	e8 19 18             	call   0xe094c
   ef133:	3c ff                	cmp    $0xff,%al
   ef135:	75 0a                	jne    0xef141
   ef137:	fe 0e c8 03          	decb   0x3c8
   ef13b:	75 e6                	jne    0xef123
   ef13d:	e8 a3 eb             	call   0xedce3
   ef140:	c3                   	ret
   ef141:	c7 06 fc 00 d0 07    	movw   $0x7d0,0xfc
   ef147:	b9 01 00             	mov    $0x1,%cx
   ef14a:	e8 a9 18             	call   0xe09f6
   ef14d:	8b 0e fc 00          	mov    0xfc,%cx
   ef151:	49                   	dec    %cx
   ef152:	89 0e fc 00          	mov    %cx,0xfc
   ef156:	75 03                	jne    0xef15b
   ef158:	b0 ff                	mov    $0xff,%al
   ef15a:	c3                   	ret
   ef15b:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef160:	e8 09 16             	call   0xe076c
   ef163:	3c ff                	cmp    $0xff,%al
   ef165:	75 0a                	jne    0xef171
   ef167:	fe 0e c8 03          	decb   0x3c8
   ef16b:	75 f3                	jne    0xef160
   ef16d:	e8 73 eb             	call   0xedce3
   ef170:	c3                   	ret
   ef171:	3c 01                	cmp    $0x1,%al
   ef173:	75 02                	jne    0xef177
   ef175:	eb 3d                	jmp    0xef1b4
   ef177:	a0 98 00             	mov    0x98,%al
   ef17a:	3c 00                	cmp    $0x0,%al
   ef17c:	75 c9                	jne    0xef147
   ef17e:	a0 99 00             	mov    0x99,%al
   ef181:	3c a0                	cmp    $0xa0,%al
   ef183:	74 c2                	je     0xef147
   ef185:	3c a1                	cmp    $0xa1,%al
   ef187:	74 be                	je     0xef147
   ef189:	3c a2                	cmp    $0xa2,%al
   ef18b:	74 ba                	je     0xef147
   ef18d:	e8 d5 00             	call   0xef265
   ef190:	e8 5e 00             	call   0xef1f1
   ef193:	33 f6                	xor    %si,%si
   ef195:	8a 84 9a 03          	mov    0x39a(%si),%al
   ef199:	b9 0c 00             	mov    $0xc,%cx
   ef19c:	46                   	inc    %si
   ef19d:	22 84 9a 03          	and    0x39a(%si),%al
   ef1a1:	e2 f9                	loop   0xef19c
   ef1a3:	3c ff                	cmp    $0xff,%al
   ef1a5:	74 02                	je     0xef1a9
   ef1a7:	eb 9e                	jmp    0xef147
   ef1a9:	e8 1f 00             	call   0xef1cb
   ef1ac:	3c ff                	cmp    $0xff,%al
   ef1ae:	75 01                	jne    0xef1b1
   ef1b0:	c3                   	ret
   ef1b1:	32 c0                	xor    %al,%al
   ef1b3:	c3                   	ret
   ef1b4:	b9 0d 00             	mov    $0xd,%cx
   ef1b7:	33 f6                	xor    %si,%si
   ef1b9:	80 a4 9a 03 00       	andb   $0x0,0x39a(%si)
   ef1be:	46                   	inc    %si
   ef1bf:	e2 f6                	loop   0xef1b7
   ef1c1:	e8 07 00             	call   0xef1cb
   ef1c4:	3c ff                	cmp    $0xff,%al
   ef1c6:	74 02                	je     0xef1ca
   ef1c8:	b0 01                	mov    $0x1,%al
   ef1ca:	c3                   	ret
   ef1cb:	e8 0f 17             	call   0xe08dd
   ef1ce:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef1d3:	8b 16 61 00          	mov    0x61,%dx
   ef1d7:	b0 50                	mov    $0x50,%al
   ef1d9:	9c                   	pushf
   ef1da:	fa                   	cli
   ef1db:	ee                   	out    %al,(%dx)
   ef1dc:	b0 01                	mov    $0x1,%al
   ef1de:	ee                   	out    %al,(%dx)
   ef1df:	9d                   	popf
   ef1e0:	e8 69 17             	call   0xe094c
   ef1e3:	3c ff                	cmp    $0xff,%al
   ef1e5:	75 09                	jne    0xef1f0
   ef1e7:	fe 0e c8 03          	decb   0x3c8
   ef1eb:	75 e6                	jne    0xef1d3
   ef1ed:	e8 f3 ea             	call   0xedce3
   ef1f0:	c3                   	ret
   ef1f1:	b8 07 02             	mov    $0x207,%ax
   ef1f4:	a3 98 03             	mov    %ax,0x398
   ef1f7:	33 db                	xor    %bx,%bx
   ef1f9:	a0 99 00             	mov    0x99,%al
   ef1fc:	e8 d4 17             	call   0xe09d3
   ef1ff:	8a d8                	mov    %al,%bl
   ef201:	a0 97 00             	mov    0x97,%al
   ef204:	88 87 33 03          	mov    %al,0x333(%bx)
   ef208:	a0 99 00             	mov    0x99,%al
   ef20b:	24 0f                	and    $0xf,%al
   ef20d:	8a d8                	mov    %al,%bl
   ef20f:	74 0d                	je     0xef21e
   ef211:	a1 98 03             	mov    0x398,%ax
   ef214:	05 03 00             	add    $0x3,%ax
   ef217:	a3 98 03             	mov    %ax,0x398
   ef21a:	fe cb                	dec    %bl
   ef21c:	75 f6                	jne    0xef214
   ef21e:	a0 99 00             	mov    0x99,%al
   ef221:	24 f0                	and    $0xf0,%al
   ef223:	3c 00                	cmp    $0x0,%al
   ef225:	74 1f                	je     0xef246
   ef227:	d0 e8                	shr    $1,%al
   ef229:	d0 e8                	shr    $1,%al
   ef22b:	d0 e8                	shr    $1,%al
   ef22d:	d0 e8                	shr    $1,%al
   ef22f:	24 0f                	and    $0xf,%al
   ef231:	8a c8                	mov    %al,%cl
   ef233:	a1 98 03             	mov    0x398,%ax
   ef236:	b3 0a                	mov    $0xa,%bl
   ef238:	05 03 00             	add    $0x3,%ax
   ef23b:	a3 98 03             	mov    %ax,0x398
   ef23e:	fe cb                	dec    %bl
   ef240:	75 f6                	jne    0xef238
   ef242:	fe c9                	dec    %cl
   ef244:	75 f0                	jne    0xef236
   ef246:	8b 1e 98 03          	mov    0x398,%bx
   ef24a:	b9 07 02             	mov    $0x207,%cx
   ef24d:	2b d9                	sub    %cx,%bx
   ef24f:	a0 9e 00             	mov    0x9e,%al
   ef252:	88 87 07 02          	mov    %al,0x207(%bx)
   ef256:	a0 9f 00             	mov    0x9f,%al
   ef259:	88 87 08 02          	mov    %al,0x208(%bx)
   ef25d:	a0 a0 00             	mov    0xa0,%al
   ef260:	88 87 09 02          	mov    %al,0x209(%bx)
   ef264:	c3                   	ret
   ef265:	b8 9a 03             	mov    $0x39a,%ax
   ef268:	a3 98 03             	mov    %ax,0x398
   ef26b:	a0 99 00             	mov    0x99,%al
   ef26e:	e8 62 17             	call   0xe09d3
   ef271:	b1 08                	mov    $0x8,%cl
   ef273:	f6 f1                	div    %cl
   ef275:	8a c8                	mov    %al,%cl
   ef277:	8a dc                	mov    %ah,%bl
   ef279:	a1 98 03             	mov    0x398,%ax
   ef27c:	32 ed                	xor    %ch,%ch
   ef27e:	03 c1                	add    %cx,%ax
   ef280:	a3 98 03             	mov    %ax,0x398
   ef283:	80 fb 00             	cmp    $0x0,%bl
   ef286:	74 21                	je     0xef2a9
   ef288:	b1 01                	mov    $0x1,%cl
   ef28a:	fe cb                	dec    %bl
   ef28c:	74 04                	je     0xef292
   ef28e:	d0 e1                	shl    $1,%cl
   ef290:	eb f8                	jmp    0xef28a
   ef292:	8b 1e 98 03          	mov    0x398,%bx
   ef296:	ba 9a 03             	mov    $0x39a,%dx
   ef299:	2b da                	sub    %dx,%bx
   ef29b:	8b f3                	mov    %bx,%si
   ef29d:	8a 84 9a 03          	mov    0x39a(%si),%al
   ef2a1:	0a c1                	or     %cl,%al
   ef2a3:	88 84 9a 03          	mov    %al,0x39a(%si)
   ef2a7:	eb 19                	jmp    0xef2c2
   ef2a9:	ff 0e 98 03          	decw   0x398
   ef2ad:	8b 1e 98 03          	mov    0x398,%bx
   ef2b1:	ba 9a 03             	mov    $0x39a,%dx
   ef2b4:	2b da                	sub    %dx,%bx
   ef2b6:	8b f3                	mov    %bx,%si
   ef2b8:	8a 84 9a 03          	mov    0x39a(%si),%al
   ef2bc:	0c 80                	or     $0x80,%al
   ef2be:	88 84 9a 03          	mov    %al,0x39a(%si)
   ef2c2:	c3                   	ret
   ef2c3:	b8 9a 03             	mov    $0x39a,%ax
   ef2c6:	a3 98 03             	mov    %ax,0x398
   ef2c9:	a0 7c 00             	mov    0x7c,%al
   ef2cc:	e8 04 17             	call   0xe09d3
   ef2cf:	e8 bc 00             	call   0xef38e
   ef2d2:	80 ff 00             	cmp    $0x0,%bh
   ef2d5:	74 3f                	je     0xef316
   ef2d7:	32 c9                	xor    %cl,%cl
   ef2d9:	fe cf                	dec    %bh
   ef2db:	74 07                	je     0xef2e4
   ef2dd:	d0 e1                	shl    $1,%cl
   ef2df:	80 c1 01             	add    $0x1,%cl
   ef2e2:	eb f5                	jmp    0xef2d9
   ef2e4:	a1 98 03             	mov    0x398,%ax
   ef2e7:	ba 9a 03             	mov    $0x39a,%dx
   ef2ea:	2b c2                	sub    %dx,%ax
   ef2ec:	8b f0                	mov    %ax,%si
   ef2ee:	8a 84 9a 03          	mov    0x39a(%si),%al
   ef2f2:	0a c1                	or     %cl,%al
   ef2f4:	88 84 9a 03          	mov    %al,0x39a(%si)
   ef2f8:	80 fb 00             	cmp    $0x0,%bl
   ef2fb:	74 30                	je     0xef32d
   ef2fd:	ff 0e 98 03          	decw   0x398
   ef301:	a1 98 03             	mov    0x398,%ax
   ef304:	ba 9a 03             	mov    $0x39a,%dx
   ef307:	2b c2                	sub    %dx,%ax
   ef309:	8b f0                	mov    %ax,%si
   ef30b:	c6 84 9a 03 ff       	movb   $0xff,0x39a(%si)
   ef310:	fe cb                	dec    %bl
   ef312:	75 e9                	jne    0xef2fd
   ef314:	eb 17                	jmp    0xef32d
   ef316:	ff 0e 98 03          	decw   0x398
   ef31a:	fe cb                	dec    %bl
   ef31c:	a1 98 03             	mov    0x398,%ax
   ef31f:	ba 9a 03             	mov    $0x39a,%dx
   ef322:	2b c2                	sub    %dx,%ax
   ef324:	8b f0                	mov    %ax,%si
   ef326:	c6 84 9a 03 7f       	movb   $0x7f,0x39a(%si)
   ef32b:	eb cb                	jmp    0xef2f8
   ef32d:	b8 9a 03             	mov    $0x39a,%ax
   ef330:	a3 98 03             	mov    %ax,0x398
   ef333:	a0 7d 00             	mov    0x7d,%al
   ef336:	e8 9a 16             	call   0xe09d3
   ef339:	e8 52 00             	call   0xef38e
   ef33c:	80 ff 00             	cmp    $0x0,%bh
   ef33f:	74 3b                	je     0xef37c
   ef341:	b1 ff                	mov    $0xff,%cl
   ef343:	d0 e1                	shl    $1,%cl
   ef345:	80 e1 fe             	and    $0xfe,%cl
   ef348:	fe cf                	dec    %bh
   ef34a:	75 f7                	jne    0xef343
   ef34c:	a1 98 03             	mov    0x398,%ax
   ef34f:	ba 9a 03             	mov    $0x39a,%dx
   ef352:	2b c2                	sub    %dx,%ax
   ef354:	8b f0                	mov    %ax,%si
   ef356:	8a 84 9a 03          	mov    0x39a(%si),%al
   ef35a:	0a c1                	or     %cl,%al
   ef35c:	88 84 9a 03          	mov    %al,0x39a(%si)
   ef360:	80 fb 0c             	cmp    $0xc,%bl
   ef363:	74 28                	je     0xef38d
   ef365:	ff 06 98 03          	incw   0x398
   ef369:	a1 98 03             	mov    0x398,%ax
   ef36c:	ba 9a 03             	mov    $0x39a,%dx
   ef36f:	2b c2                	sub    %dx,%ax
   ef371:	8b f0                	mov    %ax,%si
   ef373:	c6 84 9a 03 ff       	movb   $0xff,0x39a(%si)
   ef378:	fe c3                	inc    %bl
   ef37a:	eb e4                	jmp    0xef360
   ef37c:	a1 98 03             	mov    0x398,%ax
   ef37f:	ba 9a 03             	mov    $0x39a,%dx
   ef382:	2b c2                	sub    %dx,%ax
   ef384:	8b f0                	mov    %ax,%si
   ef386:	c6 84 9a 03 ff       	movb   $0xff,0x39a(%si)
   ef38b:	eb d3                	jmp    0xef360
   ef38d:	c3                   	ret
   ef38e:	b1 08                	mov    $0x8,%cl
   ef390:	f6 f1                	div    %cl
   ef392:	8a d8                	mov    %al,%bl
   ef394:	8a fc                	mov    %ah,%bh
   ef396:	a1 98 03             	mov    0x398,%ax
   ef399:	8a d3                	mov    %bl,%dl
   ef39b:	32 f6                	xor    %dh,%dh
   ef39d:	03 c2                	add    %dx,%ax
   ef39f:	a3 98 03             	mov    %ax,0x398
   ef3a2:	c3                   	ret
   ef3a3:	c6 06 00 01 00       	movb   $0x0,0x100
   ef3a8:	e8 32 15             	call   0xe08dd
   ef3ab:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef3b0:	8b 16 61 00          	mov    0x61,%dx
   ef3b4:	b0 40                	mov    $0x40,%al
   ef3b6:	ee                   	out    %al,(%dx)
   ef3b7:	eb 00                	jmp    0xef3b9
   ef3b9:	e8 90 15             	call   0xe094c
   ef3bc:	3c ff                	cmp    $0xff,%al
   ef3be:	75 0a                	jne    0xef3ca
   ef3c0:	fe 0e c8 03          	decb   0x3c8
   ef3c4:	75 ea                	jne    0xef3b0
   ef3c6:	e8 1a e9             	call   0xedce3
   ef3c9:	c3                   	ret
   ef3ca:	f6 c3 02             	test   $0x2,%bl
   ef3cd:	74 08                	je     0xef3d7
   ef3cf:	c6 06 00 01 01       	movb   $0x1,0x100
   ef3d4:	eb 66                	jmp    0xef43c
   ef3d6:	90                   	nop
   ef3d7:	c6 06 00 01 00       	movb   $0x0,0x100
   ef3dc:	e8 fe 14             	call   0xe08dd
   ef3df:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef3e4:	8b 16 61 00          	mov    0x61,%dx
   ef3e8:	b0 50                	mov    $0x50,%al
   ef3ea:	9c                   	pushf
   ef3eb:	fa                   	cli
   ef3ec:	ee                   	out    %al,(%dx)
   ef3ed:	32 c0                	xor    %al,%al
   ef3ef:	ee                   	out    %al,(%dx)
   ef3f0:	9d                   	popf
   ef3f1:	e8 58 15             	call   0xe094c
   ef3f4:	3c ff                	cmp    $0xff,%al
   ef3f6:	75 0a                	jne    0xef402
   ef3f8:	fe 0e c8 03          	decb   0x3c8
   ef3fc:	75 e6                	jne    0xef3e4
   ef3fe:	e8 e2 e8             	call   0xedce3
   ef401:	c3                   	ret
   ef402:	c6 06 69 00 00       	movb   $0x0,0x69
   ef407:	c6 06 6a 00 01       	movb   $0x1,0x6a
   ef40c:	c6 06 6b 00 60       	movb   $0x60,0x6b
   ef411:	c6 06 6c 00 00       	movb   $0x0,0x6c
   ef416:	c6 06 6d 00 06       	movb   $0x6,0x6d
   ef41b:	c6 06 6e 00 00       	movb   $0x0,0x6e
   ef420:	e8 ba 14             	call   0xe08dd
   ef423:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef428:	e8 80 14             	call   0xe08ab
   ef42b:	e8 f4 14             	call   0xe0922
   ef42e:	3c ff                	cmp    $0xff,%al
   ef430:	75 0a                	jne    0xef43c
   ef432:	fe 0e c8 03          	decb   0x3c8
   ef436:	75 f0                	jne    0xef428
   ef438:	e8 a8 e8             	call   0xedce3
   ef43b:	c3                   	ret
   ef43c:	e8 9e 14             	call   0xe08dd
   ef43f:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef444:	8b 16 61 00          	mov    0x61,%dx
   ef448:	b0 90                	mov    $0x90,%al
   ef44a:	9c                   	pushf
   ef44b:	fa                   	cli
   ef44c:	ee                   	out    %al,(%dx)
   ef44d:	8b 16 61 00          	mov    0x61,%dx
   ef451:	b0 04                	mov    $0x4,%al
   ef453:	ee                   	out    %al,(%dx)
   ef454:	eb 00                	jmp    0xef456
   ef456:	8b 16 61 00          	mov    0x61,%dx
   ef45a:	b0 01                	mov    $0x1,%al
   ef45c:	ee                   	out    %al,(%dx)
   ef45d:	9d                   	popf
   ef45e:	e8 eb 14             	call   0xe094c
   ef461:	3c ff                	cmp    $0xff,%al
   ef463:	75 0a                	jne    0xef46f
   ef465:	fe 0e c8 03          	decb   0x3c8
   ef469:	75 d9                	jne    0xef444
   ef46b:	e8 75 e8             	call   0xedce3
   ef46e:	c3                   	ret
   ef46f:	c7 06 fc 00 d0 07    	movw   $0x7d0,0xfc
   ef475:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef47a:	e8 ef 12             	call   0xe076c
   ef47d:	3c ff                	cmp    $0xff,%al
   ef47f:	75 0c                	jne    0xef48d
   ef481:	fe 0e c8 03          	decb   0x3c8
   ef485:	75 f3                	jne    0xef47a
   ef487:	e8 59 e8             	call   0xedce3
   ef48a:	e9 cd 00             	jmp    0xef55a
   ef48d:	3c 01                	cmp    $0x1,%al
   ef48f:	75 03                	jne    0xef494
   ef491:	e9 c6 00             	jmp    0xef55a
   ef494:	a0 97 00             	mov    0x97,%al
   ef497:	a8 02                	test   $0x2,%al
   ef499:	75 14                	jne    0xef4af
   ef49b:	b9 01 00             	mov    $0x1,%cx
   ef49e:	e8 55 15             	call   0xe09f6
   ef4a1:	8b 0e fc 00          	mov    0xfc,%cx
   ef4a5:	49                   	dec    %cx
   ef4a6:	89 0e fc 00          	mov    %cx,0xfc
   ef4aa:	75 c9                	jne    0xef475
   ef4ac:	e9 ab 00             	jmp    0xef55a
   ef4af:	80 3e 00 01 00       	cmpb   $0x0,0x100
   ef4b4:	74 02                	je     0xef4b8
   ef4b6:	eb 48                	jmp    0xef500
   ef4b8:	e8 22 14             	call   0xe08dd
   ef4bb:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef4c0:	8b 16 61 00          	mov    0x61,%dx
   ef4c4:	b0 70                	mov    $0x70,%al
   ef4c6:	ee                   	out    %al,(%dx)
   ef4c7:	eb 00                	jmp    0xef4c9
   ef4c9:	e8 80 14             	call   0xe094c
   ef4cc:	3c ff                	cmp    $0xff,%al
   ef4ce:	75 0a                	jne    0xef4da
   ef4d0:	fe 0e c8 03          	decb   0x3c8
   ef4d4:	75 ea                	jne    0xef4c0
   ef4d6:	e8 0a e8             	call   0xedce3
   ef4d9:	c3                   	ret
   ef4da:	e8 00 14             	call   0xe08dd
   ef4dd:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef4e2:	8b 16 61 00          	mov    0x61,%dx
   ef4e6:	b0 50                	mov    $0x50,%al
   ef4e8:	9c                   	pushf
   ef4e9:	fa                   	cli
   ef4ea:	ee                   	out    %al,(%dx)
   ef4eb:	b0 01                	mov    $0x1,%al
   ef4ed:	ee                   	out    %al,(%dx)
   ef4ee:	9d                   	popf
   ef4ef:	e8 5a 14             	call   0xe094c
   ef4f2:	3c ff                	cmp    $0xff,%al
   ef4f4:	75 0a                	jne    0xef500
   ef4f6:	fe 0e c8 03          	decb   0x3c8
   ef4fa:	75 e6                	jne    0xef4e2
   ef4fc:	e8 e4 e7             	call   0xedce3
   ef4ff:	c3                   	ret
   ef500:	e8 da 13             	call   0xe08dd
   ef503:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef508:	8b 16 61 00          	mov    0x61,%dx
   ef50c:	b0 90                	mov    $0x90,%al
   ef50e:	9c                   	pushf
   ef50f:	fa                   	cli
   ef510:	ee                   	out    %al,(%dx)
   ef511:	8b 16 61 00          	mov    0x61,%dx
   ef515:	b0 04                	mov    $0x4,%al
   ef517:	ee                   	out    %al,(%dx)
   ef518:	eb 00                	jmp    0xef51a
   ef51a:	8b 16 61 00          	mov    0x61,%dx
   ef51e:	32 c0                	xor    %al,%al
   ef520:	ee                   	out    %al,(%dx)
   ef521:	9d                   	popf
   ef522:	e8 27 14             	call   0xe094c
   ef525:	3c ff                	cmp    $0xff,%al
   ef527:	75 0a                	jne    0xef533
   ef529:	fe 0e c8 03          	decb   0x3c8
   ef52d:	75 d9                	jne    0xef508
   ef52f:	e8 b1 e7             	call   0xedce3
   ef532:	c3                   	ret
   ef533:	a0 98 00             	mov    0x98,%al
   ef536:	0a 06 99 00          	or     0x99,%al
   ef53a:	0a 06 9a 00          	or     0x9a,%al
   ef53e:	0a 06 9b 00          	or     0x9b,%al
   ef542:	0a 06 9c 00          	or     0x9c,%al
   ef546:	0a 06 9d 00          	or     0x9d,%al
   ef54a:	0a 06 9e 00          	or     0x9e,%al
   ef54e:	0a 06 9f 00          	or     0x9f,%al
   ef552:	75 03                	jne    0xef557
   ef554:	e9 a7 00             	jmp    0xef5fe
   ef557:	32 c0                	xor    %al,%al
   ef559:	c3                   	ret
   ef55a:	80 3e 00 01 00       	cmpb   $0x0,0x100
   ef55f:	74 02                	je     0xef563
   ef561:	eb 48                	jmp    0xef5ab
   ef563:	e8 77 13             	call   0xe08dd
   ef566:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef56b:	8b 16 61 00          	mov    0x61,%dx
   ef56f:	b0 70                	mov    $0x70,%al
   ef571:	ee                   	out    %al,(%dx)
   ef572:	eb 00                	jmp    0xef574
   ef574:	e8 d5 13             	call   0xe094c
   ef577:	3c ff                	cmp    $0xff,%al
   ef579:	75 0a                	jne    0xef585
   ef57b:	fe 0e c8 03          	decb   0x3c8
   ef57f:	75 ea                	jne    0xef56b
   ef581:	e8 5f e7             	call   0xedce3
   ef584:	c3                   	ret
   ef585:	e8 55 13             	call   0xe08dd
   ef588:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef58d:	8b 16 61 00          	mov    0x61,%dx
   ef591:	b0 50                	mov    $0x50,%al
   ef593:	9c                   	pushf
   ef594:	fa                   	cli
   ef595:	ee                   	out    %al,(%dx)
   ef596:	b0 01                	mov    $0x1,%al
   ef598:	ee                   	out    %al,(%dx)
   ef599:	9d                   	popf
   ef59a:	e8 af 13             	call   0xe094c
   ef59d:	3c ff                	cmp    $0xff,%al
   ef59f:	75 0a                	jne    0xef5ab
   ef5a1:	fe 0e c8 03          	decb   0x3c8
   ef5a5:	75 e6                	jne    0xef58d
   ef5a7:	e8 39 e7             	call   0xedce3
   ef5aa:	c3                   	ret
   ef5ab:	e8 2f 13             	call   0xe08dd
   ef5ae:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef5b3:	8b 16 61 00          	mov    0x61,%dx
   ef5b7:	b0 90                	mov    $0x90,%al
   ef5b9:	9c                   	pushf
   ef5ba:	fa                   	cli
   ef5bb:	ee                   	out    %al,(%dx)
   ef5bc:	8b 16 61 00          	mov    0x61,%dx
   ef5c0:	b0 04                	mov    $0x4,%al
   ef5c2:	ee                   	out    %al,(%dx)
   ef5c3:	eb 00                	jmp    0xef5c5
   ef5c5:	8b 16 61 00          	mov    0x61,%dx
   ef5c9:	32 c0                	xor    %al,%al
   ef5cb:	ee                   	out    %al,(%dx)
   ef5cc:	9d                   	popf
   ef5cd:	e8 7c 13             	call   0xe094c
   ef5d0:	3c ff                	cmp    $0xff,%al
   ef5d2:	75 0a                	jne    0xef5de
   ef5d4:	fe 0e c8 03          	decb   0x3c8
   ef5d8:	75 d9                	jne    0xef5b3
   ef5da:	e8 06 e7             	call   0xedce3
   ef5dd:	c3                   	ret
   ef5de:	32 c0                	xor    %al,%al
   ef5e0:	a2 97 00             	mov    %al,0x97
   ef5e3:	a2 98 00             	mov    %al,0x98
   ef5e6:	a2 99 00             	mov    %al,0x99
   ef5e9:	a2 9a 00             	mov    %al,0x9a
   ef5ec:	a2 9b 00             	mov    %al,0x9b
   ef5ef:	a2 9c 00             	mov    %al,0x9c
   ef5f2:	a2 9d 00             	mov    %al,0x9d
   ef5f5:	a2 9e 00             	mov    %al,0x9e
   ef5f8:	a2 9f 00             	mov    %al,0x9f
   ef5fb:	a2 a0 00             	mov    %al,0xa0
   ef5fe:	b0 01                	mov    $0x1,%al
   ef600:	c3                   	ret
   ef601:	32 e4                	xor    %ah,%ah
   ef603:	e8 1b fa             	call   0xef021
   ef606:	3c 00                	cmp    $0x0,%al
   ef608:	75 21                	jne    0xef62b
   ef60a:	e8 d0 12             	call   0xe08dd
   ef60d:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef612:	8b 16 61 00          	mov    0x61,%dx
   ef616:	b0 40                	mov    $0x40,%al
   ef618:	ee                   	out    %al,(%dx)
   ef619:	eb 00                	jmp    0xef61b
   ef61b:	e8 2e 13             	call   0xe094c
   ef61e:	3c ff                	cmp    $0xff,%al
   ef620:	75 0c                	jne    0xef62e
   ef622:	fe 0e c8 03          	decb   0x3c8
   ef626:	75 ea                	jne    0xef612
   ef628:	e8 b8 e6             	call   0xedce3
   ef62b:	b0 ff                	mov    $0xff,%al
   ef62d:	c3                   	ret
   ef62e:	8a c3                	mov    %bl,%al
   ef630:	a8 40                	test   $0x40,%al
   ef632:	75 04                	jne    0xef638
   ef634:	b8 02 00             	mov    $0x2,%ax
   ef637:	c3                   	ret
   ef638:	a8 20                	test   $0x20,%al
   ef63a:	74 0f                	je     0xef64b
   ef63c:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ef641:	c6 06 01 05 01       	movb   $0x1,0x501
   ef646:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ef64b:	a8 02                	test   $0x2,%al
   ef64d:	74 04                	je     0xef653
   ef64f:	b8 01 00             	mov    $0x1,%ax
   ef652:	c3                   	ret
   ef653:	33 c0                	xor    %ax,%ax
   ef655:	c3                   	ret
   ef656:	c6 06 00 05 00       	movb   $0x0,0x500
   ef65b:	e8 32 08             	call   0xefe90
   ef65e:	3c 01                	cmp    $0x1,%al
   ef660:	74 03                	je     0xef665
   ef662:	e9 73 05             	jmp    0xefbd8
   ef665:	80 3e f4 04 00       	cmpb   $0x0,0x4f4
   ef66a:	74 18                	je     0xef684
   ef66c:	53                   	push   %bx
   ef66d:	06                   	push   %es
   ef66e:	e8 6c 12             	call   0xe08dd
   ef671:	e8 3e f9             	call   0xeefb2
   ef674:	07                   	pop    %es
   ef675:	5b                   	pop    %bx
   ef676:	3c 01                	cmp    $0x1,%al
   ef678:	74 e8                	je     0xef662
   ef67a:	3c ff                	cmp    $0xff,%al
   ef67c:	74 e4                	je     0xef662
   ef67e:	e8 a9 06             	call   0xefd2a
   ef681:	e8 61 07             	call   0xefde5
   ef684:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   ef689:	c7 06 f5 00 00 00    	movw   $0x0,0xf5
   ef68f:	b0 00                	mov    $0x0,%al
   ef691:	a2 fe 00             	mov    %al,0xfe
   ef694:	a2 ff 00             	mov    %al,0xff
   ef697:	26 8a 47 19          	mov    %es:0x19(%bx),%al
   ef69b:	a2 ef 04             	mov    %al,0x4ef
   ef69e:	a2 ee 04             	mov    %al,0x4ee
   ef6a1:	26 8a 47 1a          	mov    %es:0x1a(%bx),%al
   ef6a5:	a2 f1 04             	mov    %al,0x4f1
   ef6a8:	a2 f0 04             	mov    %al,0x4f0
   ef6ab:	80 3e ee 04 00       	cmpb   $0x0,0x4ee
   ef6b0:	74 15                	je     0xef6c7
   ef6b2:	80 3e f0 04 00       	cmpb   $0x0,0x4f0
   ef6b7:	74 0e                	je     0xef6c7
   ef6b9:	c6 06 f2 04 01       	movb   $0x1,0x4f2
   ef6be:	80 3e ff 04 01       	cmpb   $0x1,0x4ff
   ef6c3:	74 02                	je     0xef6c7
   ef6c5:	eb 05                	jmp    0xef6cc
   ef6c7:	c6 06 f2 04 00       	movb   $0x0,0x4f2
   ef6cc:	26 8b 4f 12          	mov    %es:0x12(%bx),%cx
   ef6d0:	83 f9 00             	cmp    $0x0,%cx
   ef6d3:	75 03                	jne    0xef6d8
   ef6d5:	e9 72 04             	jmp    0xefb4a
   ef6d8:	26 8b 47 0e          	mov    %es:0xe(%bx),%ax
   ef6dc:	a3 f1 00             	mov    %ax,0xf1
   ef6df:	26 8b 47 10          	mov    %es:0x10(%bx),%ax
   ef6e3:	a3 f3 00             	mov    %ax,0xf3
   ef6e6:	26 8a 47 18          	mov    %es:0x18(%bx),%al
   ef6ea:	3a 06 02 05          	cmp    0x502,%al
   ef6ee:	74 6b                	je     0xef75b
   ef6f0:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef6f5:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   ef6fb:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   ef701:	c7 06 ef 00 00 00    	movw   $0x0,0xef
   ef707:	c7 06 ed 00 00 00    	movw   $0x0,0xed
   ef70d:	3c 01                	cmp    $0x1,%al
   ef70f:	74 2b                	je     0xef73c
   ef711:	3c 00                	cmp    $0x0,%al
   ef713:	74 06                	je     0xef71b
   ef715:	b8 03 80             	mov    $0x8003,%ax
   ef718:	e9 72 e3             	jmp    0xeda8d
   ef71b:	c7 06 01 01 00 08    	movw   $0x800,0x101
   ef721:	c7 06 03 01 10 08    	movw   $0x810,0x103
   ef727:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   ef72c:	75 06                	jne    0xef734
   ef72e:	c7 06 03 01 00 08    	movw   $0x800,0x103
   ef734:	33 c9                	xor    %cx,%cx
   ef736:	8a 0e cc 00          	mov    0xcc,%cl
   ef73a:	eb 12                	jmp    0xef74e
   ef73c:	c7 06 01 01 30 09    	movw   $0x930,0x101
   ef742:	c7 06 03 01 30 09    	movw   $0x930,0x103
   ef748:	33 c9                	xor    %cx,%cx
   ef74a:	8a 0e cb 00          	mov    0xcb,%cl
   ef74e:	89 0e cd 00          	mov    %cx,0xcd
   ef752:	49                   	dec    %cx
   ef753:	89 0e fa 00          	mov    %cx,0xfa
   ef757:	41                   	inc    %cx
   ef758:	a2 02 05             	mov    %al,0x502
   ef75b:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   ef760:	26 8b 47 14          	mov    %es:0x14(%bx),%ax
   ef764:	26 8b 57 16          	mov    %es:0x16(%bx),%dx
   ef768:	06                   	push   %es
   ef769:	53                   	push   %bx
   ef76a:	26 80 7f 0d 00       	cmpb   $0x0,%es:0xd(%bx)
   ef76f:	75 08                	jne    0xef779
   ef771:	05 96 00             	add    $0x96,%ax
   ef774:	83 d2 00             	adc    $0x0,%dx
   ef777:	eb 12                	jmp    0xef78b
   ef779:	26 80 7f 0d 01       	cmpb   $0x1,%es:0xd(%bx)
   ef77e:	74 08                	je     0xef788
   ef780:	5b                   	pop    %bx
   ef781:	07                   	pop    %es
   ef782:	b8 03 80             	mov    $0x8003,%ax
   ef785:	e9 05 e3             	jmp    0xeda8d
   ef788:	e8 00 f1             	call   0xee88b
   ef78b:	a3 dd 00             	mov    %ax,0xdd
   ef78e:	89 16 df 00          	mov    %dx,0xdf
   ef792:	a3 e5 00             	mov    %ax,0xe5
   ef795:	89 16 e7 00          	mov    %dx,0xe7
   ef799:	a3 a7 00             	mov    %ax,0xa7
   ef79c:	89 16 a5 00          	mov    %dx,0xa5
   ef7a0:	e8 6c 0f             	call   0xe070f
   ef7a3:	8a c2                	mov    %dl,%al
   ef7a5:	e8 76 0f             	call   0xe071e
   ef7a8:	a2 69 00             	mov    %al,0x69
   ef7ab:	8a c5                	mov    %ch,%al
   ef7ad:	e8 6e 0f             	call   0xe071e
   ef7b0:	a2 6a 00             	mov    %al,0x6a
   ef7b3:	8a c1                	mov    %cl,%al
   ef7b5:	e8 66 0f             	call   0xe071e
   ef7b8:	a2 6b 00             	mov    %al,0x6b
   ef7bb:	5b                   	pop    %bx
   ef7bc:	07                   	pop    %es
   ef7bd:	26 8b 47 12          	mov    %es:0x12(%bx),%ax
   ef7c1:	a3 79 00             	mov    %ax,0x79
   ef7c4:	c6 06 6c 00 f0       	movb   $0xf0,0x6c
   ef7c9:	c6 06 6d 00 00       	movb   $0x0,0x6d
   ef7ce:	c6 06 6e 00 00       	movb   $0x0,0x6e
   ef7d3:	a1 e7 00             	mov    0xe7,%ax
   ef7d6:	3b 06 e3 00          	cmp    0xe3,%ax
   ef7da:	75 0c                	jne    0xef7e8
   ef7dc:	a1 e5 00             	mov    0xe5,%ax
   ef7df:	3b 06 e1 00          	cmp    0xe1,%ax
   ef7e3:	75 03                	jne    0xef7e8
   ef7e5:	e9 42 02             	jmp    0xefa2a
   ef7e8:	a1 dd 00             	mov    0xdd,%ax
   ef7eb:	a3 15 05             	mov    %ax,0x515
   ef7ee:	a1 df 00             	mov    0xdf,%ax
   ef7f1:	a3 17 05             	mov    %ax,0x517
   ef7f4:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef7f9:	80 3e 00 05 01       	cmpb   $0x1,0x500
   ef7fe:	74 0c                	je     0xef80c
   ef800:	c7 06 ed 00 00 00    	movw   $0x0,0xed
   ef806:	c7 06 ef 00 00 00    	movw   $0x0,0xef
   ef80c:	eb 14                	jmp    0xef822
   ef80e:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef813:	c7 06 e1 00 00 00    	movw   $0x0,0xe1
   ef819:	c7 06 e3 00 00 00    	movw   $0x0,0xe3
   ef81f:	e9 e0 03             	jmp    0xefc02
   ef822:	e8 b8 10             	call   0xe08dd
   ef825:	c6 06 c8 03 28       	movb   $0x28,0x3c8
   ef82a:	e8 f4 f7             	call   0xef021
   ef82d:	3c 01                	cmp    $0x1,%al
   ef82f:	75 02                	jne    0xef833
   ef831:	eb db                	jmp    0xef80e
   ef833:	b0 05                	mov    $0x5,%al
   ef835:	ba d4 00             	mov    $0xd4,%dx
   ef838:	ee                   	out    %al,(%dx)
   ef839:	8b 16 61 00          	mov    0x61,%dx
   ef83d:	b0 40                	mov    $0x40,%al
   ef83f:	ee                   	out    %al,(%dx)
   ef840:	eb 00                	jmp    0xef842
   ef842:	e8 4b 11             	call   0xe0990
   ef845:	3c ff                	cmp    $0xff,%al
   ef847:	75 22                	jne    0xef86b
   ef849:	fe 0e c8 03          	decb   0x3c8
   ef84d:	75 db                	jne    0xef82a
   ef84f:	e8 91 e4             	call   0xedce3
   ef852:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef857:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   ef85d:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   ef863:	c6 06 b0 03 01       	movb   $0x1,0x3b0
   ef868:	e9 84 03             	jmp    0xefbef
   ef86b:	8a c3                	mov    %bl,%al
   ef86d:	a8 40                	test   $0x40,%al
   ef86f:	75 03                	jne    0xef874
   ef871:	e9 64 03             	jmp    0xefbd8
   ef874:	a8 20                	test   $0x20,%al
   ef876:	74 2c                	je     0xef8a4
   ef878:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   ef87d:	c6 06 01 05 01       	movb   $0x1,0x501
   ef882:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   ef887:	e8 53 10             	call   0xe08dd
   ef88a:	e8 25 f7             	call   0xeefb2
   ef88d:	3c ff                	cmp    $0xff,%al
   ef88f:	75 03                	jne    0xef894
   ef891:	e9 44 03             	jmp    0xefbd8
   ef894:	3c 01                	cmp    $0x1,%al
   ef896:	75 03                	jne    0xef89b
   ef898:	e9 67 03             	jmp    0xefc02
   ef89b:	e8 8c 04             	call   0xefd2a
   ef89e:	e8 44 05             	call   0xefde5
   ef8a1:	a0 06 01             	mov    0x106,%al
   ef8a4:	a8 08                	test   $0x8,%al
   ef8a6:	75 03                	jne    0xef8ab
   ef8a8:	e9 af 00             	jmp    0xef95a
   ef8ab:	e8 83 0e             	call   0xe0731
   ef8ae:	3c 2d                	cmp    $0x2d,%al
   ef8b0:	74 03                	je     0xef8b5
   ef8b2:	e9 37 03             	jmp    0xefbec
   ef8b5:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef8ba:	e8 20 10             	call   0xe08dd
   ef8bd:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef8c2:	c6 06 08 05 00       	movb   $0x0,0x508
   ef8c7:	8b 16 61 00          	mov    0x61,%dx
   ef8cb:	b0 c0                	mov    $0xc0,%al
   ef8cd:	9c                   	pushf
   ef8ce:	fa                   	cli
   ef8cf:	ee                   	out    %al,(%dx)
   ef8d0:	a0 69 00             	mov    0x69,%al
   ef8d3:	ee                   	out    %al,(%dx)
   ef8d4:	eb 00                	jmp    0xef8d6
   ef8d6:	a0 6a 00             	mov    0x6a,%al
   ef8d9:	ee                   	out    %al,(%dx)
   ef8da:	eb 00                	jmp    0xef8dc
   ef8dc:	a0 6b 00             	mov    0x6b,%al
   ef8df:	ee                   	out    %al,(%dx)
   ef8e0:	eb 00                	jmp    0xef8e2
   ef8e2:	b0 00                	mov    $0x0,%al
   ef8e4:	ee                   	out    %al,(%dx)
   ef8e5:	eb 00                	jmp    0xef8e7
   ef8e7:	b0 00                	mov    $0x0,%al
   ef8e9:	ee                   	out    %al,(%dx)
   ef8ea:	eb 00                	jmp    0xef8ec
   ef8ec:	b0 01                	mov    $0x1,%al
   ef8ee:	ee                   	out    %al,(%dx)
   ef8ef:	9d                   	popf
   ef8f0:	b9 28 23             	mov    $0x2328,%cx
   ef8f3:	8b 16 63 00          	mov    0x63,%dx
   ef8f7:	ec                   	in     (%dx),%al
   ef8f8:	24 0f                	and    $0xf,%al
   ef8fa:	8a d8                	mov    %al,%bl
   ef8fc:	0c 0b                	or     $0xb,%al
   ef8fe:	3c 0b                	cmp    $0xb,%al
   ef900:	74 2f                	je     0xef931
   ef902:	80 cb 0d             	or     $0xd,%bl
   ef905:	80 fb 0d             	cmp    $0xd,%bl
   ef908:	74 1e                	je     0xef928
   ef90a:	51                   	push   %cx
   ef90b:	b9 01 00             	mov    $0x1,%cx
   ef90e:	e8 e5 10             	call   0xe09f6
   ef911:	59                   	pop    %cx
   ef912:	49                   	dec    %cx
   ef913:	75 e2                	jne    0xef8f7
   ef915:	c6 06 b0 03 09       	movb   $0x9,0x3b0
   ef91a:	fe 0e c8 03          	decb   0x3c8
   ef91e:	74 02                	je     0xef922
   ef920:	eb a0                	jmp    0xef8c2
   ef922:	e8 be e3             	call   0xedce3
   ef925:	e9 c7 02             	jmp    0xefbef
   ef928:	ec                   	in     (%dx),%al
   ef929:	24 0f                	and    $0xf,%al
   ef92b:	0c 0d                	or     $0xd,%al
   ef92d:	3c 0d                	cmp    $0xd,%al
   ef92f:	74 f7                	je     0xef928
   ef931:	e8 18 10             	call   0xe094c
   ef934:	3c ff                	cmp    $0xff,%al
   ef936:	75 03                	jne    0xef93b
   ef938:	e9 b4 02             	jmp    0xefbef
   ef93b:	8a c3                	mov    %bl,%al
   ef93d:	a8 08                	test   $0x8,%al
   ef93f:	74 19                	je     0xef95a
   ef941:	c6 06 b0 03 0b       	movb   $0xb,0x3b0
   ef946:	c6 06 f8 00 01       	movb   $0x1,0xf8
   ef94b:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   ef951:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   ef957:	e9 55 f5             	jmp    0xeeeaf
   ef95a:	e8 d4 0d             	call   0xe0731
   ef95d:	3c 2d                	cmp    $0x2d,%al
   ef95f:	74 03                	je     0xef964
   ef961:	e9 88 02             	jmp    0xefbec
   ef964:	a1 01 01             	mov    0x101,%ax
   ef967:	3d 30 09             	cmp    $0x930,%ax
   ef96a:	75 07                	jne    0xef973
   ef96c:	c6 06 c5 00 61       	movb   $0x61,0xc5
   ef971:	eb 11                	jmp    0xef984
   ef973:	c6 06 c5 00 c1       	movb   $0xc1,0xc5
   ef978:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   ef97d:	75 05                	jne    0xef984
   ef97f:	c6 06 c5 00 01       	movb   $0x1,0xc5
   ef984:	e8 56 0f             	call   0xe08dd
   ef987:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef98c:	8b 16 61 00          	mov    0x61,%dx
   ef990:	b0 50                	mov    $0x50,%al
   ef992:	9c                   	pushf
   ef993:	fa                   	cli
   ef994:	ee                   	out    %al,(%dx)
   ef995:	a0 c5 00             	mov    0xc5,%al
   ef998:	ee                   	out    %al,(%dx)
   ef999:	9d                   	popf
   ef99a:	e8 af 0f             	call   0xe094c
   ef99d:	3c ff                	cmp    $0xff,%al
   ef99f:	75 11                	jne    0xef9b2
   ef9a1:	fe 0e c8 03          	decb   0x3c8
   ef9a5:	75 e5                	jne    0xef98c
   ef9a7:	e8 39 e3             	call   0xedce3
   ef9aa:	c6 06 b0 03 0a       	movb   $0xa,0x3b0
   ef9af:	e9 3d 02             	jmp    0xefbef
   ef9b2:	b9 02 00             	mov    $0x2,%cx
   ef9b5:	e8 25 0f             	call   0xe08dd
   ef9b8:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   ef9bd:	52                   	push   %dx
   ef9be:	50                   	push   %ax
   ef9bf:	ba 78 03             	mov    $0x378,%dx
   ef9c2:	b0 11                	mov    $0x11,%al
   ef9c4:	90                   	nop
   ef9c5:	58                   	pop    %ax
   ef9c6:	5a                   	pop    %dx
   ef9c7:	e8 e1 0e             	call   0xe08ab
   ef9ca:	e8 7f 0f             	call   0xe094c
   ef9cd:	3c ff                	cmp    $0xff,%al
   ef9cf:	75 11                	jne    0xef9e2
   ef9d1:	fe 0e c8 03          	decb   0x3c8
   ef9d5:	75 e6                	jne    0xef9bd
   ef9d7:	e8 09 e3             	call   0xedce3
   ef9da:	c6 06 b0 03 02       	movb   $0x2,0x3b0
   ef9df:	e9 0d 02             	jmp    0xefbef
   ef9e2:	8a c3                	mov    %bl,%al
   ef9e4:	a8 01                	test   $0x1,%al
   ef9e6:	74 06                	je     0xef9ee
   ef9e8:	49                   	dec    %cx
   ef9e9:	75 ca                	jne    0xef9b5
   ef9eb:	e9 0b 02             	jmp    0xefbf9
   ef9ee:	b9 0a 00             	mov    $0xa,%cx
   ef9f1:	e8 02 10             	call   0xe09f6
   ef9f4:	c6 06 f8 00 00       	movb   $0x0,0xf8
   ef9f9:	c6 06 f9 00 00       	movb   $0x0,0xf9
   ef9fe:	c6 06 f7 00 01       	movb   $0x1,0xf7
   efa03:	2e a0 c6 00          	mov    %cs:0xc6,%al
   efa07:	3c 0b                	cmp    $0xb,%al
   efa09:	75 05                	jne    0xefa10
   efa0b:	cd 73                	int    $0x73
   efa0d:	eb 1b                	jmp    0xefa2a
   efa0f:	90                   	nop
   efa10:	3c 05                	cmp    $0x5,%al
   efa12:	74 0c                	je     0xefa20
   efa14:	3c 04                	cmp    $0x4,%al
   efa16:	74 10                	je     0xefa28
   efa18:	3c 07                	cmp    $0x7,%al
   efa1a:	74 08                	je     0xefa24
   efa1c:	cd 0b                	int    $0xb
   efa1e:	eb 0a                	jmp    0xefa2a
   efa20:	cd 0d                	int    $0xd
   efa22:	eb 06                	jmp    0xefa2a
   efa24:	cd 0f                	int    $0xf
   efa26:	eb 02                	jmp    0xefa2a
   efa28:	cd 0c                	int    $0xc
   efa2a:	80 3e 00 05 01       	cmpb   $0x1,0x500
   efa2f:	75 03                	jne    0xefa34
   efa31:	e9 16 01             	jmp    0xefb4a
   efa34:	a1 79 00             	mov    0x79,%ax
   efa37:	3b 06 f5 00          	cmp    0xf5,%ax
   efa3b:	75 03                	jne    0xefa40
   efa3d:	e9 ba 00             	jmp    0xefafa
   efa40:	52                   	push   %dx
   efa41:	50                   	push   %ax
   efa42:	ba 78 03             	mov    $0x378,%dx
   efa45:	b0 12                	mov    $0x12,%al
   efa47:	90                   	nop
   efa48:	58                   	pop    %ax
   efa49:	5a                   	pop    %dx
   efa4a:	bb 28 23             	mov    $0x2328,%bx
   efa4d:	fa                   	cli
   efa4e:	a1 ed 00             	mov    0xed,%ax
   efa51:	3b 06 ef 00          	cmp    0xef,%ax
   efa55:	77 09                	ja     0xefa60
   efa57:	a1 ef 00             	mov    0xef,%ax
   efa5a:	2b 06 ed 00          	sub    0xed,%ax
   efa5e:	eb 0b                	jmp    0xefa6b
   efa60:	a1 cd 00             	mov    0xcd,%ax
   efa63:	2b 06 ed 00          	sub    0xed,%ax
   efa67:	03 06 ef 00          	add    0xef,%ax
   efa6b:	fb                   	sti
   efa6c:	3c 01                	cmp    $0x1,%al
   efa6e:	7d 76                	jge    0xefae6
   efa70:	80 3e f8 00 01       	cmpb   $0x1,0xf8
   efa75:	75 02                	jne    0xefa79
   efa77:	eb 40                	jmp    0xefab9
   efa79:	80 3e f9 00 01       	cmpb   $0x1,0xf9
   efa7e:	74 39                	je     0xefab9
   efa80:	b9 01 00             	mov    $0x1,%cx
   efa83:	e8 70 0f             	call   0xe09f6
   efa86:	4b                   	dec    %bx
   efa87:	75 14                	jne    0xefa9d
   efa89:	c6 06 f8 00 01       	movb   $0x1,0xf8
   efa8e:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   efa94:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   efa9a:	e9 c5 00             	jmp    0xefb62
   efa9d:	8b 16 63 00          	mov    0x63,%dx
   efaa1:	c6 06 03 05 01       	movb   $0x1,0x503
   efaa6:	ec                   	in     (%dx),%al
   efaa7:	24 0f                	and    $0xf,%al
   efaa9:	0c 0b                	or     $0xb,%al
   efaab:	3c 0b                	cmp    $0xb,%al
   efaad:	75 03                	jne    0xefab2
   efaaf:	e9 9b 00             	jmp    0xefb4d
   efab2:	c6 06 03 05 00       	movb   $0x0,0x503
   efab7:	eb 94                	jmp    0xefa4d
   efab9:	33 c9                	xor    %cx,%cx
   efabb:	a1 e5 00             	mov    0xe5,%ax
   efabe:	8b 16 e7 00          	mov    0xe7,%dx
   efac2:	03 06 f5 00          	add    0xf5,%ax
   efac6:	83 d2 00             	adc    $0x0,%dx
   efac9:	a3 dd 00             	mov    %ax,0xdd
   efacc:	89 16 df 00          	mov    %dx,0xdf
   efad0:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   efad5:	06                   	push   %es
   efad6:	53                   	push   %bx
   efad7:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   efadd:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   efae3:	e9 ba fc             	jmp    0xef7a0
   efae6:	e8 2d 01             	call   0xefc16
   efae9:	c6 06 b2 03 00       	movb   $0x0,0x3b2
   efaee:	a1 f5 00             	mov    0xf5,%ax
   efaf1:	3b 06 79 00          	cmp    0x79,%ax
   efaf5:	74 03                	je     0xefafa
   efaf7:	e9 46 ff             	jmp    0xefa40
   efafa:	a1 79 00             	mov    0x79,%ax
   efafd:	83 f2 00             	xor    $0x0,%dx
   efb00:	80 3e f2 04 00       	cmpb   $0x0,0x4f2
   efb05:	74 0b                	je     0xefb12
   efb07:	33 c0                	xor    %ax,%ax
   efb09:	33 d2                	xor    %dx,%dx
   efb0b:	8b 0e 79 00          	mov    0x79,%cx
   efb0f:	e8 4c 03             	call   0xefe5e
   efb12:	03 06 e5 00          	add    0xe5,%ax
   efb16:	13 16 e7 00          	adc    0xe7,%dx
   efb1a:	a3 e1 00             	mov    %ax,0xe1
   efb1d:	89 16 e3 00          	mov    %dx,0xe3
   efb21:	80 3e f8 00 01       	cmpb   $0x1,0xf8
   efb26:	75 22                	jne    0xefb4a
   efb28:	e8 e1 01             	call   0xefd0c
   efb2b:	03 06 e1 00          	add    0xe1,%ax
   efb2f:	83 d2 00             	adc    $0x0,%dx
   efb32:	a3 dd 00             	mov    %ax,0xdd
   efb35:	89 16 df 00          	mov    %dx,0xdf
   efb39:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   efb3e:	06                   	push   %es
   efb3f:	53                   	push   %bx
   efb40:	c6 06 00 05 01       	movb   $0x1,0x500
   efb45:	e9 58 fc             	jmp    0xef7a0
   efb48:	eb 00                	jmp    0xefb4a
   efb4a:	e9 4f e0             	jmp    0xedb9c
   efb4d:	e8 fc 0d             	call   0xe094c
   efb50:	3c ff                	cmp    $0xff,%al
   efb52:	75 03                	jne    0xefb57
   efb54:	e9 81 00             	jmp    0xefbd8
   efb57:	80 e3 04             	and    $0x4,%bl
   efb5a:	80 fb 04             	cmp    $0x4,%bl
   efb5d:	75 03                	jne    0xefb62
   efb5f:	e9 97 00             	jmp    0xefbf9
   efb62:	a1 79 00             	mov    0x79,%ax
   efb65:	8b 16 f5 00          	mov    0xf5,%dx
   efb69:	2b c2                	sub    %dx,%ax
   efb6b:	75 03                	jne    0xefb70
   efb6d:	e9 2c e0             	jmp    0xedb9c
   efb70:	fe 06 b2 03          	incb   0x3b2
   efb74:	80 3e b2 03 07       	cmpb   $0x7,0x3b2
   efb79:	72 03                	jb     0xefb7e
   efb7b:	e9 84 00             	jmp    0xefc02
   efb7e:	c6 06 f8 00 01       	movb   $0x1,0xf8
   efb83:	ba d4 00             	mov    $0xd4,%dx
   efb86:	b0 05                	mov    $0x5,%al
   efb88:	ee                   	out    %al,(%dx)
   efb89:	eb 00                	jmp    0xefb8b
   efb8b:	e8 93 f4             	call   0xef021
   efb8e:	3c 01                	cmp    $0x1,%al
   efb90:	74 1b                	je     0xefbad
   efb92:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   efb97:	8b 16 61 00          	mov    0x61,%dx
   efb9b:	b0 70                	mov    $0x70,%al
   efb9d:	ee                   	out    %al,(%dx)
   efb9e:	eb 00                	jmp    0xefba0
   efba0:	e8 a9 0d             	call   0xe094c
   efba3:	3c ff                	cmp    $0xff,%al
   efba5:	75 06                	jne    0xefbad
   efba7:	fe 0e c8 03          	decb   0x3c8
   efbab:	75 ea                	jne    0xefb97
   efbad:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   efbb3:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   efbb9:	a1 e5 00             	mov    0xe5,%ax
   efbbc:	8b 16 e7 00          	mov    0xe7,%dx
   efbc0:	03 06 f5 00          	add    0xf5,%ax
   efbc4:	83 d2 00             	adc    $0x0,%dx
   efbc7:	a3 dd 00             	mov    %ax,0xdd
   efbca:	89 16 df 00          	mov    %dx,0xdf
   efbce:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   efbd3:	06                   	push   %es
   efbd4:	53                   	push   %bx
   efbd5:	e9 c8 fb             	jmp    0xef7a0
   efbd8:	c6 06 f8 00 01       	movb   $0x1,0xf8
   efbdd:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   efbe3:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   efbe9:	e9 31 e5             	jmp    0xee11d
   efbec:	e9 c0 f2             	jmp    0xeeeaf
   efbef:	e8 84 05             	call   0xe0176
   efbf2:	3c 01                	cmp    $0x1,%al
   efbf4:	74 e2                	je     0xefbd8
   efbf6:	e9 72 fc             	jmp    0xef86b
   efbf9:	e9 ec e8             	jmp    0xee4e8
   efbfc:	b8 00 01             	mov    $0x100,%ax
   efbff:	e9 8b de             	jmp    0xeda8d
   efc02:	c6 06 f8 00 01       	movb   $0x1,0xf8
   efc07:	c7 06 e1 00 ff ff    	movw   $0xffff,0xe1
   efc0d:	c7 06 e3 00 ff ff    	movw   $0xffff,0xe3
   efc13:	e9 fb e4             	jmp    0xee111
   efc16:	06                   	push   %es
   efc17:	1e                   	push   %ds
   efc18:	57                   	push   %di
   efc19:	56                   	push   %si
   efc1a:	50                   	push   %ax
   efc1b:	53                   	push   %bx
   efc1c:	51                   	push   %cx
   efc1d:	80 3e f2 04 00       	cmpb   $0x0,0x4f2
   efc22:	74 25                	je     0xefc49
   efc24:	80 3e ef 04 00       	cmpb   $0x0,0x4ef
   efc29:	74 02                	je     0xefc2d
   efc2b:	eb 1c                	jmp    0xefc49
   efc2d:	80 3e f1 04 00       	cmpb   $0x0,0x4f1
   efc32:	75 0e                	jne    0xefc42
   efc34:	a0 ee 04             	mov    0x4ee,%al
   efc37:	a2 ef 04             	mov    %al,0x4ef
   efc3a:	a0 f0 04             	mov    0x4f0,%al
   efc3d:	a2 f1 04             	mov    %al,0x4f1
   efc40:	eb 07                	jmp    0xefc49
   efc42:	fe 0e f1 04          	decb   0x4f1
   efc46:	e9 aa 00             	jmp    0xefcf3
   efc49:	fe 0e ef 04          	decb   0x4ef
   efc4d:	8b 3e f1 00          	mov    0xf1,%di
   efc51:	a1 f3 00             	mov    0xf3,%ax
   efc54:	8e c0                	mov    %ax,%es
   efc56:	ba 00 00             	mov    $0x0,%dx
   efc59:	8b 0e 01 01          	mov    0x101,%cx
   efc5d:	06                   	push   %es
   efc5e:	57                   	push   %di
   efc5f:	51                   	push   %cx
   efc60:	8b df                	mov    %di,%bx
   efc62:	80 fc f0             	cmp    $0xf0,%ah
   efc65:	72 07                	jb     0xefc6e
   efc67:	8b fb                	mov    %bx,%di
   efc69:	8b d8                	mov    %ax,%bx
   efc6b:	eb 10                	jmp    0xefc7d
   efc6d:	90                   	nop
   efc6e:	53                   	push   %bx
   efc6f:	d1 eb                	shr    $1,%bx
   efc71:	d1 eb                	shr    $1,%bx
   efc73:	d1 eb                	shr    $1,%bx
   efc75:	d1 eb                	shr    $1,%bx
   efc77:	03 d8                	add    %ax,%bx
   efc79:	5f                   	pop    %di
   efc7a:	83 e7 0f             	and    $0xf,%di
   efc7d:	8e c3                	mov    %bx,%es
   efc7f:	bb 00 00             	mov    $0x0,%bx
   efc82:	8b 1e ed 00          	mov    0xed,%bx
   efc86:	d0 e3                	shl    $1,%bl
   efc88:	8b b7 87 01          	mov    0x187(%bx),%si
   efc8c:	b8 ff ff             	mov    $0xffff,%ax
   efc8f:	83 c6 10             	add    $0x10,%si
   efc92:	81 3e 01 01 30 09    	cmpw   $0x930,0x101
   efc98:	74 14                	je     0xefcae
   efc9a:	8b b7 07 01          	mov    0x107(%bx),%si
   efc9e:	b8 ff ff             	mov    $0xffff,%ax
   efca1:	83 c6 10             	add    $0x10,%si
   efca4:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   efca9:	74 03                	je     0xefcae
   efcab:	83 c6 10             	add    $0x10,%si
   efcae:	8e d8                	mov    %ax,%ds
   efcb0:	fc                   	cld
   efcb1:	d1 e9                	shr    $1,%cx
   efcb3:	2e 80 3e f5 04 03    	cmpb   $0x3,%cs:0x4f5
   efcb9:	72 17                	jb     0xefcd2
   efcbb:	d1 e9                	shr    $1,%cx
   efcbd:	66 57                	push   %edi
   efcbf:	66 56                	push   %esi
   efcc1:	66 0f b7 ff          	movzwl %di,%edi
   efcc5:	66 0f b7 f6          	movzwl %si,%esi
   efcc9:	f3 66 a5             	rep movsl %ds:(%si),%es:(%di)
   efccc:	66 5e                	pop    %esi
   efcce:	66 5f                	pop    %edi
   efcd0:	eb 02                	jmp    0xefcd4
   efcd2:	f3 a5                	rep movsw %ds:(%si),%es:(%di)
   efcd4:	59                   	pop    %cx
   efcd5:	5f                   	pop    %di
   efcd6:	07                   	pop    %es
   efcd7:	8c c0                	mov    %es,%ax
   efcd9:	03 f9                	add    %cx,%di
   efcdb:	73 03                	jae    0xefce0
   efcdd:	80 c4 10             	add    $0x10,%ah
   efce0:	8e c0                	mov    %ax,%es
   efce2:	8c c8                	mov    %cs,%ax
   efce4:	8e d8                	mov    %ax,%ds
   efce6:	ff 06 f5 00          	incw   0xf5
   efcea:	89 3e f1 00          	mov    %di,0xf1
   efcee:	8c c0                	mov    %es,%ax
   efcf0:	a3 f3 00             	mov    %ax,0xf3
   efcf3:	33 c0                	xor    %ax,%ax
   efcf5:	a1 ed 00             	mov    0xed,%ax
   efcf8:	40                   	inc    %ax
   efcf9:	3b 06 fa 00          	cmp    0xfa,%ax
   efcfd:	76 02                	jbe    0xefd01
   efcff:	33 c0                	xor    %ax,%ax
   efd01:	a3 ed 00             	mov    %ax,0xed
   efd04:	59                   	pop    %cx
   efd05:	5b                   	pop    %bx
   efd06:	58                   	pop    %ax
   efd07:	5e                   	pop    %si
   efd08:	5f                   	pop    %di
   efd09:	1f                   	pop    %ds
   efd0a:	07                   	pop    %es
   efd0b:	c3                   	ret
   efd0c:	a1 ed 00             	mov    0xed,%ax
   efd0f:	3b 06 ef 00          	cmp    0xef,%ax
   efd13:	77 09                	ja     0xefd1e
   efd15:	a1 ef 00             	mov    0xef,%ax
   efd18:	2b 06 ed 00          	sub    0xed,%ax
   efd1c:	eb 0b                	jmp    0xefd29
   efd1e:	a1 cd 00             	mov    0xcd,%ax
   efd21:	2b 06 ed 00          	sub    0xed,%ax
   efd25:	03 06 ef 00          	add    0xef,%ax
   efd29:	c3                   	ret
   efd2a:	53                   	push   %bx
   efd2b:	51                   	push   %cx
   efd2c:	52                   	push   %dx
   efd2d:	56                   	push   %si
   efd2e:	57                   	push   %di
   efd2f:	55                   	push   %bp
   efd30:	1e                   	push   %ds
   efd31:	06                   	push   %es
   efd32:	c6 06 f4 04 00       	movb   $0x0,0x4f4
   efd37:	83 3e a1 00 00       	cmpw   $0x0,0xa1
   efd3c:	7f 15                	jg     0xefd53
   efd3e:	81 3e a3 00 66 21    	cmpw   $0x2166,0xa3
   efd44:	7f 0d                	jg     0xefd53
   efd46:	f7 06 a3 00 00 80    	testw  $0x8000,0xa3
   efd4c:	75 05                	jne    0xefd53
   efd4e:	32 c0                	xor    %al,%al
   efd50:	e9 89 00             	jmp    0xefddc
   efd53:	c6 06 69 00 00       	movb   $0x0,0x69
   efd58:	c6 06 6a 00 02       	movb   $0x2,0x6a
   efd5d:	c6 06 6b 00 00       	movb   $0x0,0x6b
   efd62:	c6 06 6c 00 00       	movb   $0x0,0x6c
   efd67:	c6 06 6d 00 00       	movb   $0x0,0x6d
   efd6c:	c6 06 6e 00 00       	movb   $0x0,0x6e
   efd71:	e8 69 0b             	call   0xe08dd
   efd74:	e8 34 0b             	call   0xe08ab
   efd77:	e8 d2 0b             	call   0xe094c
   efd7a:	3c ff                	cmp    $0xff,%al
   efd7c:	75 02                	jne    0xefd80
   efd7e:	eb 5c                	jmp    0xefddc
   efd80:	c6 06 69 00 01       	movb   $0x1,0x69
   efd85:	c6 06 6a 00 50       	movb   $0x50,0x6a
   efd8a:	c6 06 6b 00 00       	movb   $0x0,0x6b
   efd8f:	c6 06 6c 00 00       	movb   $0x0,0x6c
   efd94:	c6 06 6d 00 00       	movb   $0x0,0x6d
   efd99:	c6 06 6e 00 00       	movb   $0x0,0x6e
   efd9e:	e8 3c 0b             	call   0xe08dd
   efda1:	e8 07 0b             	call   0xe08ab
   efda4:	e8 a5 0b             	call   0xe094c
   efda7:	3c ff                	cmp    $0xff,%al
   efda9:	75 02                	jne    0xefdad
   efdab:	eb 2f                	jmp    0xefddc
   efdad:	c6 06 69 00 00       	movb   $0x0,0x69
   efdb2:	c6 06 6a 00 02       	movb   $0x2,0x6a
   efdb7:	c6 06 6b 00 00       	movb   $0x0,0x6b
   efdbc:	c6 06 6c 00 00       	movb   $0x0,0x6c
   efdc1:	c6 06 6d 00 00       	movb   $0x0,0x6d
   efdc6:	c6 06 6e 00 00       	movb   $0x0,0x6e
   efdcb:	e8 0f 0b             	call   0xe08dd
   efdce:	e8 da 0a             	call   0xe08ab
   efdd1:	e8 78 0b             	call   0xe094c
   efdd4:	3c ff                	cmp    $0xff,%al
   efdd6:	75 02                	jne    0xefdda
   efdd8:	eb 02                	jmp    0xefddc
   efdda:	32 c0                	xor    %al,%al
   efddc:	07                   	pop    %es
   efddd:	1f                   	pop    %ds
   efdde:	5d                   	pop    %bp
   efddf:	5f                   	pop    %di
   efde0:	5e                   	pop    %si
   efde1:	5a                   	pop    %dx
   efde2:	59                   	pop    %cx
   efde3:	5b                   	pop    %bx
   efde4:	c3                   	ret
   efde5:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   efdea:	75 01                	jne    0xefded
   efdec:	c3                   	ret
   efded:	53                   	push   %bx
   efdee:	51                   	push   %cx
   efdef:	52                   	push   %dx
   efdf0:	56                   	push   %si
   efdf1:	57                   	push   %di
   efdf2:	55                   	push   %bp
   efdf3:	1e                   	push   %ds
   efdf4:	06                   	push   %es
   efdf5:	e8 e5 0a             	call   0xe08dd
   efdf8:	8b 16 61 00          	mov    0x61,%dx
   efdfc:	b0 90                	mov    $0x90,%al
   efdfe:	9c                   	pushf
   efdff:	fa                   	cli
   efe00:	ee                   	out    %al,(%dx)
   efe01:	b0 02                	mov    $0x2,%al
   efe03:	ee                   	out    %al,(%dx)
   efe04:	eb 00                	jmp    0xefe06
   efe06:	b0 01                	mov    $0x1,%al
   efe08:	ee                   	out    %al,(%dx)
   efe09:	9d                   	popf
   efe0a:	e8 3f 0b             	call   0xe094c
   efe0d:	e8 cd 0a             	call   0xe08dd
   efe10:	8b 16 61 00          	mov    0x61,%dx
   efe14:	b0 90                	mov    $0x90,%al
   efe16:	9c                   	pushf
   efe17:	fa                   	cli
   efe18:	ee                   	out    %al,(%dx)
   efe19:	b0 08                	mov    $0x8,%al
   efe1b:	ee                   	out    %al,(%dx)
   efe1c:	eb 00                	jmp    0xefe1e
   efe1e:	b0 48                	mov    $0x48,%al
   efe20:	ee                   	out    %al,(%dx)
   efe21:	9d                   	popf
   efe22:	e8 27 0b             	call   0xe094c
   efe25:	e8 b5 0a             	call   0xe08dd
   efe28:	8b 16 61 00          	mov    0x61,%dx
   efe2c:	b0 90                	mov    $0x90,%al
   efe2e:	9c                   	pushf
   efe2f:	fa                   	cli
   efe30:	ee                   	out    %al,(%dx)
   efe31:	b0 01                	mov    $0x1,%al
   efe33:	ee                   	out    %al,(%dx)
   efe34:	eb 00                	jmp    0xefe36
   efe36:	b0 08                	mov    $0x8,%al
   efe38:	ee                   	out    %al,(%dx)
   efe39:	eb 00                	jmp    0xefe3b
   efe3b:	b0 0f                	mov    $0xf,%al
   efe3d:	ee                   	out    %al,(%dx)
   efe3e:	9d                   	popf
   efe3f:	e8 0a 0b             	call   0xe094c
   efe42:	e8 98 0a             	call   0xe08dd
   efe45:	8b 16 61 00          	mov    0x61,%dx
   efe49:	b0 50                	mov    $0x50,%al
   efe4b:	9c                   	pushf
   efe4c:	fa                   	cli
   efe4d:	ee                   	out    %al,(%dx)
   efe4e:	b0 c1                	mov    $0xc1,%al
   efe50:	ee                   	out    %al,(%dx)
   efe51:	9d                   	popf
   efe52:	e8 f7 0a             	call   0xe094c
   efe55:	07                   	pop    %es
   efe56:	1f                   	pop    %ds
   efe57:	5d                   	pop    %bp
   efe58:	5f                   	pop    %di
   efe59:	5e                   	pop    %si
   efe5a:	5a                   	pop    %dx
   efe5b:	59                   	pop    %cx
   efe5c:	5b                   	pop    %bx
   efe5d:	c3                   	ret
   efe5e:	53                   	push   %bx
   efe5f:	51                   	push   %cx
   efe60:	33 c0                	xor    %ax,%ax
   efe62:	8b d8                	mov    %ax,%bx
   efe64:	a0 ee 04             	mov    0x4ee,%al
   efe67:	2b c8                	sub    %ax,%cx
   efe69:	76 03                	jbe    0xefe6e
   efe6b:	43                   	inc    %bx
   efe6c:	eb f9                	jmp    0xefe67
   efe6e:	32 e4                	xor    %ah,%ah
   efe70:	a0 ee 04             	mov    0x4ee,%al
   efe73:	f7 e3                	mul    %bx
   efe75:	59                   	pop    %cx
   efe76:	2b c8                	sub    %ax,%cx
   efe78:	32 f6                	xor    %dh,%dh
   efe7a:	8a 16 ee 04          	mov    0x4ee,%dl
   efe7e:	02 16 f0 04          	add    0x4f0,%dl
   efe82:	80 d6 00             	adc    $0x0,%dh
   efe85:	8b c3                	mov    %bx,%ax
   efe87:	f7 e2                	mul    %dx
   efe89:	03 c1                	add    %cx,%ax
   efe8b:	83 d2 00             	adc    $0x0,%dx
   efe8e:	5b                   	pop    %bx
   efe8f:	c3                   	ret
   efe90:	b0 01                	mov    $0x1,%al
   efe92:	c3                   	ret
   efe93:	e8 fa ff             	call   0xefe90
   efe96:	3c 01                	cmp    $0x1,%al
   efe98:	74 03                	je     0xefe9d
   efe9a:	e9 5c 01             	jmp    0xefff9
   efe9d:	80 3e f4 04 00       	cmpb   $0x0,0x4f4
   efea2:	74 18                	je     0xefebc
   efea4:	53                   	push   %bx
   efea5:	06                   	push   %es
   efea6:	e8 34 0a             	call   0xe08dd
   efea9:	e8 06 f1             	call   0xeefb2
   efeac:	07                   	pop    %es
   efead:	5b                   	pop    %bx
   efeae:	3c 01                	cmp    $0x1,%al
   efeb0:	74 e8                	je     0xefe9a
   efeb2:	3c ff                	cmp    $0xff,%al
   efeb4:	74 e4                	je     0xefe9a
   efeb6:	e8 71 fe             	call   0xefd2a
   efeb9:	e8 29 ff             	call   0xefde5
   efebc:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   efec1:	b0 00                	mov    $0x0,%al
   efec3:	a2 fe 00             	mov    %al,0xfe
   efec6:	a2 ff 00             	mov    %al,0xff
   efec9:	26 8b 47 14          	mov    %es:0x14(%bx),%ax
   efecd:	26 8b 57 16          	mov    %es:0x16(%bx),%dx
   efed1:	06                   	push   %es
   efed2:	53                   	push   %bx
   efed3:	26 80 7f 0d 00       	cmpb   $0x0,%es:0xd(%bx)
   efed8:	75 08                	jne    0xefee2
   efeda:	05 96 00             	add    $0x96,%ax
   efedd:	83 d2 00             	adc    $0x0,%dx
   efee0:	eb 12                	jmp    0xefef4
   efee2:	26 80 7f 0d 01       	cmpb   $0x1,%es:0xd(%bx)
   efee7:	74 08                	je     0xefef1
   efee9:	5b                   	pop    %bx
   efeea:	07                   	pop    %es
   efeeb:	b8 03 80             	mov    $0x8003,%ax
   efeee:	e9 9c db             	jmp    0xeda8d
   efef1:	e8 97 e9             	call   0xee88b
   efef4:	a3 e5 00             	mov    %ax,0xe5
   efef7:	89 16 e7 00          	mov    %dx,0xe7
   efefb:	89 16 a5 00          	mov    %dx,0xa5
   efeff:	a3 a7 00             	mov    %ax,0xa7
   eff02:	e8 0a 08             	call   0xe070f
   eff05:	8a c2                	mov    %dl,%al
   eff07:	e8 14 08             	call   0xe071e
   eff0a:	a2 69 00             	mov    %al,0x69
   eff0d:	8a c5                	mov    %ch,%al
   eff0f:	e8 0c 08             	call   0xe071e
   eff12:	a2 6a 00             	mov    %al,0x6a
   eff15:	8a c1                	mov    %cl,%al
   eff17:	e8 04 08             	call   0xe071e
   eff1a:	a2 6b 00             	mov    %al,0x6b
   eff1d:	5b                   	pop    %bx
   eff1e:	07                   	pop    %es
   eff1f:	c6 06 6c 00 00       	movb   $0x0,0x6c
   eff24:	c6 06 6d 00 00       	movb   $0x0,0x6d
   eff29:	c6 06 6e 00 00       	movb   $0x0,0x6e
   eff2e:	c6 06 f8 00 01       	movb   $0x1,0xf8
   eff33:	c7 06 ed 00 00 00    	movw   $0x0,0xed
   eff39:	c7 06 ef 00 00 00    	movw   $0x0,0xef
   eff3f:	e8 df f0             	call   0xef021
   eff42:	3c 00                	cmp    $0x0,%al
   eff44:	74 03                	je     0xeff49
   eff46:	e9 b0 00             	jmp    0xefff9
   eff49:	e8 91 09             	call   0xe08dd
   eff4c:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   eff51:	c7 06 fc 00 08 07    	movw   $0x708,0xfc
   eff57:	8b 16 61 00          	mov    0x61,%dx
   eff5b:	b0 40                	mov    $0x40,%al
   eff5d:	ee                   	out    %al,(%dx)
   eff5e:	eb 00                	jmp    0xeff60
   eff60:	e8 e9 09             	call   0xe094c
   eff63:	3c ff                	cmp    $0xff,%al
   eff65:	75 11                	jne    0xeff78
   eff67:	fe 0e c8 03          	decb   0x3c8
   eff6b:	75 e4                	jne    0xeff51
   eff6d:	e8 73 dd             	call   0xedce3
   eff70:	c6 06 b0 03 03       	movb   $0x3,0x3b0
   eff75:	e9 87 00             	jmp    0xeffff
   eff78:	8a c3                	mov    %bl,%al
   eff7a:	a8 40                	test   $0x40,%al
   eff7c:	75 02                	jne    0xeff80
   eff7e:	eb 79                	jmp    0xefff9
   eff80:	a8 20                	test   $0x20,%al
   eff82:	74 2d                	je     0xeffb1
   eff84:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   eff89:	c6 06 01 05 01       	movb   $0x1,0x501
   eff8e:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   eff93:	e8 47 09             	call   0xe08dd
   eff96:	e8 19 f0             	call   0xeefb2
   eff99:	3c ff                	cmp    $0xff,%al
   eff9b:	75 03                	jne    0xeffa0
   eff9d:	e9 38 fc             	jmp    0xefbd8
   effa0:	3c 01                	cmp    $0x1,%al
   effa2:	75 03                	jne    0xeffa7
   effa4:	e9 5b fc             	jmp    0xefc02
   effa7:	e8 80 fd             	call   0xefd2a
   effaa:	e8 38 fe             	call   0xefde5
   effad:	8a 1e 06 01          	mov    0x106,%bl
   effb1:	8a c3                	mov    %bl,%al
   effb3:	a8 08                	test   $0x8,%al
   effb5:	74 03                	je     0xeffba
   effb7:	e9 e2 db             	jmp    0xedb9c
   effba:	8a c3                	mov    %bl,%al
   effbc:	a8 02                	test   $0x2,%al
   effbe:	74 03                	je     0xeffc3
   effc0:	e9 c7 da             	jmp    0xeda8a
   effc3:	e8 6b 07             	call   0xe0731
   effc6:	3c 2d                	cmp    $0x2d,%al
   effc8:	74 02                	je     0xeffcc
   effca:	eb 30                	jmp    0xefffc
   effcc:	e8 0e 09             	call   0xe08dd
   effcf:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   effd4:	e8 d4 08             	call   0xe08ab
   effd7:	e8 72 09             	call   0xe094c
   effda:	3c ff                	cmp    $0xff,%al
   effdc:	75 10                	jne    0xeffee
   effde:	fe 0e c8 03          	decb   0x3c8
   effe2:	75 f0                	jne    0xeffd4
   effe4:	e8 fc dc             	call   0xedce3
   effe7:	c6 06 b0 03 04       	movb   $0x4,0x3b0
   effec:	eb 11                	jmp    0xeffff
   effee:	8a c3                	mov    %bl,%al
   efff0:	24 40                	and    $0x40,%al
   efff2:	3c 40                	cmp    $0x40,%al
   efff4:	75 03                	jne    0xefff9
   efff6:	e9 a3 db             	jmp    0xedb9c
   efff9:	e9 21 e1             	jmp    0xee11d
   efffc:	e9 b0 ee             	jmp    0xeeeaf
   effff:	e8 74 01             	call   0xf0176
   f0002:	3c 01                	cmp    $0x1,%al
   f0004:	74 f3                	je     0xefff9
   f0006:	8a c3                	mov    %bl,%al
   f0008:	e9 6d ff             	jmp    0xfff78
   f000b:	e9 03 e1             	jmp    0xfe111
   f000e:	e8 7f fe             	call   0xffe90
   f0011:	3c 01                	cmp    $0x1,%al
   f0013:	74 03                	je     0xf0018
   f0015:	e9 4c 01             	jmp    0xf0164
   f0018:	80 3e f4 04 00       	cmpb   $0x0,0x4f4
   f001d:	74 18                	je     0xf0037
   f001f:	53                   	push   %bx
   f0020:	06                   	push   %es
   f0021:	e8 b9 08             	call   0xf08dd
   f0024:	e8 8b ef             	call   0xfefb2
   f0027:	07                   	pop    %es
   f0028:	5b                   	pop    %bx
   f0029:	3c 01                	cmp    $0x1,%al
   f002b:	74 e8                	je     0xf0015
   f002d:	3c ff                	cmp    $0xff,%al
   f002f:	74 e4                	je     0xf0015
   f0031:	e8 f6 fc             	call   0xffd2a
   f0034:	e8 ae fd             	call   0xffde5
   f0037:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   f003c:	b0 00                	mov    $0x0,%al
   f003e:	a2 fe 00             	mov    %al,0xfe
   f0041:	a2 ff 00             	mov    %al,0xff
   f0044:	26 8b 47 14          	mov    %es:0x14(%bx),%ax
   f0048:	26 8b 57 16          	mov    %es:0x16(%bx),%dx
   f004c:	06                   	push   %es
   f004d:	53                   	push   %bx
   f004e:	26 80 7f 0d 00       	cmpb   $0x0,%es:0xd(%bx)
   f0053:	75 08                	jne    0xf005d
   f0055:	05 96 00             	add    $0x96,%ax
   f0058:	83 d2 00             	adc    $0x0,%dx
   f005b:	eb 12                	jmp    0xf006f
   f005d:	26 80 7f 0d 01       	cmpb   $0x1,%es:0xd(%bx)
   f0062:	74 08                	je     0xf006c
   f0064:	5b                   	pop    %bx
   f0065:	07                   	pop    %es
   f0066:	b8 03 80             	mov    $0x8003,%ax
   f0069:	e9 21 da             	jmp    0xfda8d
   f006c:	e8 1c e8             	call   0xfe88b
   f006f:	89 16 a5 00          	mov    %dx,0xa5
   f0073:	a3 a7 00             	mov    %ax,0xa7
   f0076:	e8 96 06             	call   0xf070f
   f0079:	8a c2                	mov    %dl,%al
   f007b:	e8 a0 06             	call   0xf071e
   f007e:	a2 69 00             	mov    %al,0x69
   f0081:	8a c5                	mov    %ch,%al
   f0083:	e8 98 06             	call   0xf071e
   f0086:	a2 6a 00             	mov    %al,0x6a
   f0089:	8a c1                	mov    %cl,%al
   f008b:	e8 90 06             	call   0xf071e
   f008e:	a2 6b 00             	mov    %al,0x6b
   f0091:	5b                   	pop    %bx
   f0092:	07                   	pop    %es
   f0093:	c6 06 6c 00 00       	movb   $0x0,0x6c
   f0098:	c6 06 6d 00 00       	movb   $0x0,0x6d
   f009d:	c6 06 6e 00 00       	movb   $0x0,0x6e
   f00a2:	c6 06 f8 00 01       	movb   $0x1,0xf8
   f00a7:	c7 06 ed 00 00 00    	movw   $0x0,0xed
   f00ad:	c7 06 ef 00 00 00    	movw   $0x0,0xef
   f00b3:	e8 6b ef             	call   0xff021
   f00b6:	3c 00                	cmp    $0x0,%al
   f00b8:	74 03                	je     0xf00bd
   f00ba:	e9 a7 00             	jmp    0xf0164
   f00bd:	c7 06 fc 00 08 07    	movw   $0x708,0xfc
   f00c3:	e8 17 08             	call   0xf08dd
   f00c6:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f00cb:	8b 16 61 00          	mov    0x61,%dx
   f00cf:	b0 40                	mov    $0x40,%al
   f00d1:	ee                   	out    %al,(%dx)
   f00d2:	eb 00                	jmp    0xf00d4
   f00d4:	e8 75 08             	call   0xf094c
   f00d7:	3c ff                	cmp    $0xff,%al
   f00d9:	75 18                	jne    0xf00f3
   f00db:	fe 0e c8 03          	decb   0x3c8
   f00df:	75 ea                	jne    0xf00cb
   f00e1:	e8 ff db             	call   0xfdce3
   f00e4:	c6 06 b0 03 05       	movb   $0x5,0x3b0
   f00e9:	eb 7c                	jmp    0xf0167
   f00eb:	90                   	nop
   f00ec:	8b 16 61 00          	mov    0x61,%dx
   f00f0:	ec                   	in     (%dx),%al
   f00f1:	8a d8                	mov    %al,%bl
   f00f3:	8a c3                	mov    %bl,%al
   f00f5:	24 40                	and    $0x40,%al
   f00f7:	3c 40                	cmp    $0x40,%al
   f00f9:	74 02                	je     0xf00fd
   f00fb:	eb 67                	jmp    0xf0164
   f00fd:	8a c3                	mov    %bl,%al
   f00ff:	24 20                	and    $0x20,%al
   f0101:	3c 20                	cmp    $0x20,%al
   f0103:	75 29                	jne    0xf012e
   f0105:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f010a:	c6 06 01 05 01       	movb   $0x1,0x501
   f010f:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f0114:	e8 c6 07             	call   0xf08dd
   f0117:	e8 98 ee             	call   0xfefb2
   f011a:	3c ff                	cmp    $0xff,%al
   f011c:	75 03                	jne    0xf0121
   f011e:	e9 b7 fa             	jmp    0xffbd8
   f0121:	3c 01                	cmp    $0x1,%al
   f0123:	75 03                	jne    0xf0128
   f0125:	e9 da fa             	jmp    0xffc02
   f0128:	e8 ff fb             	call   0xffd2a
   f012b:	e8 b7 fc             	call   0xffde5
   f012e:	e8 00 06             	call   0xf0731
   f0131:	3c 2d                	cmp    $0x2d,%al
   f0133:	74 02                	je     0xf0137
   f0135:	eb 39                	jmp    0xf0170
   f0137:	e8 a3 07             	call   0xf08dd
   f013a:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f013f:	e8 69 07             	call   0xf08ab
   f0142:	e8 07 08             	call   0xf094c
   f0145:	3c ff                	cmp    $0xff,%al
   f0147:	75 10                	jne    0xf0159
   f0149:	fe 0e c8 03          	decb   0x3c8
   f014d:	75 f0                	jne    0xf013f
   f014f:	e8 91 db             	call   0xfdce3
   f0152:	c6 06 b0 03 06       	movb   $0x6,0x3b0
   f0157:	eb 0e                	jmp    0xf0167
   f0159:	8a c3                	mov    %bl,%al
   f015b:	24 40                	and    $0x40,%al
   f015d:	3c 40                	cmp    $0x40,%al
   f015f:	75 03                	jne    0xf0164
   f0161:	e9 38 da             	jmp    0xfdb9c
   f0164:	e9 b6 df             	jmp    0xfe11d
   f0167:	e8 0c 00             	call   0xf0176
   f016a:	3c 01                	cmp    $0x1,%al
   f016c:	74 f6                	je     0xf0164
   f016e:	eb 83                	jmp    0xf00f3
   f0170:	b8 06 80             	mov    $0x8006,%ax
   f0173:	e9 17 d9             	jmp    0xfda8d
   f0176:	80 3e b1 03 01       	cmpb   $0x1,0x3b1
   f017b:	74 13                	je     0xf0190
   f017d:	e8 5d 07             	call   0xf08dd
   f0180:	8b 16 61 00          	mov    0x61,%dx
   f0184:	b0 40                	mov    $0x40,%al
   f0186:	ee                   	out    %al,(%dx)
   f0187:	eb 00                	jmp    0xf0189
   f0189:	e8 c0 07             	call   0xf094c
   f018c:	3c ff                	cmp    $0xff,%al
   f018e:	75 08                	jne    0xf0198
   f0190:	b0 01                	mov    $0x1,%al
   f0192:	c6 06 b1 03 00       	movb   $0x0,0x3b1
   f0197:	c3                   	ret
   f0198:	c6 06 b1 03 01       	movb   $0x1,0x3b1
   f019d:	32 c0                	xor    %al,%al
   f019f:	c3                   	ret
   f01a0:	e8 ed fc             	call   0xffe90
   f01a3:	3c 01                	cmp    $0x1,%al
   f01a5:	74 03                	je     0xf01aa
   f01a7:	e9 46 03             	jmp    0xf04f0
   f01aa:	80 3e f4 04 00       	cmpb   $0x0,0x4f4
   f01af:	74 18                	je     0xf01c9
   f01b1:	53                   	push   %bx
   f01b2:	06                   	push   %es
   f01b3:	e8 27 07             	call   0xf08dd
   f01b6:	e8 f9 ed             	call   0xfefb2
   f01b9:	07                   	pop    %es
   f01ba:	5b                   	pop    %bx
   f01bb:	3c 01                	cmp    $0x1,%al
   f01bd:	74 e8                	je     0xf01a7
   f01bf:	3c ff                	cmp    $0xff,%al
   f01c1:	74 e4                	je     0xf01a7
   f01c3:	e8 64 fb             	call   0xffd2a
   f01c6:	e8 1c fc             	call   0xffde5
   f01c9:	c7 06 cc 03 00 00    	movw   $0x0,0x3cc
   f01cf:	c7 06 ce 03 00 00    	movw   $0x0,0x3ce
   f01d5:	c6 06 db 03 00       	movb   $0x0,0x3db
   f01da:	c6 06 dc 03 00       	movb   $0x0,0x3dc
   f01df:	c6 06 d8 03 62       	movb   $0x62,0x3d8
   f01e4:	26 8b 47 0e          	mov    %es:0xe(%bx),%ax
   f01e8:	26 8b 57 10          	mov    %es:0x10(%bx),%dx
   f01ec:	c6 06 d5 03 00       	movb   $0x0,0x3d5
   f01f1:	26 f6 47 0d 01       	testb  $0x1,%es:0xd(%bx)
   f01f6:	75 08                	jne    0xf0200
   f01f8:	05 96 00             	add    $0x96,%ax
   f01fb:	83 d2 00             	adc    $0x0,%dx
   f01fe:	eb 08                	jmp    0xf0208
   f0200:	c6 06 d5 03 01       	movb   $0x1,0x3d5
   f0205:	e8 83 e6             	call   0xfe88b
   f0208:	89 16 a5 00          	mov    %dx,0xa5
   f020c:	a3 a7 00             	mov    %ax,0xa7
   f020f:	a3 e9 00             	mov    %ax,0xe9
   f0212:	89 16 eb 00          	mov    %dx,0xeb
   f0216:	e8 f6 04             	call   0xf070f
   f0219:	8a c2                	mov    %dl,%al
   f021b:	e8 00 05             	call   0xf071e
   f021e:	a2 69 00             	mov    %al,0x69
   f0221:	8a c5                	mov    %ch,%al
   f0223:	e8 f8 04             	call   0xf071e
   f0226:	a2 6a 00             	mov    %al,0x6a
   f0229:	8a c1                	mov    %cl,%al
   f022b:	e8 f0 04             	call   0xf071e
   f022e:	a2 6b 00             	mov    %al,0x6b
   f0231:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f0236:	26 8b 47 12          	mov    %es:0x12(%bx),%ax
   f023a:	26 8b 57 14          	mov    %es:0x14(%bx),%dx
   f023e:	06                   	push   %es
   f023f:	53                   	push   %bx
   f0240:	03 06 e9 00          	add    0xe9,%ax
   f0244:	83 d2 00             	adc    $0x0,%dx
   f0247:	03 16 eb 00          	add    0xeb,%dx
   f024b:	a3 d0 03             	mov    %ax,0x3d0
   f024e:	89 16 d2 03          	mov    %dx,0x3d2
   f0252:	73 07                	jae    0xf025b
   f0254:	a1 a3 00             	mov    0xa3,%ax
   f0257:	8b 16 a1 00          	mov    0xa1,%dx
   f025b:	e8 b1 04             	call   0xf070f
   f025e:	8a c2                	mov    %dl,%al
   f0260:	e8 bb 04             	call   0xf071e
   f0263:	a2 6c 00             	mov    %al,0x6c
   f0266:	8a c5                	mov    %ch,%al
   f0268:	e8 b3 04             	call   0xf071e
   f026b:	a2 6d 00             	mov    %al,0x6d
   f026e:	8a c1                	mov    %cl,%al
   f0270:	e8 ab 04             	call   0xf071e
   f0273:	a2 6e 00             	mov    %al,0x6e
   f0276:	5b                   	pop    %bx
   f0277:	07                   	pop    %es
   f0278:	26 8a 47 0d          	mov    %es:0xd(%bx),%al
   f027c:	a8 02                	test   $0x2,%al
   f027e:	75 03                	jne    0xf0283
   f0280:	e9 c5 00             	jmp    0xf0348
   f0283:	c6 06 c0 03 01       	movb   $0x1,0x3c0
   f0288:	e8 52 d8             	call   0xfdadd
   f028b:	3c ff                	cmp    $0xff,%al
   f028d:	75 03                	jne    0xf0292
   f028f:	e9 8b de             	jmp    0xfe11d
   f0292:	3c 04                	cmp    $0x4,%al
   f0294:	75 08                	jne    0xf029e
   f0296:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   f029b:	e9 aa 00             	jmp    0xf0348
   f029e:	a1 a7 00             	mov    0xa7,%ax
   f02a1:	8b 16 a5 00          	mov    0xa5,%dx
   f02a5:	2d 7d 00             	sub    $0x7d,%ax
   f02a8:	83 da 00             	sbb    $0x0,%dx
   f02ab:	e8 61 04             	call   0xf070f
   f02ae:	8a c2                	mov    %dl,%al
   f02b0:	e8 6b 04             	call   0xf071e
   f02b3:	a2 69 00             	mov    %al,0x69
   f02b6:	8a c5                	mov    %ch,%al
   f02b8:	e8 63 04             	call   0xf071e
   f02bb:	a2 6a 00             	mov    %al,0x6a
   f02be:	8a c1                	mov    %cl,%al
   f02c0:	e8 5b 04             	call   0xf071e
   f02c3:	a2 6b 00             	mov    %al,0x6b
   f02c6:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f02cb:	26 8b 47 12          	mov    %es:0x12(%bx),%ax
   f02cf:	26 8b 57 14          	mov    %es:0x14(%bx),%dx
   f02d3:	05 02 00             	add    $0x2,%ax
   f02d6:	83 d2 00             	adc    $0x0,%dx
   f02d9:	03 06 e9 00          	add    0xe9,%ax
   f02dd:	83 d2 00             	adc    $0x0,%dx
   f02e0:	03 16 eb 00          	add    0xeb,%dx
   f02e4:	73 07                	jae    0xf02ed
   f02e6:	a1 a3 00             	mov    0xa3,%ax
   f02e9:	8b 16 a1 00          	mov    0xa1,%dx
   f02ed:	e8 1f 04             	call   0xf070f
   f02f0:	8a c2                	mov    %dl,%al
   f02f2:	e8 29 04             	call   0xf071e
   f02f5:	a2 6c 00             	mov    %al,0x6c
   f02f8:	8a c5                	mov    %ch,%al
   f02fa:	e8 21 04             	call   0xf071e
   f02fd:	a2 6d 00             	mov    %al,0x6d
   f0300:	8a c1                	mov    %cl,%al
   f0302:	e8 19 04             	call   0xf071e
   f0305:	a2 6e 00             	mov    %al,0x6e
   f0308:	a1 a7 00             	mov    0xa7,%ax
   f030b:	8b 16 a5 00          	mov    0xa5,%dx
   f030f:	e8 fd 03             	call   0xf070f
   f0312:	8a c2                	mov    %dl,%al
   f0314:	e8 07 04             	call   0xf071e
   f0317:	a2 6f 00             	mov    %al,0x6f
   f031a:	8a c5                	mov    %ch,%al
   f031c:	e8 ff 03             	call   0xf071e
   f031f:	a2 70 00             	mov    %al,0x70
   f0322:	8a c1                	mov    %cl,%al
   f0324:	e8 f7 03             	call   0xf071e
   f0327:	a2 71 00             	mov    %al,0x71
   f032a:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f032f:	26 8b 47 12          	mov    %es:0x12(%bx),%ax
   f0333:	26 8b 57 14          	mov    %es:0x14(%bx),%dx
   f0337:	05 02 00             	add    $0x2,%ax
   f033a:	83 d2 00             	adc    $0x0,%dx
   f033d:	88 16 72 00          	mov    %dl,0x72
   f0341:	88 26 73 00          	mov    %ah,0x73
   f0345:	a2 74 00             	mov    %al,0x74
   f0348:	e8 d6 ec             	call   0xff021
   f034b:	3c 00                	cmp    $0x0,%al
   f034d:	74 03                	je     0xf0352
   f034f:	e9 9e 01             	jmp    0xf04f0
   f0352:	e8 88 05             	call   0xf08dd
   f0355:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f035a:	8b 16 61 00          	mov    0x61,%dx
   f035e:	b0 40                	mov    $0x40,%al
   f0360:	ee                   	out    %al,(%dx)
   f0361:	eb 00                	jmp    0xf0363
   f0363:	e8 e6 05             	call   0xf094c
   f0366:	3c ff                	cmp    $0xff,%al
   f0368:	75 11                	jne    0xf037b
   f036a:	fe 0e c8 03          	decb   0x3c8
   f036e:	75 ea                	jne    0xf035a
   f0370:	e8 70 d9             	call   0xfdce3
   f0373:	c6 06 b0 03 07       	movb   $0x7,0x3b0
   f0378:	e9 83 01             	jmp    0xf04fe
   f037b:	8a c3                	mov    %bl,%al
   f037d:	24 20                	and    $0x20,%al
   f037f:	3c 20                	cmp    $0x20,%al
   f0381:	75 2d                	jne    0xf03b0
   f0383:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f0388:	c6 06 01 05 01       	movb   $0x1,0x501
   f038d:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f0392:	e8 48 05             	call   0xf08dd
   f0395:	e8 1a ec             	call   0xfefb2
   f0398:	3c ff                	cmp    $0xff,%al
   f039a:	75 03                	jne    0xf039f
   f039c:	e9 39 f8             	jmp    0xffbd8
   f039f:	3c 01                	cmp    $0x1,%al
   f03a1:	75 03                	jne    0xf03a6
   f03a3:	e9 5c f8             	jmp    0xffc02
   f03a6:	e8 81 f9             	call   0xffd2a
   f03a9:	e8 39 fa             	call   0xffde5
   f03ac:	8a 1e 06 01          	mov    0x106,%bl
   f03b0:	8a c3                	mov    %bl,%al
   f03b2:	24 02                	and    $0x2,%al
   f03b4:	3c 02                	cmp    $0x2,%al
   f03b6:	75 0d                	jne    0xf03c5
   f03b8:	c6 06 fe 00 01       	movb   $0x1,0xfe
   f03bd:	c6 06 ff 00 00       	movb   $0x0,0xff
   f03c2:	e9 44 03             	jmp    0xf0709
   f03c5:	e8 69 03             	call   0xf0731
   f03c8:	3c 2d                	cmp    $0x2d,%al
   f03ca:	74 03                	je     0xf03cf
   f03cc:	e9 2c 01             	jmp    0xf04fb
   f03cf:	80 3e c0 03 01       	cmpb   $0x1,0x3c0
   f03d4:	75 2a                	jne    0xf0400
   f03d6:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f03db:	33 db                	xor    %bx,%bx
   f03dd:	8a 1e dc 03          	mov    0x3dc,%bl
   f03e1:	d1 e3                	shl    $1,%bx
   f03e3:	8b 87 e0 03          	mov    0x3e0(%bx),%ax
   f03e7:	a3 d9 03             	mov    %ax,0x3d9
   f03ea:	e8 52 e4             	call   0xfe83f
   f03ed:	e8 5c 05             	call   0xf094c
   f03f0:	3c ff                	cmp    $0xff,%al
   f03f2:	75 0c                	jne    0xf0400
   f03f4:	fe 0e c8 03          	decb   0x3c8
   f03f8:	75 e1                	jne    0xf03db
   f03fa:	e8 e6 d8             	call   0xfdce3
   f03fd:	e9 1d dd             	jmp    0xfe11d
   f0400:	80 3e c0 03 01       	cmpb   $0x1,0x3c0
   f0405:	75 03                	jne    0xf040a
   f0407:	eb 62                	jmp    0xf046b
   f0409:	90                   	nop
   f040a:	8b 16 61 00          	mov    0x61,%dx
   f040e:	b0 50                	mov    $0x50,%al
   f0410:	9c                   	pushf
   f0411:	fa                   	cli
   f0412:	ee                   	out    %al,(%dx)
   f0413:	b0 00                	mov    $0x0,%al
   f0415:	ee                   	out    %al,(%dx)
   f0416:	9d                   	popf
   f0417:	e8 32 05             	call   0xf094c
   f041a:	3c ff                	cmp    $0xff,%al
   f041c:	75 03                	jne    0xf0421
   f041e:	e9 fc dc             	jmp    0xfe11d
   f0421:	8b 16 61 00          	mov    0x61,%dx
   f0425:	b0 c0                	mov    $0xc0,%al
   f0427:	9c                   	pushf
   f0428:	fa                   	cli
   f0429:	ee                   	out    %al,(%dx)
   f042a:	a0 69 00             	mov    0x69,%al
   f042d:	ee                   	out    %al,(%dx)
   f042e:	eb 00                	jmp    0xf0430
   f0430:	a0 6a 00             	mov    0x6a,%al
   f0433:	ee                   	out    %al,(%dx)
   f0434:	eb 00                	jmp    0xf0436
   f0436:	a0 6b 00             	mov    0x6b,%al
   f0439:	ee                   	out    %al,(%dx)
   f043a:	eb 00                	jmp    0xf043c
   f043c:	b0 00                	mov    $0x0,%al
   f043e:	ee                   	out    %al,(%dx)
   f043f:	eb 00                	jmp    0xf0441
   f0441:	b0 00                	mov    $0x0,%al
   f0443:	ee                   	out    %al,(%dx)
   f0444:	eb 00                	jmp    0xf0446
   f0446:	b0 00                	mov    $0x0,%al
   f0448:	ee                   	out    %al,(%dx)
   f0449:	9d                   	popf
   f044a:	e8 ff 04             	call   0xf094c
   f044d:	3c ff                	cmp    $0xff,%al
   f044f:	75 03                	jne    0xf0454
   f0451:	e9 c9 dc             	jmp    0xfe11d
   f0454:	8b 16 61 00          	mov    0x61,%dx
   f0458:	b0 50                	mov    $0x50,%al
   f045a:	9c                   	pushf
   f045b:	fa                   	cli
   f045c:	ee                   	out    %al,(%dx)
   f045d:	b0 01                	mov    $0x1,%al
   f045f:	ee                   	out    %al,(%dx)
   f0460:	9d                   	popf
   f0461:	e8 e8 04             	call   0xf094c
   f0464:	3c ff                	cmp    $0xff,%al
   f0466:	75 03                	jne    0xf046b
   f0468:	e9 b2 dc             	jmp    0xfe11d
   f046b:	c6 06 f8 00 01       	movb   $0x1,0xf8
   f0470:	e8 6a 04             	call   0xf08dd
   f0473:	e8 35 04             	call   0xf08ab
   f0476:	8b 16 63 00          	mov    0x63,%dx
   f047a:	bb 28 23             	mov    $0x2328,%bx
   f047d:	ec                   	in     (%dx),%al
   f047e:	a8 02                	test   $0x2,%al
   f0480:	74 14                	je     0xf0496
   f0482:	a8 04                	test   $0x4,%al
   f0484:	74 1d                	je     0xf04a3
   f0486:	b9 01 00             	mov    $0x1,%cx
   f0489:	e8 6a 05             	call   0xf09f6
   f048c:	4b                   	dec    %bx
   f048d:	75 ee                	jne    0xf047d
   f048f:	c6 06 b0 03 08       	movb   $0x8,0x3b0
   f0494:	eb 68                	jmp    0xf04fe
   f0496:	e8 b3 04             	call   0xf094c
   f0499:	3c ff                	cmp    $0xff,%al
   f049b:	75 03                	jne    0xf04a0
   f049d:	e9 7d dc             	jmp    0xfe11d
   f04a0:	e9 45 e0             	jmp    0xfe4e8
   f04a3:	8b 16 61 00          	mov    0x61,%dx
   f04a7:	ec                   	in     (%dx),%al
   f04a8:	8a d8                	mov    %al,%bl
   f04aa:	8a c3                	mov    %bl,%al
   f04ac:	24 08                	and    $0x8,%al
   f04ae:	3c 08                	cmp    $0x8,%al
   f04b0:	74 0a                	je     0xf04bc
   f04b2:	b0 00                	mov    $0x0,%al
   f04b4:	a2 fe 00             	mov    %al,0xfe
   f04b7:	a2 ff 00             	mov    %al,0xff
   f04ba:	eb 3f                	jmp    0xf04fb
   f04bc:	8a c3                	mov    %bl,%al
   f04be:	24 f8                	and    $0xf8,%al
   f04c0:	3c 58                	cmp    $0x58,%al
   f04c2:	74 04                	je     0xf04c8
   f04c4:	3c 78                	cmp    $0x78,%al
   f04c6:	75 18                	jne    0xf04e0
   f04c8:	c6 06 fe 00 01       	movb   $0x1,0xfe
   f04cd:	c6 06 ff 00 00       	movb   $0x0,0xff
   f04d2:	8a c3                	mov    %bl,%al
   f04d4:	24 02                	and    $0x2,%al
   f04d6:	3c 02                	cmp    $0x2,%al
   f04d8:	74 03                	je     0xf04dd
   f04da:	e9 bf d6             	jmp    0xfdb9c
   f04dd:	e9 c1 d6             	jmp    0xfdba1
   f04e0:	8a c3                	mov    %bl,%al
   f04e2:	24 40                	and    $0x40,%al
   f04e4:	3c 40                	cmp    $0x40,%al
   f04e6:	75 08                	jne    0xf04f0
   f04e8:	8a c3                	mov    %bl,%al
   f04ea:	24 20                	and    $0x20,%al
   f04ec:	3c 20                	cmp    $0x20,%al
   f04ee:	74 18                	je     0xf0508
   f04f0:	b0 00                	mov    $0x0,%al
   f04f2:	a2 fe 00             	mov    %al,0xfe
   f04f5:	a2 ff 00             	mov    %al,0xff
   f04f8:	e9 22 dc             	jmp    0xfe11d
   f04fb:	e9 b1 e9             	jmp    0xfeeaf
   f04fe:	e8 75 fc             	call   0xf0176
   f0501:	3c 01                	cmp    $0x1,%al
   f0503:	74 eb                	je     0xf04f0
   f0505:	e9 73 fe             	jmp    0xf037b
   f0508:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f050d:	c6 06 01 05 01       	movb   $0x1,0x501
   f0512:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f0517:	e9 e2 f6             	jmp    0xffbfc
   f051a:	e8 73 f9             	call   0xffe90
   f051d:	3c 01                	cmp    $0x1,%al
   f051f:	74 02                	je     0xf0523
   f0521:	eb cd                	jmp    0xf04f0
   f0523:	c6 06 c0 03 00       	movb   $0x0,0x3c0
   f0528:	e8 f6 ea             	call   0xff021
   f052b:	3c 00                	cmp    $0x0,%al
   f052d:	74 03                	je     0xf0532
   f052f:	e9 eb db             	jmp    0xfe11d
   f0532:	e8 a8 03             	call   0xf08dd
   f0535:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f053a:	8b 16 61 00          	mov    0x61,%dx
   f053e:	b0 40                	mov    $0x40,%al
   f0540:	ee                   	out    %al,(%dx)
   f0541:	eb 00                	jmp    0xf0543
   f0543:	e8 06 04             	call   0xf094c
   f0546:	3c ff                	cmp    $0xff,%al
   f0548:	75 0b                	jne    0xf0555
   f054a:	fe 0e c8 03          	decb   0x3c8
   f054e:	75 ea                	jne    0xf053a
   f0550:	e8 90 d7             	call   0xfdce3
   f0553:	eb 9b                	jmp    0xf04f0
   f0555:	8a c3                	mov    %bl,%al
   f0557:	24 20                	and    $0x20,%al
   f0559:	3c 20                	cmp    $0x20,%al
   f055b:	75 0f                	jne    0xf056c
   f055d:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f0562:	c6 06 01 05 01       	movb   $0x1,0x501
   f0567:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f056c:	80 e3 02             	and    $0x2,%bl
   f056f:	80 fb 02             	cmp    $0x2,%bl
   f0572:	74 06                	je     0xf057a
   f0574:	e8 be 00             	call   0xf0635
   f0577:	e9 13 d5             	jmp    0xfda8d
   f057a:	e8 60 03             	call   0xf08dd
   f057d:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f0582:	8b 16 61 00          	mov    0x61,%dx
   f0586:	b0 70                	mov    $0x70,%al
   f0588:	ee                   	out    %al,(%dx)
   f0589:	eb 00                	jmp    0xf058b
   f058b:	e8 be 03             	call   0xf094c
   f058e:	3c ff                	cmp    $0xff,%al
   f0590:	75 0f                	jne    0xf05a1
   f0592:	fe 0e c8 03          	decb   0x3c8
   f0596:	75 ea                	jne    0xf0582
   f0598:	e8 48 d7             	call   0xfdce3
   f059b:	e8 97 00             	call   0xf0635
   f059e:	e9 7c db             	jmp    0xfe11d
   f05a1:	e8 c8 01             	call   0xf076c
   f05a4:	3c ff                	cmp    $0xff,%al
   f05a6:	75 03                	jne    0xf05ab
   f05a8:	e9 45 ff             	jmp    0xf04f0
   f05ab:	3c 01                	cmp    $0x1,%al
   f05ad:	75 06                	jne    0xf05b5
   f05af:	e8 83 00             	call   0xf0635
   f05b2:	e9 33 df             	jmp    0xfe4e8
   f05b5:	a0 6c 00             	mov    0x6c,%al
   f05b8:	a2 90 00             	mov    %al,0x90
   f05bb:	a0 6d 00             	mov    0x6d,%al
   f05be:	a2 91 00             	mov    %al,0x91
   f05c1:	a0 6e 00             	mov    0x6e,%al
   f05c4:	a2 92 00             	mov    %al,0x92
   f05c7:	e8 4f 00             	call   0xf0619
   f05ca:	89 16 95 00          	mov    %dx,0x95
   f05ce:	a3 93 00             	mov    %ax,0x93
   f05d1:	a0 9e 00             	mov    0x9e,%al
   f05d4:	a2 90 00             	mov    %al,0x90
   f05d7:	a0 9f 00             	mov    0x9f,%al
   f05da:	a2 91 00             	mov    %al,0x91
   f05dd:	a0 a0 00             	mov    0xa0,%al
   f05e0:	a2 92 00             	mov    %al,0x92
   f05e3:	e8 33 00             	call   0xf0619
   f05e6:	3b 16 95 00          	cmp    0x95,%dx
   f05ea:	77 27                	ja     0xf0613
   f05ec:	72 06                	jb     0xf05f4
   f05ee:	3b 06 93 00          	cmp    0x93,%ax
   f05f2:	77 1f                	ja     0xf0613
   f05f4:	a0 9e 00             	mov    0x9e,%al
   f05f7:	a2 69 00             	mov    %al,0x69
   f05fa:	a0 9f 00             	mov    0x9f,%al
   f05fd:	a2 6a 00             	mov    %al,0x6a
   f0600:	a0 a0 00             	mov    0xa0,%al
   f0603:	a2 6b 00             	mov    %al,0x6b
   f0606:	c6 06 fe 00 00       	movb   $0x0,0xfe
   f060b:	c6 06 ff 00 01       	movb   $0x1,0xff
   f0610:	e9 89 d5             	jmp    0xfdb9c
   f0613:	e8 1f 00             	call   0xf0635
   f0616:	e9 74 d4             	jmp    0xfda8d
   f0619:	a0 90 00             	mov    0x90,%al
   f061c:	e8 b4 03             	call   0xf09d3
   f061f:	8a d0                	mov    %al,%dl
   f0621:	a0 91 00             	mov    0x91,%al
   f0624:	e8 ac 03             	call   0xf09d3
   f0627:	8a e8                	mov    %al,%ch
   f0629:	a0 92 00             	mov    0x92,%al
   f062c:	e8 a4 03             	call   0xf09d3
   f062f:	8a e5                	mov    %ch,%ah
   f0631:	e8 57 e2             	call   0xfe88b
   f0634:	c3                   	ret
   f0635:	b0 00                	mov    $0x0,%al
   f0637:	a2 fe 00             	mov    %al,0xfe
   f063a:	a2 ff 00             	mov    %al,0xff
   f063d:	33 c0                	xor    %ax,%ax
   f063f:	a2 69 00             	mov    %al,0x69
   f0642:	a2 6a 00             	mov    %al,0x6a
   f0645:	a2 6b 00             	mov    %al,0x6b
   f0648:	a2 6c 00             	mov    %al,0x6c
   f064b:	a2 6d 00             	mov    %al,0x6d
   f064e:	a2 6e 00             	mov    %al,0x6e
   f0651:	c3                   	ret
   f0652:	e8 3b f8             	call   0xffe90
   f0655:	3c 01                	cmp    $0x1,%al
   f0657:	74 03                	je     0xf065c
   f0659:	e9 94 fe             	jmp    0xf04f0
   f065c:	80 3e f4 04 00       	cmpb   $0x0,0x4f4
   f0661:	74 18                	je     0xf067b
   f0663:	53                   	push   %bx
   f0664:	06                   	push   %es
   f0665:	e8 75 02             	call   0xf08dd
   f0668:	e8 47 e9             	call   0xfefb2
   f066b:	07                   	pop    %es
   f066c:	5b                   	pop    %bx
   f066d:	3c 01                	cmp    $0x1,%al
   f066f:	74 e8                	je     0xf0659
   f0671:	3c ff                	cmp    $0xff,%al
   f0673:	74 e4                	je     0xf0659
   f0675:	e8 b2 f6             	call   0xffd2a
   f0678:	e8 6a f7             	call   0xffde5
   f067b:	a0 ff 00             	mov    0xff,%al
   f067e:	3c 01                	cmp    $0x1,%al
   f0680:	74 0d                	je     0xf068f
   f0682:	a0 fe 00             	mov    0xfe,%al
   f0685:	3c 01                	cmp    $0x1,%al
   f0687:	75 03                	jne    0xf068c
   f0689:	eb 7e                	jmp    0xf0709
   f068b:	90                   	nop
   f068c:	e9 59 de             	jmp    0xfe4e8
   f068f:	e8 8f e9             	call   0xff021
   f0692:	3c 00                	cmp    $0x0,%al
   f0694:	74 03                	je     0xf0699
   f0696:	e9 4f de             	jmp    0xfe4e8
   f0699:	e8 41 02             	call   0xf08dd
   f069c:	c6 06 c8 03 03       	movb   $0x3,0x3c8
   f06a1:	8b 16 61 00          	mov    0x61,%dx
   f06a5:	b0 40                	mov    $0x40,%al
   f06a7:	ee                   	out    %al,(%dx)
   f06a8:	eb 00                	jmp    0xf06aa
   f06aa:	e8 9f 02             	call   0xf094c
   f06ad:	3c ff                	cmp    $0xff,%al
   f06af:	74 30                	je     0xf06e1
   f06b1:	8a c3                	mov    %bl,%al
   f06b3:	24 20                	and    $0x20,%al
   f06b5:	3c 20                	cmp    $0x20,%al
   f06b7:	75 1d                	jne    0xf06d6
   f06b9:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f06be:	c6 06 01 05 01       	movb   $0x1,0x501
   f06c3:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f06c8:	88 1e 06 01          	mov    %bl,0x106
   f06cc:	e8 5b f6             	call   0xffd2a
   f06cf:	e8 13 f7             	call   0xffde5
   f06d2:	8a 1e 06 01          	mov    0x106,%bl
   f06d6:	8a c3                	mov    %bl,%al
   f06d8:	24 08                	and    $0x8,%al
   f06da:	3c 08                	cmp    $0x8,%al
   f06dc:	74 17                	je     0xf06f5
   f06de:	e9 07 de             	jmp    0xfe4e8
   f06e1:	fe 0e c8 03          	decb   0x3c8
   f06e5:	75 ba                	jne    0xf06a1
   f06e7:	e8 f9 d5             	call   0xfdce3
   f06ea:	b0 00                	mov    $0x0,%al
   f06ec:	a2 fe 00             	mov    %al,0xfe
   f06ef:	a2 ff 00             	mov    %al,0xff
   f06f2:	e9 f3 dd             	jmp    0xfe4e8
   f06f5:	8a c3                	mov    %bl,%al
   f06f7:	a8 40                	test   $0x40,%al
   f06f9:	75 03                	jne    0xf06fe
   f06fb:	e9 ea dd             	jmp    0xfe4e8
   f06fe:	8a c3                	mov    %bl,%al
   f0700:	a8 02                	test   $0x2,%al
   f0702:	74 02                	je     0xf0706
   f0704:	eb 03                	jmp    0xf0709
   f0706:	e9 c6 fc             	jmp    0xf03cf
   f0709:	b8 0c 80             	mov    $0x800c,%ax
   f070c:	e9 7b d3             	jmp    0xfda8a
   f070f:	b9 94 11             	mov    $0x1194,%cx
   f0712:	f7 f1                	div    %cx
   f0714:	92                   	xchg   %ax,%dx
   f0715:	b1 4b                	mov    $0x4b,%cl
   f0717:	f6 f1                	div    %cl
   f0719:	86 e0                	xchg   %ah,%al
   f071b:	8b c8                	mov    %ax,%cx
   f071d:	c3                   	ret
   f071e:	53                   	push   %bx
   f071f:	d4 0a                	aam    $0xa
   f0721:	50                   	push   %ax
   f0722:	d1 e8                	shr    $1,%ax
   f0724:	d1 e8                	shr    $1,%ax
   f0726:	d1 e8                	shr    $1,%ax
   f0728:	d1 e8                	shr    $1,%ax
   f072a:	8a d8                	mov    %al,%bl
   f072c:	58                   	pop    %ax
   f072d:	02 c3                	add    %bl,%al
   f072f:	5b                   	pop    %bx
   f0730:	c3                   	ret
   f0731:	a1 a1 00             	mov    0xa1,%ax
   f0734:	8b 16 a5 00          	mov    0xa5,%dx
   f0738:	2b c2                	sub    %dx,%ax
   f073a:	77 0b                	ja     0xf0747
   f073c:	a1 a3 00             	mov    0xa3,%ax
   f073f:	8b 16 a7 00          	mov    0xa7,%dx
   f0743:	2b c2                	sub    %dx,%ax
   f0745:	76 03                	jbe    0xf074a
   f0747:	b0 2d                	mov    $0x2d,%al
   f0749:	c3                   	ret
   f074a:	c6 06 b0 03 0c       	movb   $0xc,0x3b0
   f074f:	e8 60 e8             	call   0xfefb2
   f0752:	a1 a1 00             	mov    0xa1,%ax
   f0755:	8b 16 a5 00          	mov    0xa5,%dx
   f0759:	2b c2                	sub    %dx,%ax
   f075b:	77 ea                	ja     0xf0747
   f075d:	a1 a3 00             	mov    0xa3,%ax
   f0760:	8b 16 a7 00          	mov    0xa7,%dx
   f0764:	2b c2                	sub    %dx,%ax
   f0766:	77 df                	ja     0xf0747
   f0768:	f8                   	clc
   f0769:	b0 2b                	mov    $0x2b,%al
   f076b:	c3                   	ret
   f076c:	e8 6e 01             	call   0xf08dd
   f076f:	8b 16 61 00          	mov    0x61,%dx
   f0773:	b0 20                	mov    $0x20,%al
   f0775:	ee                   	out    %al,(%dx)
   f0776:	eb 00                	jmp    0xf0778
   f0778:	e8 d1 01             	call   0xf094c
   f077b:	3c ff                	cmp    $0xff,%al
   f077d:	75 01                	jne    0xf0780
   f077f:	c3                   	ret
   f0780:	88 1e 06 01          	mov    %bl,0x106
   f0784:	f6 c3 40             	test   $0x40,%bl
   f0787:	75 03                	jne    0xf078c
   f0789:	b0 01                	mov    $0x1,%al
   f078b:	c3                   	ret
   f078c:	e8 bd 01             	call   0xf094c
   f078f:	3c ff                	cmp    $0xff,%al
   f0791:	75 01                	jne    0xf0794
   f0793:	c3                   	ret
   f0794:	88 1e 97 00          	mov    %bl,0x97
   f0798:	e8 b1 01             	call   0xf094c
   f079b:	3c ff                	cmp    $0xff,%al
   f079d:	75 01                	jne    0xf07a0
   f079f:	c3                   	ret
   f07a0:	88 1e 98 00          	mov    %bl,0x98
   f07a4:	e8 a5 01             	call   0xf094c
   f07a7:	3c ff                	cmp    $0xff,%al
   f07a9:	75 01                	jne    0xf07ac
   f07ab:	c3                   	ret
   f07ac:	88 1e 99 00          	mov    %bl,0x99
   f07b0:	e8 99 01             	call   0xf094c
   f07b3:	3c ff                	cmp    $0xff,%al
   f07b5:	75 01                	jne    0xf07b8
   f07b7:	c3                   	ret
   f07b8:	88 1e 9a 00          	mov    %bl,0x9a
   f07bc:	e8 8d 01             	call   0xf094c
   f07bf:	3c ff                	cmp    $0xff,%al
   f07c1:	75 01                	jne    0xf07c4
   f07c3:	c3                   	ret
   f07c4:	88 1e 9b 00          	mov    %bl,0x9b
   f07c8:	e8 81 01             	call   0xf094c
   f07cb:	3c ff                	cmp    $0xff,%al
   f07cd:	75 01                	jne    0xf07d0
   f07cf:	c3                   	ret
   f07d0:	88 1e 9c 00          	mov    %bl,0x9c
   f07d4:	e8 75 01             	call   0xf094c
   f07d7:	3c ff                	cmp    $0xff,%al
   f07d9:	75 01                	jne    0xf07dc
   f07db:	c3                   	ret
   f07dc:	88 1e 9d 00          	mov    %bl,0x9d
   f07e0:	e8 69 01             	call   0xf094c
   f07e3:	3c ff                	cmp    $0xff,%al
   f07e5:	75 01                	jne    0xf07e8
   f07e7:	c3                   	ret
   f07e8:	88 1e 9e 00          	mov    %bl,0x9e
   f07ec:	e8 5d 01             	call   0xf094c
   f07ef:	3c ff                	cmp    $0xff,%al
   f07f1:	75 01                	jne    0xf07f4
   f07f3:	c3                   	ret
   f07f4:	88 1e 9f 00          	mov    %bl,0x9f
   f07f8:	e8 51 01             	call   0xf094c
   f07fb:	3c ff                	cmp    $0xff,%al
   f07fd:	75 01                	jne    0xf0800
   f07ff:	c3                   	ret
   f0800:	88 1e a0 00          	mov    %bl,0xa0
   f0804:	8a 1e 06 01          	mov    0x106,%bl
   f0808:	8a c3                	mov    %bl,%al
   f080a:	24 04                	and    $0x4,%al
   f080c:	3c 04                	cmp    $0x4,%al
   f080e:	74 05                	je     0xf0815
   f0810:	33 db                	xor    %bx,%bx
   f0812:	33 c0                	xor    %ax,%ax
   f0814:	c3                   	ret
   f0815:	33 db                	xor    %bx,%bx
   f0817:	b8 01 00             	mov    $0x1,%ax
   f081a:	c3                   	ret
   f081b:	8b 16 61 00          	mov    0x61,%dx
   f081f:	b0 10                	mov    $0x10,%al
   f0821:	ee                   	out    %al,(%dx)
   f0822:	eb 00                	jmp    0xf0824
   f0824:	e8 25 01             	call   0xf094c
   f0827:	3c ff                	cmp    $0xff,%al
   f0829:	75 01                	jne    0xf082c
   f082b:	c3                   	ret
   f082c:	88 1e 06 01          	mov    %bl,0x106
   f0830:	f6 c3 40             	test   $0x40,%bl
   f0833:	75 03                	jne    0xf0838
   f0835:	b0 01                	mov    $0x1,%al
   f0837:	c3                   	ret
   f0838:	f6 c3 20             	test   $0x20,%bl
   f083b:	74 0b                	je     0xf0848
   f083d:	b0 01                	mov    $0x1,%al
   f083f:	a2 a8 03             	mov    %al,0x3a8
   f0842:	a2 01 05             	mov    %al,0x501
   f0845:	a2 f4 04             	mov    %al,0x4f4
   f0848:	e8 01 01             	call   0xf094c
   f084b:	3c ff                	cmp    $0xff,%al
   f084d:	75 01                	jne    0xf0850
   f084f:	c3                   	ret
   f0850:	88 1e 7c 00          	mov    %bl,0x7c
   f0854:	e8 f5 00             	call   0xf094c
   f0857:	3c ff                	cmp    $0xff,%al
   f0859:	75 01                	jne    0xf085c
   f085b:	c3                   	ret
   f085c:	88 1e 7d 00          	mov    %bl,0x7d
   f0860:	e8 e9 00             	call   0xf094c
   f0863:	3c ff                	cmp    $0xff,%al
   f0865:	75 01                	jne    0xf0868
   f0867:	c3                   	ret
   f0868:	88 1e 7e 00          	mov    %bl,0x7e
   f086c:	e8 dd 00             	call   0xf094c
   f086f:	3c ff                	cmp    $0xff,%al
   f0871:	75 01                	jne    0xf0874
   f0873:	c3                   	ret
   f0874:	88 1e 7f 00          	mov    %bl,0x7f
   f0878:	e8 d1 00             	call   0xf094c
   f087b:	3c ff                	cmp    $0xff,%al
   f087d:	75 01                	jne    0xf0880
   f087f:	c3                   	ret
   f0880:	88 1e 80 00          	mov    %bl,0x80
   f0884:	e8 c5 00             	call   0xf094c
   f0887:	3c ff                	cmp    $0xff,%al
   f0889:	75 01                	jne    0xf088c
   f088b:	c3                   	ret
   f088c:	88 1e 81 00          	mov    %bl,0x81
   f0890:	e8 b9 00             	call   0xf094c
   f0893:	3c ff                	cmp    $0xff,%al
   f0895:	75 01                	jne    0xf0898
   f0897:	c3                   	ret
   f0898:	88 1e 82 00          	mov    %bl,0x82
   f089c:	e8 ad 00             	call   0xf094c
   f089f:	3c ff                	cmp    $0xff,%al
   f08a1:	75 01                	jne    0xf08a4
   f08a3:	c3                   	ret
   f08a4:	88 1e 83 00          	mov    %bl,0x83
   f08a8:	b0 00                	mov    $0x0,%al
   f08aa:	c3                   	ret
   f08ab:	c6 06 08 05 00       	movb   $0x0,0x508
   f08b0:	8b 16 61 00          	mov    0x61,%dx
   f08b4:	b0 c0                	mov    $0xc0,%al
   f08b6:	9c                   	pushf
   f08b7:	fa                   	cli
   f08b8:	ee                   	out    %al,(%dx)
   f08b9:	a0 69 00             	mov    0x69,%al
   f08bc:	ee                   	out    %al,(%dx)
   f08bd:	eb 00                	jmp    0xf08bf
   f08bf:	a0 6a 00             	mov    0x6a,%al
   f08c2:	ee                   	out    %al,(%dx)
   f08c3:	eb 00                	jmp    0xf08c5
   f08c5:	a0 6b 00             	mov    0x6b,%al
   f08c8:	ee                   	out    %al,(%dx)
   f08c9:	eb 00                	jmp    0xf08cb
   f08cb:	a0 6c 00             	mov    0x6c,%al
   f08ce:	ee                   	out    %al,(%dx)
   f08cf:	eb 00                	jmp    0xf08d1
   f08d1:	a0 6d 00             	mov    0x6d,%al
   f08d4:	ee                   	out    %al,(%dx)
   f08d5:	eb 00                	jmp    0xf08d7
   f08d7:	a0 6e 00             	mov    0x6e,%al
   f08da:	ee                   	out    %al,(%dx)
   f08db:	9d                   	popf
   f08dc:	c3                   	ret
   f08dd:	51                   	push   %cx
   f08de:	53                   	push   %bx
   f08df:	c6 06 03 05 01       	movb   $0x1,0x503
   f08e4:	bb 0a 00             	mov    $0xa,%bx
   f08e7:	8b 16 63 00          	mov    0x63,%dx
   f08eb:	ec                   	in     (%dx),%al
   f08ec:	24 0f                	and    $0xf,%al
   f08ee:	0c 0b                	or     $0xb,%al
   f08f0:	3c 0b                	cmp    $0xb,%al
   f08f2:	74 0b                	je     0xf08ff
   f08f4:	b9 01 00             	mov    $0x1,%cx
   f08f7:	e8 fc 00             	call   0xf09f6
   f08fa:	4b                   	dec    %bx
   f08fb:	75 ee                	jne    0xf08eb
   f08fd:	eb 1b                	jmp    0xf091a
   f08ff:	8b 16 61 00          	mov    0x61,%dx
   f0903:	ec                   	in     (%dx),%al
   f0904:	a8 20                	test   $0x20,%al
   f0906:	74 12                	je     0xf091a
   f0908:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f090d:	c6 06 01 05 01       	movb   $0x1,0x501
   f0912:	c6 06 a8 03 01       	movb   $0x1,0x3a8
   f0917:	e8 98 e6             	call   0xfefb2
   f091a:	c6 06 03 05 00       	movb   $0x0,0x503
   f091f:	5b                   	pop    %bx
   f0920:	59                   	pop    %cx
   f0921:	c3                   	ret
   f0922:	51                   	push   %cx
   f0923:	8b 16 63 00          	mov    0x63,%dx
   f0927:	bb 30 75             	mov    $0x7530,%bx
   f092a:	ec                   	in     (%dx),%al
   f092b:	24 0f                	and    $0xf,%al
   f092d:	0c 0b                	or     $0xb,%al
   f092f:	3c 0b                	cmp    $0xb,%al
   f0931:	74 0d                	je     0xf0940
   f0933:	b9 01 00             	mov    $0x1,%cx
   f0936:	e8 bd 00             	call   0xf09f6
   f0939:	4b                   	dec    %bx
   f093a:	75 ee                	jne    0xf092a
   f093c:	b0 ff                	mov    $0xff,%al
   f093e:	59                   	pop    %cx
   f093f:	c3                   	ret
   f0940:	8b 16 61 00          	mov    0x61,%dx
   f0944:	ec                   	in     (%dx),%al
   f0945:	8a d8                	mov    %al,%bl
   f0947:	b0 00                	mov    $0x0,%al
   f0949:	59                   	pop    %cx
   f094a:	c3                   	ret
   f094b:	90                   	nop
   f094c:	51                   	push   %cx
   f094d:	c6 06 03 05 01       	movb   $0x1,0x503
   f0952:	8b 16 63 00          	mov    0x63,%dx
   f0956:	bb b8 0b             	mov    $0xbb8,%bx
   f0959:	ec                   	in     (%dx),%al
   f095a:	24 0f                	and    $0xf,%al
   f095c:	0c 0b                	or     $0xb,%al
   f095e:	3c 0b                	cmp    $0xb,%al
   f0960:	74 12                	je     0xf0974
   f0962:	b9 01 00             	mov    $0x1,%cx
   f0965:	e8 8e 00             	call   0xf09f6
   f0968:	4b                   	dec    %bx
   f0969:	75 ee                	jne    0xf0959
   f096b:	b0 ff                	mov    $0xff,%al
   f096d:	59                   	pop    %cx
   f096e:	c6 06 03 05 00       	movb   $0x0,0x503
   f0973:	c3                   	ret
   f0974:	4a                   	dec    %dx
   f0975:	90                   	nop
   f0976:	ec                   	in     (%dx),%al
   f0977:	90                   	nop
   f0978:	42                   	inc    %dx
   f0979:	80 3e af 03 01       	cmpb   $0x1,0x3af
   f097e:	74 04                	je     0xf0984
   f0980:	3c ff                	cmp    $0xff,%al
   f0982:	74 de                	je     0xf0962
   f0984:	8a d8                	mov    %al,%bl
   f0986:	b0 00                	mov    $0x0,%al
   f0988:	59                   	pop    %cx
   f0989:	c6 06 03 05 00       	movb   $0x0,0x503
   f098e:	c3                   	ret
   f098f:	90                   	nop
   f0990:	51                   	push   %cx
   f0991:	c6 06 03 05 01       	movb   $0x1,0x503
   f0996:	8b 16 63 00          	mov    0x63,%dx
   f099a:	bb 30 00             	mov    $0x30,%bx
   f099d:	ec                   	in     (%dx),%al
   f099e:	24 0f                	and    $0xf,%al
   f09a0:	0c 0b                	or     $0xb,%al
   f09a2:	3c 0b                	cmp    $0xb,%al
   f09a4:	74 12                	je     0xf09b8
   f09a6:	b9 01 00             	mov    $0x1,%cx
   f09a9:	e8 4a 00             	call   0xf09f6
   f09ac:	4b                   	dec    %bx
   f09ad:	75 ee                	jne    0xf099d
   f09af:	eb ba                	jmp    0xf096b
   f09b1:	59                   	pop    %cx
   f09b2:	b0 40                	mov    $0x40,%al
   f09b4:	ee                   	out    %al,(%dx)
   f09b5:	90                   	nop
   f09b6:	90                   	nop
   f09b7:	c3                   	ret
   f09b8:	4a                   	dec    %dx
   f09b9:	90                   	nop
   f09ba:	ec                   	in     (%dx),%al
   f09bb:	90                   	nop
   f09bc:	42                   	inc    %dx
   f09bd:	80 3e af 03 01       	cmpb   $0x1,0x3af
   f09c2:	74 04                	je     0xf09c8
   f09c4:	3c ff                	cmp    $0xff,%al
   f09c6:	74 de                	je     0xf09a6
   f09c8:	eb ba                	jmp    0xf0984
   f09ca:	51                   	push   %cx
   f09cb:	b9 06 00             	mov    $0x6,%cx
   f09ce:	e8 25 00             	call   0xf09f6
   f09d1:	eb de                	jmp    0xf09b1
   f09d3:	53                   	push   %bx
   f09d4:	51                   	push   %cx
   f09d5:	32 e4                	xor    %ah,%ah
   f09d7:	b3 10                	mov    $0x10,%bl
   f09d9:	f6 f3                	div    %bl
   f09db:	50                   	push   %ax
   f09dc:	d0 e0                	shl    $1,%al
   f09de:	d0 e0                	shl    $1,%al
   f09e0:	d0 e0                	shl    $1,%al
   f09e2:	d0 e0                	shl    $1,%al
   f09e4:	02 c4                	add    %ah,%al
   f09e6:	8a d8                	mov    %al,%bl
   f09e8:	58                   	pop    %ax
   f09e9:	8a c8                	mov    %al,%cl
   f09eb:	b0 06                	mov    $0x6,%al
   f09ed:	f6 e1                	mul    %cl
   f09ef:	2a d8                	sub    %al,%bl
   f09f1:	8a c3                	mov    %bl,%al
   f09f3:	59                   	pop    %cx
   f09f4:	5b                   	pop    %bx
   f09f5:	c3                   	ret
   f09f6:	53                   	push   %bx
   f09f7:	51                   	push   %cx
   f09f8:	a1 06 05             	mov    0x506,%ax
   f09fb:	8b 1e 04 05          	mov    0x504,%bx
   f09ff:	2d 01 00             	sub    $0x1,%ax
   f0a02:	83 db 00             	sbb    $0x0,%bx
   f0a05:	90                   	nop
   f0a06:	90                   	nop
   f0a07:	3d 00 00             	cmp    $0x0,%ax
   f0a0a:	75 f3                	jne    0xf09ff
   f0a0c:	83 fb 00             	cmp    $0x0,%bx
   f0a0f:	75 ee                	jne    0xf09ff
   f0a11:	59                   	pop    %cx
   f0a12:	e2 e3                	loop   0xf09f7
   f0a14:	5b                   	pop    %bx
   f0a15:	c3                   	ret
   f0a16:	9c                   	pushf
   f0a17:	50                   	push   %ax
   f0a18:	53                   	push   %bx
   f0a19:	51                   	push   %cx
   f0a1a:	52                   	push   %dx
   f0a1b:	1e                   	push   %ds
   f0a1c:	06                   	push   %es
   f0a1d:	57                   	push   %di
   f0a1e:	56                   	push   %si
   f0a1f:	55                   	push   %bp
   f0a20:	8c c8                	mov    %cs,%ax
   f0a22:	8e d8                	mov    %ax,%ds
   f0a24:	8b 16 63 00          	mov    0x63,%dx
   f0a28:	ec                   	in     (%dx),%al
   f0a29:	a8 08                	test   $0x8,%al
   f0a2b:	75 16                	jne    0xf0a43
   f0a2d:	4a                   	dec    %dx
   f0a2e:	e8 99 ff             	call   0xf09ca
   f0a31:	bb ff ff             	mov    $0xffff,%bx
   f0a34:	8b 16 63 00          	mov    0x63,%dx
   f0a38:	ec                   	in     (%dx),%al
   f0a39:	a8 04                	test   $0x4,%al
   f0a3b:	74 08                	je     0xf0a45
   f0a3d:	4b                   	dec    %bx
   f0a3e:	75 f4                	jne    0xf0a34
   f0a40:	e9 ed 00             	jmp    0xf0b30
   f0a43:	eb 2b                	jmp    0xf0a70
   f0a45:	32 e4                	xor    %ah,%ah
   f0a47:	8b 16 61 00          	mov    0x61,%dx
   f0a4b:	ec                   	in     (%dx),%al
   f0a4c:	24 80                	and    $0x80,%al
   f0a4e:	d0 c0                	rol    $1,%al
   f0a50:	50                   	push   %ax
   f0a51:	1e                   	push   %ds
   f0a52:	53                   	push   %bx
   f0a53:	8b 1e 0e 05          	mov    0x50e,%bx
   f0a57:	0b 1e 10 05          	or     0x510,%bx
   f0a5b:	74 04                	je     0xf0a61
   f0a5d:	ff 1e 0e 05          	lcall  *0x50e
   f0a61:	5b                   	pop    %bx
   f0a62:	1f                   	pop    %ds
   f0a63:	8b 16 61 00          	mov    0x61,%dx
   f0a67:	b0 41                	mov    $0x41,%al
   f0a69:	ee                   	out    %al,(%dx)
   f0a6a:	eb 00                	jmp    0xf0a6c
   f0a6c:	58                   	pop    %ax
   f0a6d:	e9 c0 00             	jmp    0xf0b30
   f0a70:	80 3e c0 03 01       	cmpb   $0x1,0x3c0
   f0a75:	74 03                	je     0xf0a7a
   f0a77:	e9 9b 00             	jmp    0xf0b15
   f0a7a:	8c c8                	mov    %cs,%ax
   f0a7c:	8e c0                	mov    %ax,%es
   f0a7e:	a1 d9 03             	mov    0x3d9,%ax
   f0a81:	8b f8                	mov    %ax,%di
   f0a83:	fc                   	cld
   f0a84:	33 c9                	xor    %cx,%cx
   f0a86:	b1 20                	mov    $0x20,%cl
   f0a88:	bb ff ff             	mov    $0xffff,%bx
   f0a8b:	8b 16 63 00          	mov    0x63,%dx
   f0a8f:	ec                   	in     (%dx),%al
   f0a90:	24 0f                	and    $0xf,%al
   f0a92:	0c 0b                	or     $0xb,%al
   f0a94:	3c 0b                	cmp    $0xb,%al
   f0a96:	74 06                	je     0xf0a9e
   f0a98:	4b                   	dec    %bx
   f0a99:	75 f0                	jne    0xf0a8b
   f0a9b:	e9 92 00             	jmp    0xf0b30
   f0a9e:	8b 16 61 00          	mov    0x61,%dx
   f0aa2:	ec                   	in     (%dx),%al
   f0aa3:	aa                   	stos   %al,%es:(%di)
   f0aa4:	49                   	dec    %cx
   f0aa5:	3c 9f                	cmp    $0x9f,%al
   f0aa7:	74 0d                	je     0xf0ab6
   f0aa9:	fe 0e d8 03          	decb   0x3d8
   f0aad:	74 07                	je     0xf0ab6
   f0aaf:	83 f9 00             	cmp    $0x0,%cx
   f0ab2:	75 d4                	jne    0xf0a88
   f0ab4:	eb 58                	jmp    0xf0b0e
   f0ab6:	c6 06 d8 03 62       	movb   $0x62,0x3d8
   f0abb:	a0 dc 03             	mov    0x3dc,%al
   f0abe:	fe c0                	inc    %al
   f0ac0:	3c 21                	cmp    $0x21,%al
   f0ac2:	76 02                	jbe    0xf0ac6
   f0ac4:	32 c0                	xor    %al,%al
   f0ac6:	a2 dc 03             	mov    %al,0x3dc
   f0ac9:	3a 06 db 03          	cmp    0x3db,%al
   f0acd:	75 2b                	jne    0xf0afa
   f0acf:	80 3e 27 04 00       	cmpb   $0x0,0x427
   f0ad4:	74 0e                	je     0xf0ae4
   f0ad6:	80 3e 27 04 01       	cmpb   $0x1,0x427
   f0adb:	74 0c                	je     0xf0ae9
   f0add:	c6 06 27 04 03       	movb   $0x3,0x427
   f0ae2:	eb 05                	jmp    0xf0ae9
   f0ae4:	c6 06 27 04 01       	movb   $0x1,0x427
   f0ae9:	a0 db 03             	mov    0x3db,%al
   f0aec:	fe c0                	inc    %al
   f0aee:	a2 db 03             	mov    %al,0x3db
   f0af1:	3c 21                	cmp    $0x21,%al
   f0af3:	76 05                	jbe    0xf0afa
   f0af5:	c6 06 db 03 00       	movb   $0x0,0x3db
   f0afa:	33 db                	xor    %bx,%bx
   f0afc:	8a 1e dc 03          	mov    0x3dc,%bl
   f0b00:	d1 e3                	shl    $1,%bx
   f0b02:	8b bf e0 03          	mov    0x3e0(%bx),%di
   f0b06:	83 f9 00             	cmp    $0x0,%cx
   f0b09:	74 03                	je     0xf0b0e
   f0b0b:	e9 7a ff             	jmp    0xf0a88
   f0b0e:	8b c7                	mov    %di,%ax
   f0b10:	a3 d9 03             	mov    %ax,0x3d9
   f0b13:	eb 1b                	jmp    0xf0b30
   f0b15:	8b 16 63 00          	mov    0x63,%dx
   f0b19:	ec                   	in     (%dx),%al
   f0b1a:	24 0f                	and    $0xf,%al
   f0b1c:	0c 0b                	or     $0xb,%al
   f0b1e:	3c 0b                	cmp    $0xb,%al
   f0b20:	74 02                	je     0xf0b24
   f0b22:	eb 0f                	jmp    0xf0b33
   f0b24:	80 3e 03 05 01       	cmpb   $0x1,0x503
   f0b29:	74 05                	je     0xf0b30
   f0b2b:	8b 16 61 00          	mov    0x61,%dx
   f0b2f:	ec                   	in     (%dx),%al
   f0b30:	eb 1d                	jmp    0xf0b4f
   f0b32:	90                   	nop
   f0b33:	80 3e f8 00 01       	cmpb   $0x1,0xf8
   f0b38:	75 03                	jne    0xf0b3d
   f0b3a:	e9 75 01             	jmp    0xf0cb2
   f0b3d:	80 3e f7 00 01       	cmpb   $0x1,0xf7
   f0b42:	75 03                	jne    0xf0b47
   f0b44:	e9 d0 00             	jmp    0xf0c17
   f0b47:	ba d0 00             	mov    $0xd0,%dx
   f0b4a:	ec                   	in     (%dx),%al
   f0b4b:	a8 02                	test   $0x2,%al
   f0b4d:	75 17                	jne    0xf0b66
   f0b4f:	c6 06 08 05 01       	movb   $0x1,0x508
   f0b54:	c6 06 f8 00 01       	movb   $0x1,0xf8
   f0b59:	b0 05                	mov    $0x5,%al
   f0b5b:	ba d4 00             	mov    $0xd4,%dx
   f0b5e:	ee                   	out    %al,(%dx)
   f0b5f:	eb 00                	jmp    0xf0b61
   f0b61:	32 c0                	xor    %al,%al
   f0b63:	e9 4c 01             	jmp    0xf0cb2
   f0b66:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   f0b6b:	74 67                	je     0xf0bd4
   f0b6d:	a1 15 05             	mov    0x515,%ax
   f0b70:	8b 16 17 05          	mov    0x517,%dx
   f0b74:	e8 98 fb             	call   0xf070f
   f0b77:	8a c2                	mov    %dl,%al
   f0b79:	e8 a2 fb             	call   0xf071e
   f0b7c:	a2 12 05             	mov    %al,0x512
   f0b7f:	8a c5                	mov    %ch,%al
   f0b81:	e8 9a fb             	call   0xf071e
   f0b84:	a2 13 05             	mov    %al,0x513
   f0b87:	8a c1                	mov    %cl,%al
   f0b89:	e8 92 fb             	call   0xf071e
   f0b8c:	a2 14 05             	mov    %al,0x514
   f0b8f:	06                   	push   %es
   f0b90:	1e                   	push   %ds
   f0b91:	33 db                	xor    %bx,%bx
   f0b93:	8b 1e ef 00          	mov    0xef,%bx
   f0b97:	d0 e3                	shl    $1,%bl
   f0b99:	81 3e 01 01 30 09    	cmpw   $0x930,0x101
   f0b9f:	75 0f                	jne    0xf0bb0
   f0ba1:	8b bf 87 01          	mov    0x187(%bx),%di
   f0ba5:	b8 ff ff             	mov    $0xffff,%ax
   f0ba8:	83 c7 10             	add    $0x10,%di
   f0bab:	83 c7 0c             	add    $0xc,%di
   f0bae:	eb 0d                	jmp    0xf0bbd
   f0bb0:	8b bf 07 01          	mov    0x107(%bx),%di
   f0bb4:	b8 ff ff             	mov    $0xffff,%ax
   f0bb7:	83 c7 10             	add    $0x10,%di
   f0bba:	83 c7 0c             	add    $0xc,%di
   f0bbd:	8e c0                	mov    %ax,%es
   f0bbf:	be 12 05             	mov    $0x512,%si
   f0bc2:	fc                   	cld
   f0bc3:	b9 03 00             	mov    $0x3,%cx
   f0bc6:	f3 a6                	repz cmpsb %es:(%di),%ds:(%si)
   f0bc8:	83 f9 00             	cmp    $0x0,%cx
   f0bcb:	74 05                	je     0xf0bd2
   f0bcd:	1f                   	pop    %ds
   f0bce:	07                   	pop    %es
   f0bcf:	e9 7d ff             	jmp    0xf0b4f
   f0bd2:	1f                   	pop    %ds
   f0bd3:	07                   	pop    %es
   f0bd4:	a1 ef 00             	mov    0xef,%ax
   f0bd7:	40                   	inc    %ax
   f0bd8:	3b 06 fa 00          	cmp    0xfa,%ax
   f0bdc:	76 02                	jbe    0xf0be0
   f0bde:	32 c0                	xor    %al,%al
   f0be0:	a3 ef 00             	mov    %ax,0xef
   f0be3:	3b 06 ed 00          	cmp    0xed,%ax
   f0be7:	74 0c                	je     0xf0bf5
   f0be9:	83 06 15 05 01       	addw   $0x1,0x515
   f0bee:	83 16 17 05 00       	adcw   $0x0,0x517
   f0bf3:	eb 22                	jmp    0xf0c17
   f0bf5:	c6 06 08 05 01       	movb   $0x1,0x508
   f0bfa:	c6 06 f8 00 01       	movb   $0x1,0xf8
   f0bff:	a1 ef 00             	mov    0xef,%ax
   f0c02:	3c 00                	cmp    $0x0,%al
   f0c04:	74 08                	je     0xf0c0e
   f0c06:	fe c8                	dec    %al
   f0c08:	a3 ef 00             	mov    %ax,0xef
   f0c0b:	e9 a4 00             	jmp    0xf0cb2
   f0c0e:	a1 fa 00             	mov    0xfa,%ax
   f0c11:	a3 ef 00             	mov    %ax,0xef
   f0c14:	e9 9b 00             	jmp    0xf0cb2
   f0c17:	c6 06 f8 00 00       	movb   $0x0,0xf8
   f0c1c:	8b 1e ef 00          	mov    0xef,%bx
   f0c20:	d0 e3                	shl    $1,%bl
   f0c22:	81 3e 01 01 30 09    	cmpw   $0x930,0x101
   f0c28:	75 10                	jne    0xf0c3a
   f0c2a:	8b 87 87 01          	mov    0x187(%bx),%ax
   f0c2e:	a3 d3 00             	mov    %ax,0xd3
   f0c31:	8b 87 c7 01          	mov    0x1c7(%bx),%ax
   f0c35:	a3 d1 00             	mov    %ax,0xd1
   f0c38:	eb 0e                	jmp    0xf0c48
   f0c3a:	8b 87 07 01          	mov    0x107(%bx),%ax
   f0c3e:	a3 d3 00             	mov    %ax,0xd3
   f0c41:	8b 87 47 01          	mov    0x147(%bx),%ax
   f0c45:	a3 d1 00             	mov    %ax,0xd1
   f0c48:	b0 40                	mov    $0x40,%al
   f0c4a:	8b 16 5f 00          	mov    0x5f,%dx
   f0c4e:	83 c2 0f             	add    $0xf,%dx
   f0c51:	ee                   	out    %al,(%dx)
   f0c52:	eb 00                	jmp    0xf0c54
   f0c54:	a1 01 01             	mov    0x101,%ax
   f0c57:	3d 00 08             	cmp    $0x800,%ax
   f0c5a:	75 0a                	jne    0xf0c66
   f0c5c:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   f0c61:	74 03                	je     0xf0c66
   f0c63:	05 10 00             	add    $0x10,%ax
   f0c66:	d1 e8                	shr    $1,%ax
   f0c68:	48                   	dec    %ax
   f0c69:	ba c6 00             	mov    $0xc6,%dx
   f0c6c:	e6 d8                	out    %al,$0xd8
   f0c6e:	eb 00                	jmp    0xf0c70
   f0c70:	ee                   	out    %al,(%dx)
   f0c71:	eb 00                	jmp    0xf0c73
   f0c73:	8a c4                	mov    %ah,%al
   f0c75:	ee                   	out    %al,(%dx)
   f0c76:	eb 00                	jmp    0xf0c78
   f0c78:	a1 d1 00             	mov    0xd1,%ax
   f0c7b:	8a c4                	mov    %ah,%al
   f0c7d:	d0 e8                	shr    $1,%al
   f0c7f:	d0 e8                	shr    $1,%al
   f0c81:	d0 e8                	shr    $1,%al
   f0c83:	d0 e8                	shr    $1,%al
   f0c85:	d0 e8                	shr    $1,%al
   f0c87:	a1 d3 00             	mov    0xd3,%ax
   f0c8a:	d1 d8                	rcr    $1,%ax
   f0c8c:	ba c4 00             	mov    $0xc4,%dx
   f0c8f:	ee                   	out    %al,(%dx)
   f0c90:	eb 00                	jmp    0xf0c92
   f0c92:	8a c4                	mov    %ah,%al
   f0c94:	ee                   	out    %al,(%dx)
   f0c95:	eb 00                	jmp    0xf0c97
   f0c97:	ba 8b 00             	mov    $0x8b,%dx
   f0c9a:	b0 10                	mov    $0x10,%al
   f0c9c:	ee                   	out    %al,(%dx)
   f0c9d:	eb 00                	jmp    0xf0c9f
   f0c9f:	b0 45                	mov    $0x45,%al
   f0ca1:	ba d6 00             	mov    $0xd6,%dx
   f0ca4:	ee                   	out    %al,(%dx)
   f0ca5:	eb 00                	jmp    0xf0ca7
   f0ca7:	b0 01                	mov    $0x1,%al
   f0ca9:	ba d4 00             	mov    $0xd4,%dx
   f0cac:	ee                   	out    %al,(%dx)
   f0cad:	eb 00                	jmp    0xf0caf
   f0caf:	eb 01                	jmp    0xf0cb2
   f0cb1:	90                   	nop
   f0cb2:	80 3e f7 00 01       	cmpb   $0x1,0xf7
   f0cb7:	74 10                	je     0xf0cc9
   f0cb9:	2e a0 c6 00          	mov    %cs:0xc6,%al
   f0cbd:	3c 0b                	cmp    $0xb,%al
   f0cbf:	75 04                	jne    0xf0cc5
   f0cc1:	b0 20                	mov    $0x20,%al
   f0cc3:	e6 a0                	out    %al,$0xa0
   f0cc5:	b0 20                	mov    $0x20,%al
   f0cc7:	e6 20                	out    %al,$0x20
   f0cc9:	c6 06 f7 00 00       	movb   $0x0,0xf7
   f0cce:	5d                   	pop    %bp
   f0ccf:	5e                   	pop    %si
   f0cd0:	5f                   	pop    %di
   f0cd1:	07                   	pop    %es
   f0cd2:	1f                   	pop    %ds
   f0cd3:	5a                   	pop    %dx
   f0cd4:	59                   	pop    %cx
   f0cd5:	5b                   	pop    %bx
   f0cd6:	58                   	pop    %ax
   f0cd7:	9d                   	popf
   f0cd8:	cf                   	iret
   f0cd9:	e8 22 06             	call   0xf12fe
   f0cdc:	e8 30 06             	call   0xf130f
   f0cdf:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f0ce4:	26 c4 77 12          	les    %es:0x12(%bx),%si
   f0ce8:	b8 0a 00             	mov    $0xa,%ax
   f0ceb:	8b f8                	mov    %ax,%di
   f0ced:	46                   	inc    %si
   f0cee:	26 8a 04             	mov    %es:(%si),%al
   f0cf1:	3c 0d                	cmp    $0xd,%al
   f0cf3:	74 40                	je     0xf0d35
   f0cf5:	3c 0a                	cmp    $0xa,%al
   f0cf7:	74 3c                	je     0xf0d35
   f0cf9:	3c 2f                	cmp    $0x2f,%al
   f0cfb:	75 f0                	jne    0xf0ced
   f0cfd:	46                   	inc    %si
   f0cfe:	26 8a 04             	mov    %es:(%si),%al
   f0d01:	24 df                	and    $0xdf,%al
   f0d03:	3c 50                	cmp    $0x50,%al
   f0d05:	74 30                	je     0xf0d37
   f0d07:	3c 44                	cmp    $0x44,%al
   f0d09:	74 35                	je     0xf0d40
   f0d0b:	3c 54                	cmp    $0x54,%al
   f0d0d:	74 3a                	je     0xf0d49
   f0d0f:	3c 49                	cmp    $0x49,%al
   f0d11:	74 3f                	je     0xf0d52
   f0d13:	3c 4d                	cmp    $0x4d,%al
   f0d15:	74 44                	je     0xf0d5b
   f0d17:	3c 55                	cmp    $0x55,%al
   f0d19:	74 49                	je     0xf0d64
   f0d1b:	3c 41                	cmp    $0x41,%al
   f0d1d:	74 53                	je     0xf0d72
   f0d1f:	3c 4e                	cmp    $0x4e,%al
   f0d21:	74 58                	je     0xf0d7b
   f0d23:	3c 48                	cmp    $0x48,%al
   f0d25:	74 5c                	je     0xf0d83
   f0d27:	3c 0d                	cmp    $0xd,%al
   f0d29:	74 5e                	je     0xf0d89
   f0d2b:	3c 0a                	cmp    $0xa,%al
   f0d2d:	74 5a                	je     0xf0d89
   f0d2f:	3c 5e                	cmp    $0x5e,%al
   f0d31:	74 56                	je     0xf0d89
   f0d33:	eb c8                	jmp    0xf0cfd
   f0d35:	eb 52                	jmp    0xf0d89
   f0d37:	e8 39 03             	call   0xf1073
   f0d3a:	3c 01                	cmp    $0x1,%al
   f0d3c:	74 4b                	je     0xf0d89
   f0d3e:	eb bd                	jmp    0xf0cfd
   f0d40:	e8 3c 03             	call   0xf107f
   f0d43:	3c 01                	cmp    $0x1,%al
   f0d45:	74 42                	je     0xf0d89
   f0d47:	eb b4                	jmp    0xf0cfd
   f0d49:	e8 6d 03             	call   0xf10b9
   f0d4c:	3c 01                	cmp    $0x1,%al
   f0d4e:	74 39                	je     0xf0d89
   f0d50:	eb ab                	jmp    0xf0cfd
   f0d52:	e8 82 03             	call   0xf10d7
   f0d55:	3c 01                	cmp    $0x1,%al
   f0d57:	74 30                	je     0xf0d89
   f0d59:	eb a2                	jmp    0xf0cfd
   f0d5b:	e8 06 04             	call   0xf1164
   f0d5e:	3c 01                	cmp    $0x1,%al
   f0d60:	74 27                	je     0xf0d89
   f0d62:	eb 99                	jmp    0xf0cfd
   f0d64:	c6 06 ed 04 01       	movb   $0x1,0x4ed
   f0d69:	e8 81 04             	call   0xf11ed
   f0d6c:	3c 01                	cmp    $0x1,%al
   f0d6e:	74 19                	je     0xf0d89
   f0d70:	eb 8b                	jmp    0xf0cfd
   f0d72:	e8 f5 04             	call   0xf126a
   f0d75:	3c 01                	cmp    $0x1,%al
   f0d77:	74 10                	je     0xf0d89
   f0d79:	eb 82                	jmp    0xf0cfd
   f0d7b:	c6 06 ff 04 01       	movb   $0x1,0x4ff
   f0d80:	e9 7a ff             	jmp    0xf0cfd
   f0d83:	e8 1c 05             	call   0xf12a2
   f0d86:	e9 74 ff             	jmp    0xf0cfd
   f0d89:	a0 c3 03             	mov    0x3c3,%al
   f0d8c:	3c ff                	cmp    $0xff,%al
   f0d8e:	74 06                	je     0xf0d96
   f0d90:	3a 06 cb 00          	cmp    0xcb,%al
   f0d94:	76 05                	jbe    0xf0d9b
   f0d96:	c6 06 c3 03 00       	movb   $0x0,0x3c3
   f0d9b:	e8 60 05             	call   0xf12fe
   f0d9e:	c6 06 f4 04 01       	movb   $0x1,0x4f4
   f0da3:	50                   	push   %ax
   f0da4:	a1 cd 00             	mov    0xcd,%ax
   f0da7:	48                   	dec    %ax
   f0da8:	a3 fa 00             	mov    %ax,0xfa
   f0dab:	58                   	pop    %ax
   f0dac:	06                   	push   %es
   f0dad:	50                   	push   %ax
   f0dae:	53                   	push   %bx
   f0daf:	52                   	push   %dx
   f0db0:	55                   	push   %bp
   f0db1:	8c c8                	mov    %cs,%ax
   f0db3:	8e d8                	mov    %ax,%ds
   f0db5:	b8 89 39             	mov    $0x3989,%ax
   f0db8:	8b d0                	mov    %ax,%dx
   f0dba:	b4 25                	mov    $0x25,%ah
   f0dbc:	a0 c6 00             	mov    0xc6,%al
   f0dbf:	3c 0b                	cmp    $0xb,%al
   f0dc1:	74 28                	je     0xf0deb
   f0dc3:	3c 04                	cmp    $0x4,%al
   f0dc5:	74 0f                	je     0xf0dd6
   f0dc7:	3c 05                	cmp    $0x5,%al
   f0dc9:	74 12                	je     0xf0ddd
   f0dcb:	3c 07                	cmp    $0x7,%al
   f0dcd:	74 15                	je     0xf0de4
   f0dcf:	b0 0b                	mov    $0xb,%al
   f0dd1:	cd 21                	int    $0x21
   f0dd3:	eb 29                	jmp    0xf0dfe
   f0dd5:	90                   	nop
   f0dd6:	b0 0c                	mov    $0xc,%al
   f0dd8:	cd 21                	int    $0x21
   f0dda:	eb 22                	jmp    0xf0dfe
   f0ddc:	90                   	nop
   f0ddd:	b0 0d                	mov    $0xd,%al
   f0ddf:	cd 21                	int    $0x21
   f0de1:	eb 1b                	jmp    0xf0dfe
   f0de3:	90                   	nop
   f0de4:	b0 0f                	mov    $0xf,%al
   f0de6:	cd 21                	int    $0x21
   f0de8:	eb 14                	jmp    0xf0dfe
   f0dea:	90                   	nop
   f0deb:	b0 73                	mov    $0x73,%al
   f0ded:	cd 21                	int    $0x21
   f0def:	e4 a1                	in     $0xa1,%al
   f0df1:	22 06 c7 00          	and    0xc7,%al
   f0df5:	e6 a1                	out    %al,$0xa1
   f0df7:	a0 c8 00             	mov    0xc8,%al
   f0dfa:	e6 a0                	out    %al,$0xa0
   f0dfc:	eb 0d                	jmp    0xf0e0b
   f0dfe:	e4 21                	in     $0x21,%al
   f0e00:	22 06 c7 00          	and    0xc7,%al
   f0e04:	e6 21                	out    %al,$0x21
   f0e06:	a0 c8 00             	mov    0xc8,%al
   f0e09:	e6 20                	out    %al,$0x20
   f0e0b:	b8 30 09             	mov    $0x930,%ax
   f0e0e:	32 ff                	xor    %bh,%bh
   f0e10:	8a 1e cb 00          	mov    0xcb,%bl
   f0e14:	f7 e3                	mul    %bx
   f0e16:	bb 10 08             	mov    $0x810,%bx
   f0e19:	80 3e bf 03 00       	cmpb   $0x0,0x3bf
   f0e1e:	75 03                	jne    0xf0e23
   f0e20:	bb 00 08             	mov    $0x800,%bx
   f0e23:	f7 f3                	div    %bx
   f0e25:	a2 cc 00             	mov    %al,0xcc
   f0e28:	80 3e 09 05 01       	cmpb   $0x1,0x509
   f0e2d:	75 07                	jne    0xf0e36
   f0e2f:	bb 00 00             	mov    $0x0,%bx
   f0e32:	8b c3                	mov    %bx,%ax
   f0e34:	eb 0e                	jmp    0xf0e44
   f0e36:	80 3e 09 05 02       	cmpb   $0x2,0x509
   f0e3b:	75 02                	jne    0xf0e3f
   f0e3d:	eb 00                	jmp    0xf0e3f
   f0e3f:	bb 4c 3c             	mov    $0x3c4c,%bx
   f0e42:	8c c8                	mov    %cs,%ax
   f0e44:	b9 00 00             	mov    $0x0,%cx
   f0e47:	8a 0e cb 00          	mov    0xcb,%cl
   f0e4b:	c7 06 01 01 30 09    	movw   $0x930,0x101
   f0e51:	c7 06 03 01 30 09    	movw   $0x930,0x103
   f0e57:	bd 00 00             	mov    $0x0,%bp
   f0e5a:	e8 34 d1             	call   0xfdf91
   f0e5d:	80 3e 09 05 01       	cmpb   $0x1,0x509
   f0e62:	75 07                	jne    0xf0e6b
   f0e64:	bb 00 00             	mov    $0x0,%bx
   f0e67:	8b c3                	mov    %bx,%ax
   f0e69:	eb 05                	jmp    0xf0e70
   f0e6b:	8c c8                	mov    %cs,%ax
   f0e6d:	bb 4c 3c             	mov    $0x3c4c,%bx
   f0e70:	b9 00 00             	mov    $0x0,%cx
   f0e73:	8a 0e cc 00          	mov    0xcc,%cl
   f0e77:	c7 06 01 01 00 08    	movw   $0x800,0x101
   f0e7d:	c7 06 03 01 10 08    	movw   $0x810,0x103
   f0e83:	bd 00 00             	mov    $0x0,%bp
   f0e86:	e8 08 d1             	call   0xfdf91
   f0e89:	33 ff                	xor    %di,%di
   f0e8b:	bb 4c 3c             	mov    $0x3c4c,%bx
   f0e8e:	89 9d e0 03          	mov    %bx,0x3e0(%di)
   f0e92:	33 c9                	xor    %cx,%cx
   f0e94:	b1 21                	mov    $0x21,%cl
   f0e96:	47                   	inc    %di
   f0e97:	47                   	inc    %di
   f0e98:	83 c3 62             	add    $0x62,%bx
   f0e9b:	89 9d e0 03          	mov    %bx,0x3e0(%di)
   f0e9f:	e2 f5                	loop   0xf0e96
   f0ea1:	83 c3 62             	add    $0x62,%bx
   f0ea4:	89 1e 24 04          	mov    %bx,0x424
   f0ea8:	5d                   	pop    %bp
   f0ea9:	5a                   	pop    %dx
   f0eaa:	5b                   	pop    %bx
   f0eab:	58                   	pop    %ax
   f0eac:	07                   	pop    %es
   f0ead:	e8 2d fa             	call   0xf08dd
   f0eb0:	8b 16 61 00          	mov    0x61,%dx
   f0eb4:	b0 40                	mov    $0x40,%al
   f0eb6:	ee                   	out    %al,(%dx)
   f0eb7:	eb 00                	jmp    0xf0eb9
   f0eb9:	e8 90 fa             	call   0xf094c
   f0ebc:	3c ff                	cmp    $0xff,%al
   f0ebe:	75 07                	jne    0xf0ec7
   f0ec0:	e8 89 fa             	call   0xf094c
   f0ec3:	3c ff                	cmp    $0xff,%al
   f0ec5:	74 0c                	je     0xf0ed3
   f0ec7:	8a c3                	mov    %bl,%al
   f0ec9:	a8 40                	test   $0x40,%al
   f0ecb:	74 06                	je     0xf0ed3
   f0ecd:	e8 0d fa             	call   0xf08dd
   f0ed0:	e8 df e0             	call   0xfefb2
   f0ed3:	06                   	push   %es
   f0ed4:	8c c8                	mov    %cs,%ax
   f0ed6:	8e c0                	mov    %ax,%es
   f0ed8:	bf 9a 03             	mov    $0x39a,%di
   f0edb:	b9 0d 00             	mov    $0xd,%cx
   f0ede:	b0 00                	mov    $0x0,%al
   f0ee0:	fc                   	cld
   f0ee1:	aa                   	stos   %al,%es:(%di)
   f0ee2:	e2 fd                	loop   0xf0ee1
   f0ee4:	07                   	pop    %es
   f0ee5:	80 3e f3 04 00       	cmpb   $0x0,0x4f3
   f0eea:	74 00                	je     0xf0eec
   f0eec:	b8 4c 3c             	mov    $0x3c4c,%ax
   f0eef:	05 66 0d             	add    $0xd66,%ax
   f0ef2:	05 10 00             	add    $0x10,%ax
   f0ef5:	80 3e 09 05 01       	cmpb   $0x1,0x509
   f0efa:	74 16                	je     0xf0f12
   f0efc:	53                   	push   %bx
   f0efd:	50                   	push   %ax
   f0efe:	52                   	push   %dx
   f0eff:	32 e4                	xor    %ah,%ah
   f0f01:	a0 cb 00             	mov    0xcb,%al
   f0f04:	fe c0                	inc    %al
   f0f06:	bb 30 09             	mov    $0x930,%bx
   f0f09:	f7 e3                	mul    %bx
   f0f0b:	8b d8                	mov    %ax,%bx
   f0f0d:	5a                   	pop    %dx
   f0f0e:	58                   	pop    %ax
   f0f0f:	03 c3                	add    %bx,%ax
   f0f11:	5b                   	pop    %bx
   f0f12:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f0f17:	26 89 47 0e          	mov    %ax,%es:0xe(%bx)
   f0f1b:	8c c8                	mov    %cs,%ax
   f0f1d:	73 03                	jae    0xf0f22
   f0f1f:	80 c4 10             	add    $0x10,%ah
   f0f22:	26 89 47 10          	mov    %ax,%es:0x10(%bx)
   f0f26:	26 c6 47 01 00       	movb   $0x0,%es:0x1(%bx)
   f0f2b:	80 3e 09 05 01       	cmpb   $0x1,0x509
   f0f30:	75 17                	jne    0xf0f49
   f0f32:	06                   	push   %es
   f0f33:	53                   	push   %bx
   f0f34:	52                   	push   %dx
   f0f35:	50                   	push   %ax
   f0f36:	32 e4                	xor    %ah,%ah
   f0f38:	a0 cb 00             	mov    0xcb,%al
   f0f3b:	bb 30 09             	mov    $0x930,%bx
   f0f3e:	f7 e3                	mul    %bx
   f0f40:	8b d0                	mov    %ax,%dx
   f0f42:	e8 f1 04             	call   0xf1436
   f0f45:	58                   	pop    %ax
   f0f46:	5a                   	pop    %dx
   f0f47:	5b                   	pop    %bx
   f0f48:	07                   	pop    %es
   f0f49:	e9 50 cc             	jmp    0xfdb9c
   f0f4c:	bf 00 00             	mov    $0x0,%di
   f0f4f:	47                   	inc    %di
   f0f50:	47                   	inc    %di
   f0f51:	b8 ff 7f             	mov    $0x7fff,%ax
   f0f54:	ab                   	stos   %ax,%es:(%di)
   f0f55:	2e c4 1e 16 00       	les    %cs:0x16,%bx
   f0f5a:	33 c0                	xor    %ax,%ax
   f0f5c:	26 89 47 0e          	mov    %ax,%es:0xe(%bx)
   f0f60:	8c c8                	mov    %cs,%ax
   f0f62:	26 89 47 10          	mov    %ax,%es:0x10(%bx)
   f0f66:	26 c6 47 01 00       	movb   $0x0,%es:0x1(%bx)
   f0f6b:	26 c6 47 0d 00       	movb   $0x0,%es:0xd(%bx)
   f0f70:	e9 29 cc             	jmp    0xfdb9c
   f0f73:	46                   	inc    %si
   f0f74:	26 8a 04             	mov    %es:(%si),%al
   f0f77:	3c 2f                	cmp    $0x2f,%al
   f0f79:	74 1b                	je     0xf0f96
   f0f7b:	3c 20                	cmp    $0x20,%al
   f0f7d:	74 17                	je     0xf0f96
   f0f7f:	3c 0d                	cmp    $0xd,%al
   f0f81:	74 13                	je     0xf0f96
   f0f83:	3c 3a                	cmp    $0x3a,%al
   f0f85:	75 ec                	jne    0xf0f73
   f0f87:	46                   	inc    %si
   f0f88:	26 8a 04             	mov    %es:(%si),%al
   f0f8b:	3c 33                	cmp    $0x33,%al
   f0f8d:	74 0a                	je     0xf0f99
   f0f8f:	3c 32                	cmp    $0x32,%al
   f0f91:	74 06                	je     0xf0f99
   f0f93:	e9 dd 00             	jmp    0xf1073
   f0f96:	b0 01                	mov    $0x1,%al
   f0f98:	c3                   	ret
   f0f99:	24 0f                	and    $0xf,%al
   f0f9b:	a2 c2 00             	mov    %al,0xc2
   f0f9e:	46                   	inc    %si
   f0f9f:	26 8a 04             	mov    %es:(%si),%al
   f0fa2:	a2 c3 00             	mov    %al,0xc3
   f0fa5:	46                   	inc    %si
   f0fa6:	26 8a 04             	mov    %es:(%si),%al
   f0fa9:	a2 c4 00             	mov    %al,0xc4
   f0fac:	a0 c3 00             	mov    0xc3,%al
   f0faf:	d0 e8                	shr    $1,%al
   f0fb1:	d0 e8                	shr    $1,%al
   f0fb3:	d0 e8                	shr    $1,%al
   f0fb5:	d0 e8                	shr    $1,%al
   f0fb7:	3c 03                	cmp    $0x3,%al
   f0fb9:	74 0b                	je     0xf0fc6
   f0fbb:	3c 04                	cmp    $0x4,%al
   f0fbd:	74 14                	je     0xf0fd3
   f0fbf:	3c 06                	cmp    $0x6,%al
   f0fc1:	74 10                	je     0xf0fd3
   f0fc3:	e9 ad 00             	jmp    0xf1073
   f0fc6:	33 c0                	xor    %ax,%ax
   f0fc8:	a0 c3 00             	mov    0xc3,%al
   f0fcb:	e8 a8 00             	call   0xf1076
   f0fce:	a2 c3 00             	mov    %al,0xc3
   f0fd1:	eb 0d                	jmp    0xf0fe0
   f0fd3:	33 c0                	xor    %ax,%ax
   f0fd5:	a0 c3 00             	mov    0xc3,%al
   f0fd8:	e8 9b 00             	call   0xf1076
   f0fdb:	04 90                	add    $0x90,%al
   f0fdd:	a2 c3 00             	mov    %al,0xc3
   f0fe0:	a0 c4 00             	mov    0xc4,%al
   f0fe3:	d0 e8                	shr    $1,%al
   f0fe5:	d0 e8                	shr    $1,%al
   f0fe7:	d0 e8                	shr    $1,%al
   f0fe9:	d0 e8                	shr    $1,%al
   f0feb:	3c 03                	cmp    $0x3,%al
   f0fed:	74 0a                	je     0xf0ff9
   f0fef:	3c 04                	cmp    $0x4,%al
   f0ff1:	74 1b                	je     0xf100e
   f0ff3:	3c 06                	cmp    $0x6,%al
   f0ff5:	74 17                	je     0xf100e
   f0ff7:	eb 7a                	jmp    0xf1073
   f0ff9:	33 c0                	xor    %ax,%ax
   f0ffb:	a0 c4 00             	mov    0xc4,%al
   f0ffe:	e8 75 00             	call   0xf1076
   f1001:	d0 e8                	shr    $1,%al
   f1003:	d0 e8                	shr    $1,%al
   f1005:	d0 e8                	shr    $1,%al
   f1007:	d0 e8                	shr    $1,%al
   f1009:	a2 c4 00             	mov    %al,0xc4
   f100c:	eb 15                	jmp    0xf1023
   f100e:	33 c0                	xor    %ax,%ax
   f1010:	a0 c4 00             	mov    0xc4,%al
   f1013:	e8 60 00             	call   0xf1076
   f1016:	d0 e8                	shr    $1,%al
   f1018:	d0 e8                	shr    $1,%al
   f101a:	d0 e8                	shr    $1,%al
   f101c:	d0 e8                	shr    $1,%al
   f101e:	04 09                	add    $0x9,%al
   f1020:	a2 c4 00             	mov    %al,0xc4
   f1023:	8a 26 c2 00          	mov    0xc2,%ah
   f1027:	33 db                	xor    %bx,%bx
   f1029:	a0 c3 00             	mov    0xc3,%al
   f102c:	8a 1e c4 00          	mov    0xc4,%bl
   f1030:	03 c3                	add    %bx,%ax
   f1032:	50                   	push   %ax
   f1033:	57                   	push   %di
   f1034:	06                   	push   %es
   f1035:	1e                   	push   %ds
   f1036:	07                   	pop    %es
   f1037:	b9 0c 00             	mov    $0xc,%cx
   f103a:	bf aa 00             	mov    $0xaa,%di
   f103d:	fc                   	cld
   f103e:	f2 af                	repnz scas %es:(%di),%ax
   f1040:	07                   	pop    %es
   f1041:	5f                   	pop    %di
   f1042:	58                   	pop    %ax
   f1043:	74 03                	je     0xf1048
   f1045:	b8 20 02             	mov    $0x220,%ax
   f1048:	a3 5f 00             	mov    %ax,0x5f
   f104b:	8b d8                	mov    %ax,%bx
   f104d:	81 c3 08 04          	add    $0x408,%bx
   f1051:	89 1e 61 00          	mov    %bx,0x61
   f1055:	8b d8                	mov    %ax,%bx
   f1057:	81 c3 09 04          	add    $0x409,%bx
   f105b:	89 1e 63 00          	mov    %bx,0x63
   f105f:	8b d8                	mov    %ax,%bx
   f1061:	81 c3 09 04          	add    $0x409,%bx
   f1065:	89 1e 65 00          	mov    %bx,0x65
   f1069:	8b d8                	mov    %ax,%bx
   f106b:	81 c3 0a 04          	add    $0x40a,%bx
   f106f:	89 1e 67 00          	mov    %bx,0x67
   f1073:	b0 00                	mov    $0x0,%al
   f1075:	c3                   	ret
   f1076:	d0 e0                	shl    $1,%al
   f1078:	d0 e0                	shl    $1,%al
   f107a:	d0 e0                	shl    $1,%al
   f107c:	d0 e0                	shl    $1,%al
   f107e:	c3                   	ret
   f107f:	46                   	inc    %si
   f1080:	26 8a 04             	mov    %es:(%si),%al
   f1083:	3c 2f                	cmp    $0x2f,%al
   f1085:	74 28                	je     0xf10af
   f1087:	3c 20                	cmp    $0x20,%al
   f1089:	74 24                	je     0xf10af
   f108b:	3c 0d                	cmp    $0xd,%al
   f108d:	74 20                	je     0xf10af
   f108f:	3c 3a                	cmp    $0x3a,%al
   f1091:	75 ec                	jne    0xf107f
   f1093:	46                   	inc    %si
   f1094:	b9 08 00             	mov    $0x8,%cx
   f1097:	26 8a 04             	mov    %es:(%si),%al
   f109a:	3c 20                	cmp    $0x20,%al
   f109c:	74 11                	je     0xf10af
   f109e:	3c 0d                	cmp    $0xd,%al
   f10a0:	74 0d                	je     0xf10af
   f10a2:	3c 0a                	cmp    $0xa,%al
   f10a4:	74 09                	je     0xf10af
   f10a6:	88 05                	mov    %al,(%di)
   f10a8:	46                   	inc    %si
   f10a9:	47                   	inc    %di
   f10aa:	e2 eb                	loop   0xf1097
   f10ac:	b0 00                	mov    $0x0,%al
   f10ae:	c3                   	ret
   f10af:	b0 20                	mov    $0x20,%al
   f10b1:	88 05                	mov    %al,(%di)
   f10b3:	47                   	inc    %di
   f10b4:	e2 f9                	loop   0xf10af
   f10b6:	b0 00                	mov    $0x0,%al
   f10b8:	c3                   	ret
   f10b9:	46                   	inc    %si
   f10ba:	26 8a 04             	mov    %es:(%si),%al
   f10bd:	3c 2f                	cmp    $0x2f,%al
   f10bf:	74 13                	je     0xf10d4
   f10c1:	3c 20                	cmp    $0x20,%al
   f10c3:	74 0f                	je     0xf10d4
   f10c5:	3c 0d                	cmp    $0xd,%al
   f10c7:	74 0b                	je     0xf10d4
   f10c9:	3c 3a                	cmp    $0x3a,%al
   f10cb:	75 ec                	jne    0xf10b9
   f10cd:	46                   	inc    %si
   f10ce:	26 8a 04             	mov    %es:(%si),%al
   f10d1:	b0 00                	mov    $0x0,%al
   f10d3:	c3                   	ret
   f10d4:	b0 01                	mov    $0x1,%al
   f10d6:	c3                   	ret
   f10d7:	46                   	inc    %si
   f10d8:	26 8a 04             	mov    %es:(%si),%al
   f10db:	3c 2f                	cmp    $0x2f,%al
   f10dd:	74 3a                	je     0xf1119
   f10df:	3c 20                	cmp    $0x20,%al
   f10e1:	74 36                	je     0xf1119
   f10e3:	3c 0d                	cmp    $0xd,%al
   f10e5:	74 32                	je     0xf1119
   f10e7:	3c 3a                	cmp    $0x3a,%al
   f10e9:	75 ec                	jne    0xf10d7
   f10eb:	46                   	inc    %si
   f10ec:	26 8a 04             	mov    %es:(%si),%al
   f10ef:	3c 34                	cmp    $0x34,%al
   f10f1:	74 29                	je     0xf111c
   f10f3:	3c 35                	cmp    $0x35,%al
   f10f5:	74 37                	je     0xf112e
   f10f7:	3c 37                	cmp    $0x37,%al
   f10f9:	74 45                	je     0xf1140
   f10fb:	3c 31                	cmp    $0x31,%al
   f10fd:	75 08                	jne    0xf1107
   f10ff:	46                   	inc    %si
   f1100:	26 8a 04             	mov    %es:(%si),%al
   f1103:	3c 31                	cmp    $0x31,%al
   f1105:	74 4b                	je     0xf1152
   f1107:	c6 06 c6 00 03       	movb   $0x3,0xc6
   f110c:	c6 06 c8 00 63       	movb   $0x63,0xc8
   f1111:	c6 06 c7 00 f7       	movb   $0xf7,0xc7
   f1116:	b0 00                	mov    $0x0,%al
   f1118:	c3                   	ret
   f1119:	b0 01                	mov    $0x1,%al
   f111b:	c3                   	ret
   f111c:	c6 06 c6 00 04       	movb   $0x4,0xc6
   f1121:	c6 06 c8 00 64       	movb   $0x64,0xc8
   f1126:	c6 06 c7 00 ef       	movb   $0xef,0xc7
   f112b:	b0 00                	mov    $0x0,%al
   f112d:	c3                   	ret
   f112e:	c6 06 c6 00 05       	movb   $0x5,0xc6
   f1133:	c6 06 c8 00 65       	movb   $0x65,0xc8
   f1138:	c6 06 c7 00 df       	movb   $0xdf,0xc7
   f113d:	b0 00                	mov    $0x0,%al
   f113f:	c3                   	ret
   f1140:	c6 06 c6 00 07       	movb   $0x7,0xc6
   f1145:	c6 06 c8 00 67       	movb   $0x67,0xc8
   f114a:	c6 06 c7 00 7f       	movb   $0x7f,0xc7
   f114f:	b0 00                	mov    $0x0,%al
   f1151:	c3                   	ret
   f1152:	c6 06 c6 00 0b       	movb   $0xb,0xc6
   f1157:	c6 06 c8 00 63       	movb   $0x63,0xc8
   f115c:	c6 06 c7 00 f7       	movb   $0xf7,0xc7
   f1161:	b0 00                	mov    $0x0,%al
   f1163:	c3                   	ret
   f1164:	46                   	inc    %si
   f1165:	26 8a 04             	mov    %es:(%si),%al
   f1168:	3c 2f                	cmp    $0x2f,%al
   f116a:	74 35                	je     0xf11a1
   f116c:	3c 20                	cmp    $0x20,%al
   f116e:	74 31                	je     0xf11a1
   f1170:	3c 0d                	cmp    $0xd,%al
   f1172:	74 2d                	je     0xf11a1
   f1174:	3c 3a                	cmp    $0x3a,%al
   f1176:	75 ec                	jne    0xf1164
   f1178:	46                   	inc    %si
   f1179:	26 8a 04             	mov    %es:(%si),%al
   f117c:	2c 30                	sub    $0x30,%al
   f117e:	a2 c9 00             	mov    %al,0xc9
   f1181:	46                   	inc    %si
   f1182:	26 8a 04             	mov    %es:(%si),%al
   f1185:	3c 00                	cmp    $0x0,%al
   f1187:	74 0e                	je     0xf1197
   f1189:	3c 20                	cmp    $0x20,%al
   f118b:	74 0a                	je     0xf1197
   f118d:	3c ff                	cmp    $0xff,%al
   f118f:	74 06                	je     0xf1197
   f1191:	3c 0d                	cmp    $0xd,%al
   f1193:	74 02                	je     0xf1197
   f1195:	eb 0d                	jmp    0xf11a4
   f1197:	4e                   	dec    %si
   f1198:	a0 c9 00             	mov    0xc9,%al
   f119b:	3c 02                	cmp    $0x2,%al
   f119d:	72 35                	jb     0xf11d4
   f119f:	eb 41                	jmp    0xf11e2
   f11a1:	b0 01                	mov    $0x1,%al
   f11a3:	c3                   	ret
   f11a4:	2c 30                	sub    $0x30,%al
   f11a6:	a2 ca 00             	mov    %al,0xca
   f11a9:	8a 26 c9 00          	mov    0xc9,%ah
   f11ad:	d0 e4                	shl    $1,%ah
   f11af:	d0 e4                	shl    $1,%ah
   f11b1:	d0 e4                	shl    $1,%ah
   f11b3:	d0 e4                	shl    $1,%ah
   f11b5:	a0 ca 00             	mov    0xca,%al
   f11b8:	0a c4                	or     %ah,%al
   f11ba:	e8 16 f8             	call   0xf09d3
   f11bd:	3c 14                	cmp    $0x14,%al
   f11bf:	76 02                	jbe    0xf11c3
   f11c1:	eb 11                	jmp    0xf11d4
   f11c3:	8a 26 ca 00          	mov    0xca,%ah
   f11c7:	80 fc 00             	cmp    $0x0,%ah
   f11ca:	75 16                	jne    0xf11e2
   f11cc:	b4 30                	mov    $0x30,%ah
   f11ce:	88 26 ca 00          	mov    %ah,0xca
   f11d2:	eb 0e                	jmp    0xf11e2
   f11d4:	b4 02                	mov    $0x2,%ah
   f11d6:	88 26 c9 00          	mov    %ah,0xc9
   f11da:	b4 00                	mov    $0x0,%ah
   f11dc:	88 26 ca 00          	mov    %ah,0xca
   f11e0:	b0 02                	mov    $0x2,%al
   f11e2:	32 e4                	xor    %ah,%ah
   f11e4:	a2 cb 00             	mov    %al,0xcb
   f11e7:	a3 cd 00             	mov    %ax,0xcd
   f11ea:	b0 00                	mov    $0x0,%al
   f11ec:	c3                   	ret
   f11ed:	46                   	inc    %si
   f11ee:	26 8a 04             	mov    %es:(%si),%al
   f11f1:	3c 2f                	cmp    $0x2f,%al
   f11f3:	74 28                	je     0xf121d
   f11f5:	3c 20                	cmp    $0x20,%al
   f11f7:	74 24                	je     0xf121d
   f11f9:	3c 0d                	cmp    $0xd,%al
   f11fb:	74 20                	je     0xf121d
   f11fd:	3c 3a                	cmp    $0x3a,%al
   f11ff:	75 ec                	jne    0xf11ed
   f1201:	46                   	inc    %si
   f1202:	26 8a 04             	mov    %es:(%si),%al
   f1205:	3c 31                	cmp    $0x31,%al
   f1207:	75 08                	jne    0xf1211
   f1209:	c6 06 bd 03 01       	movb   $0x1,0x3bd
   f120e:	32 c0                	xor    %al,%al
   f1210:	c3                   	ret
   f1211:	3c 30                	cmp    $0x30,%al
   f1213:	75 08                	jne    0xf121d
   f1215:	c6 06 bd 03 00       	movb   $0x0,0x3bd
   f121a:	32 c0                	xor    %al,%al
   f121c:	c3                   	ret
   f121d:	c6 06 bd 03 00       	movb   $0x0,0x3bd
   f1222:	32 c0                	xor    %al,%al
   f1224:	c3                   	ret
   f1225:	80 3e ed 04 00       	cmpb   $0x0,0x4ed
   f122a:	74 3d                	je     0xf1269
   f122c:	c3                   	ret
   f122d:	e8 ad c8             	call   0xfdadd
   f1230:	3c ff                	cmp    $0xff,%al
   f1232:	74 35                	je     0xf1269
   f1234:	3c 04                	cmp    $0x4,%al
   f1236:	74 ed                	je     0xf1225
   f1238:	8b 16 61 00          	mov    0x61,%dx
   f123c:	b0 fe                	mov    $0xfe,%al
   f123e:	9c                   	pushf
   f123f:	fa                   	cli
   f1240:	ee                   	out    %al,(%dx)
   f1241:	a0 bd 03             	mov    0x3bd,%al
   f1244:	ee                   	out    %al,(%dx)
   f1245:	9d                   	popf
   f1246:	e8 03 f7             	call   0xf094c
   f1249:	3c ff                	cmp    $0xff,%al
   f124b:	74 1c                	je     0xf1269
   f124d:	f6 c3 01             	test   $0x1,%bl
   f1250:	75 d3                	jne    0xf1225
   f1252:	80 3e bd 03 01       	cmpb   $0x1,0x3bd
   f1257:	75 08                	jne    0xf1261
   f1259:	80 3e ed 04 00       	cmpb   $0x0,0x4ed
   f125e:	74 09                	je     0xf1269
   f1260:	c3                   	ret
   f1261:	80 3e ed 04 00       	cmpb   $0x0,0x4ed
   f1266:	74 01                	je     0xf1269
   f1268:	c3                   	ret
   f1269:	c3                   	ret
   f126a:	46                   	inc    %si
   f126b:	26 8a 04             	mov    %es:(%si),%al
   f126e:	3c 2f                	cmp    $0x2f,%al
   f1270:	74 28                	je     0xf129a
   f1272:	3c 20                	cmp    $0x20,%al
   f1274:	74 24                	je     0xf129a
   f1276:	3c 0d                	cmp    $0xd,%al
   f1278:	74 20                	je     0xf129a
   f127a:	3c 3a                	cmp    $0x3a,%al
   f127c:	75 ec                	jne    0xf126a
   f127e:	46                   	inc    %si
   f127f:	26 8a 04             	mov    %es:(%si),%al
   f1282:	3c 31                	cmp    $0x31,%al
   f1284:	75 08                	jne    0xf128e
   f1286:	c6 06 f3 04 01       	movb   $0x1,0x4f3
   f128b:	32 c0                	xor    %al,%al
   f128d:	c3                   	ret
   f128e:	3c 30                	cmp    $0x30,%al
   f1290:	75 08                	jne    0xf129a
   f1292:	c6 06 f3 04 00       	movb   $0x0,0x4f3
   f1297:	32 c0                	xor    %al,%al
   f1299:	c3                   	ret
   f129a:	c6 06 f3 04 00       	movb   $0x0,0x4f3
   f129f:	32 c0                	xor    %al,%al
   f12a1:	c3                   	ret
   f12a2:	06                   	push   %es
   f12a3:	52                   	push   %dx
   f12a4:	53                   	push   %bx
   f12a5:	c6 06 09 05 00       	movb   $0x0,0x509
   f12aa:	b8 00 43             	mov    $0x4300,%ax
   f12ad:	cd 2f                	int    $0x2f
   f12af:	3c 80                	cmp    $0x80,%al
   f12b1:	75 42                	jne    0xf12f5
   f12b3:	b8 10 43             	mov    $0x4310,%ax
   f12b6:	cd 2f                	int    $0x2f
   f12b8:	89 1e 0a 05          	mov    %bx,0x50a
   f12bc:	8c 06 0c 05          	mov    %es,0x50c
   f12c0:	33 d2                	xor    %dx,%dx
   f12c2:	32 e4                	xor    %ah,%ah
   f12c4:	a0 cb 00             	mov    0xcb,%al
   f12c7:	fe c0                	inc    %al
   f12c9:	bb 30 09             	mov    $0x930,%bx
   f12cc:	f7 e3                	mul    %bx
   f12ce:	8b d8                	mov    %ax,%bx
   f12d0:	8b d0                	mov    %ax,%dx
   f12d2:	b4 01                	mov    $0x1,%ah
   f12d4:	ff 1e 0a 05          	lcall  *0x50a
   f12d8:	3d 01 00             	cmp    $0x1,%ax
   f12db:	74 02                	je     0xf12df
   f12dd:	eb 16                	jmp    0xf12f5
   f12df:	b4 03                	mov    $0x3,%ah
   f12e1:	ff 1e 0a 05          	lcall  *0x50a
   f12e5:	3d 01 00             	cmp    $0x1,%ax
   f12e8:	74 02                	je     0xf12ec
   f12ea:	eb 09                	jmp    0xf12f5
   f12ec:	c6 06 09 05 01       	movb   $0x1,0x509
   f12f1:	5b                   	pop    %bx
   f12f2:	5a                   	pop    %dx
   f12f3:	07                   	pop    %es
   f12f4:	c3                   	ret
   f12f5:	c6 06 09 05 02       	movb   $0x2,0x509
   f12fa:	5b                   	pop    %bx
   f12fb:	5a                   	pop    %dx
   f12fc:	07                   	pop    %es
   f12fd:	c3                   	ret
   f12fe:	55                   	push   %bp
   f12ff:	8b ec                	mov    %sp,%bp
   f1301:	9c                   	pushf
   f1302:	b8 02 00             	mov    $0x2,%ax
   f1305:	c6 06 f5 04 02       	movb   $0x2,0x4f5
   f130a:	9d                   	popf
   f130b:	8b e5                	mov    %bp,%sp
   f130d:	5d                   	pop    %bp
   f130e:	c3                   	ret
   f130f:	b8 40 00             	mov    $0x40,%ax
   f1312:	8e c0                	mov    %ax,%es
   f1314:	bb 6c 00             	mov    $0x6c,%bx
   f1317:	26 8b 37             	mov    %es:(%bx),%si
   f131a:	26 8b 07             	mov    %es:(%bx),%ax
   f131d:	3b c6                	cmp    %si,%ax
   f131f:	74 f9                	je     0xf131a
   f1321:	8b f0                	mov    %ax,%si
   f1323:	33 c9                	xor    %cx,%cx
   f1325:	33 c0                	xor    %ax,%ax
   f1327:	26 3b 37             	cmp    %es:(%bx),%si
   f132a:	75 10                	jne    0xf133c
   f132c:	05 01 00             	add    $0x1,%ax
   f132f:	72 02                	jb     0xf1333
   f1331:	eb f4                	jmp    0xf1327
   f1333:	83 d1 00             	adc    $0x0,%cx
   f1336:	72 02                	jb     0xf133a
   f1338:	eb ed                	jmp    0xf1327
   f133a:	eb 54                	jmp    0xf1390
   f133c:	89 0e 8f 43          	mov    %cx,0x438f
   f1340:	a3 91 43             	mov    %ax,0x4391
   f1343:	8b 1e 8f 43          	mov    0x438f,%bx
   f1347:	a1 91 43             	mov    0x4391,%ax
   f134a:	b9 06 00             	mov    $0x6,%cx
   f134d:	d1 eb                	shr    $1,%bx
   f134f:	d1 d8                	rcr    $1,%ax
   f1351:	e2 fa                	loop   0xf134d
   f1353:	53                   	push   %bx
   f1354:	50                   	push   %ax
   f1355:	b9 05 00             	mov    $0x5,%cx
   f1358:	d1 eb                	shr    $1,%bx
   f135a:	d1 d8                	rcr    $1,%ax
   f135c:	e2 fa                	loop   0xf1358
   f135e:	89 1e 04 05          	mov    %bx,0x504
   f1362:	a3 06 05             	mov    %ax,0x506
   f1365:	d1 e0                	shl    $1,%ax
   f1367:	d1 d3                	rcl    $1,%bx
   f1369:	d1 e0                	shl    $1,%ax
   f136b:	d1 d3                	rcl    $1,%bx
   f136d:	03 06 06 05          	add    0x506,%ax
   f1371:	13 1e 04 05          	adc    0x504,%bx
   f1375:	a3 06 05             	mov    %ax,0x506
   f1378:	89 1e 04 05          	mov    %bx,0x504
   f137c:	58                   	pop    %ax
   f137d:	5b                   	pop    %bx
   f137e:	03 06 06 05          	add    0x506,%ax
   f1382:	13 1e 04 05          	adc    0x504,%bx
   f1386:	a3 06 05             	mov    %ax,0x506
   f1389:	89 1e 04 05          	mov    %bx,0x504
   f138d:	e8 01 00             	call   0xf1391
   f1390:	c3                   	ret
   f1391:	33 c0                	xor    %ax,%ax
   f1393:	b0 03                	mov    $0x3,%al
   f1395:	80 3e f5 04 04       	cmpb   $0x4,0x4f5
   f139a:	74 04                	je     0xf13a0
   f139c:	b0 00                	mov    $0x0,%al
   f139e:	b4 00                	mov    $0x0,%ah
   f13a0:	a2 9a 43             	mov    %al,0x439a
   f13a3:	88 26 95 43          	mov    %ah,0x4395
   f13a7:	8b 1e 04 05          	mov    0x504,%bx
   f13ab:	a1 06 05             	mov    0x506,%ax
   f13ae:	d1 eb                	shr    $1,%bx
   f13b0:	d1 d8                	rcr    $1,%ax
   f13b2:	d1 eb                	shr    $1,%bx
   f13b4:	d1 d8                	rcr    $1,%ax
   f13b6:	d1 eb                	shr    $1,%bx
   f13b8:	d1 d8                	rcr    $1,%ax
   f13ba:	d1 eb                	shr    $1,%bx
   f13bc:	d1 d8                	rcr    $1,%ax
   f13be:	8b c8                	mov    %ax,%cx
   f13c0:	8b d3                	mov    %bx,%dx
   f13c2:	d1 eb                	shr    $1,%bx
   f13c4:	d1 d8                	rcr    $1,%ax
   f13c6:	03 c1                	add    %cx,%ax
   f13c8:	03 da                	add    %dx,%bx
   f13ca:	89 1e 96 43          	mov    %bx,0x4396
   f13ce:	a3 98 43             	mov    %ax,0x4398
   f13d1:	a0 9a 43             	mov    0x439a,%al
   f13d4:	3c 00                	cmp    $0x0,%al
   f13d6:	74 43                	je     0xf141b
   f13d8:	8a 26 95 43          	mov    0x4395,%ah
   f13dc:	80 fc 00             	cmp    $0x0,%ah
   f13df:	75 1d                	jne    0xf13fe
   f13e1:	32 e4                	xor    %ah,%ah
   f13e3:	8b c8                	mov    %ax,%cx
   f13e5:	8b 1e 04 05          	mov    0x504,%bx
   f13e9:	a1 06 05             	mov    0x506,%ax
   f13ec:	03 06 98 43          	add    0x4398,%ax
   f13f0:	13 1e 96 43          	adc    0x4396,%bx
   f13f4:	e2 f6                	loop   0xf13ec
   f13f6:	89 1e 04 05          	mov    %bx,0x504
   f13fa:	a3 06 05             	mov    %ax,0x506
   f13fd:	c3                   	ret
   f13fe:	32 e4                	xor    %ah,%ah
   f1400:	8b c8                	mov    %ax,%cx
   f1402:	8b 1e 04 05          	mov    0x504,%bx
   f1406:	a1 06 05             	mov    0x506,%ax
   f1409:	2b 06 98 43          	sub    0x4398,%ax
   f140d:	1b 1e 96 43          	sbb    0x4396,%bx
   f1411:	e2 f6                	loop   0xf1409
   f1413:	89 1e 04 05          	mov    %bx,0x504
   f1417:	a3 06 05             	mov    %ax,0x506
   f141a:	c3                   	ret
   f141b:	c3                   	ret
	...
   f1428:	32 c0                	xor    %al,%al
   f142a:	b4 09                	mov    $0x9,%ah
   f142c:	cd 21                	int    $0x21
   f142e:	c3                   	ret
   f142f:	32 c0                	xor    %al,%al
   f1431:	b4 02                	mov    $0x2,%ah
   f1433:	cd 21                	int    $0x21
   f1435:	c3                   	ret
   f1436:	51                   	push   %cx
   f1437:	06                   	push   %es
   f1438:	b8 ff ff             	mov    $0xffff,%ax
   f143b:	8e c0                	mov    %ax,%es
   f143d:	be c0 ff             	mov    $0xffc0,%si
   f1440:	b9 08 00             	mov    $0x8,%cx
   f1443:	26 8b 44 04          	mov    %es:0x4(%si),%ax
   f1447:	3d 44 43             	cmp    $0x4344,%ax
   f144a:	74 4e                	je     0xf149a
   f144c:	83 c6 08             	add    $0x8,%si
   f144f:	e2 f2                	loop   0xf1443
   f1451:	be c0 ff             	mov    $0xffc0,%si
   f1454:	b9 08 00             	mov    $0x8,%cx
   f1457:	26 8b 04             	mov    %es:(%si),%ax
   f145a:	0b c0                	or     %ax,%ax
   f145c:	75 06                	jne    0xf1464
   f145e:	26 0b 44 02          	or     %es:0x2(%si),%ax
   f1462:	74 08                	je     0xf146c
   f1464:	83 c6 08             	add    $0x8,%si
   f1467:	e2 ee                	loop   0xf1457
   f1469:	be c0 ff             	mov    $0xffc0,%si
   f146c:	bb 10 00             	mov    $0x10,%bx
   f146f:	83 fe c0             	cmp    $0xffc0,%si
   f1472:	74 08                	je     0xf147c
   f1474:	26 8b 5c f8          	mov    %es:-0x8(%si),%bx
   f1478:	26 03 5c fa          	add    %es:-0x6(%si),%bx
   f147c:	26 89 1c             	mov    %bx,%es:(%si)
   f147f:	26 89 54 02          	mov    %dx,%es:0x2(%si)
   f1483:	26 c7 44 04 44 43    	movw   $0x4344,%es:0x4(%si)
   f1489:	33 c0                	xor    %ax,%ax
   f148b:	26 89 44 08          	mov    %ax,%es:0x8(%si)
   f148f:	26 89 44 0a          	mov    %ax,%es:0xa(%si)
   f1493:	26 89 44 0c          	mov    %ax,%es:0xc(%si)
   f1497:	07                   	pop    %es
   f1498:	59                   	pop    %cx
   f1499:	c3                   	ret
   f149a:	26 8b 34             	mov    %es:(%si),%si
   f149d:	07                   	pop    %es
   f149e:	59                   	pop    %cx
   f149f:	c3                   	ret
   f14a0:	0d 0a 47             	or     $0x470a,%ax
   f14a3:	52                   	push   %dx
   f14a4:	59                   	pop    %cx
   f14a5:	50                   	push   %ax
   f14a6:	48                   	dec    %ax
   f14a7:	4f                   	dec    %di
   f14a8:	4e                   	dec    %si
   f14a9:	20 43 44             	and    %al,0x44(%bp,%di)
   f14ac:	2d 52 4f             	sub    $0x4f52,%ax
   f14af:	4d                   	dec    %bp
   f14b0:	20 64 65             	and    %ah,0x65(%si)
   f14b3:	76 69                	jbe    0xf151e
   f14b5:	63 65 20             	arpl   %sp,0x20(%di)
   f14b8:	64 72 69             	fs jb  0xf1524
   f14bb:	76 65                	jbe    0xf1522
   f14bd:	72 20                	jb     0xf14df
   f14bf:	2d                   	.byte 0x2d
