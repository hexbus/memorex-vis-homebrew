# Handler Semantics Appendix: 82h / 83h / 84h / 85h / 88h

This appendix tightens the handler names beyond the earlier generic descriptions.

## Summary table

| Request | Address | Proposed name | Confidence |
|---|---:|---|---|
| `80h` | `0xEF656` | `READ_SECTORS / TRANSFER_DATA` | High |
| `82h` | `0xEFE93` | `GET_POSITION_OR_STATUS_WITH_MSF` | Medium |
| `83h` | `0xF000E` | `GET_SINGLE_POSITION_OR_COMPACT_STATUS` | Medium |
| `84h` | `0xF01A0` | `RANGE_COMMAND / PLAY_OR_RANGE_TRANSFER` | Medium |
| `85h` | `0xF051A` | `MEDIA_STATUS_OR_CURRENT_LOCATION` | Medium-high |
| `88h` | `0xF0652` | `MEDIA_READY_CHANGE_GATE` | Medium-high |

These are semantic names, not recovered original labels.

## Why original labels were not recovered

The 513 archive was searched for MAP/LST/SYM/source label evidence. The search results are in:

```text
maps/513_label_source_search_results.csv
maps/513_archive_file_type_counts.csv
```

The useful 513 evidence remains the embedded ROM driver identity and command line. No definitive original symbol map for these handler labels was recovered in this pass.

## 82h: GET_POSITION_OR_STATUS_WITH_MSF

Working role:

```text
Position/status style request that works with MSF-like fields and status bits.
```

```asm
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
```

Prototype behavior:

```text
Return stable ready/current-position state.
```

## 83h: GET_SINGLE_POSITION_OR_COMPACT_STATUS

Working role:

```text
Compact single-position/status request, structurally related to 82h.
```

```asm
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
```

Prototype behavior:

```text
Return stable ready/no-error status.
```

## 84h: RANGE_COMMAND / PLAY_OR_RANGE_TRANSFER

Working role:

```text
Range-based command path. Builds start/end MSF fields and can issue a C0 packet.
This may be used for range control, special transfer, or audio-like behavior.
```

```asm
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
```

Prototype behavior:

```text
For data-only boot, accept and return success unless a title actually relies on range/audio behavior.
```

## 85h: MEDIA_STATUS_OR_CURRENT_LOCATION

Working role:

```text
Media/status/current-location path. Uses 0x40 status and 0x70 hold/pause.
```

```asm
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
```

Prototype behavior:

```text
Return disc present, ready, no media change, and a sane current MSF.
```

## 88h: MEDIA_READY_CHANGE_GATE

Working role:

```text
Ready/change/error gate. Checks cached state and confirms media readiness.
```

```asm
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
```

Prototype behavior:

```text
Report mounted media as ready and unchanged after initialization.
```

## Implementation note

For the first replacement engine, only `80h` / `0xC0` read behavior is essential for `A:\CONTROL.TAT`.

The remaining handlers should initially return permissive, ready, no-error responses and be logged aggressively. If a title stalls, the log will show which handler needs a more accurate response model.
