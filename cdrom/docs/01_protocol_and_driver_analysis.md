# VIS Mitsumi CD-ROM Protocol and Driver Analysis

This is the consolidated working analysis of the VIS CD-ROM driver for homebrew and replacement-drive development.

## Executive conclusion

The VIS CD-ROM subsystem uses an embedded **Mitsumi/Gryphon proprietary CD-ROM driver** beneath a ROM MSCDEX-derived filesystem layer.

It is not SCSI, not IDE/ATAPI, and not Panasonic/MKE.

Confirmed ROM identity:

```text
0xED067  cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h
0xED08D  DOS device-driver header
0xED0A7  Copyright (C) Mitsumi corporation 1989,1990,1991
0xF14A2  GRYPHON CD-ROM device driver - Version is 2(33) 29-Sep-92
```

## Overall software stack

```text
TLAUNCH
  -> INT 21h open/read A:\CONTROL.TAT
  -> ROM MSCDEX-derived filesystem layer
  -> embedded Mitsumi/Gryphon DOS device driver
  -> VIS controller/glue logic
  -> proprietary Mitsumi 40-pin CD-ROM bus
  -> physical CD-ROM drive
```

## Device-driver boundary

The embedded driver has a DOS device-driver header at:

```text
0xED08D
```

Decoded fields:

```text
next pointer       FF FF FF FF
attributes         0xC800
strategy offset    0x098B -> approx 0xEDA18
interrupt offset   0x0996 -> approx 0xEDA23
placeholder name   12345678
```

The `/d:mscd001` command-line option patches the placeholder name to `MSCD001`.

The ROM MSCDEX layer searches for an `MSCD00` prefix, so `MSCD001` is a match.

## Init command line

The embedded command line is:

```text
cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h
```

Current static interpretation:

```text
/D  device name, patches DOS device-driver header
/I  IRQ/vector selection; current value is 5
/M  buffer/sector count; current value is 18 decimal
/T  parsed but durable effect is not fully confirmed
/H  probes INT 2Fh AX=4300/4310 host/hardware service
/U  door lock/unlock behavior
/A  alternate feature flag
/N  boolean behavior flag
/P  parser exists, but no visible base-port assignment in this ROM path
```

The `/P` behavior is important. A generic PC driver might use `/P` for the controller base address. In this VIS ROM, no clear `/P` assignment to the port variables has been proven. That suggests the VIS build relies on built-in platform mapping or controller glue.

## Primary read path

Request command `80h` is the primary sector-read / transfer path.

```text
MSCDEX read request
  -> lower driver interrupt dispatcher
  -> command 80h handler at 0xEF656
  -> prepare transfer counters and request fields
  -> convert logical address to MSF / BCD
  -> send Mitsumi 0x40 status
  -> send Mitsumi 0xC0 read packet
  -> poll phase/status
  -> enter interrupt/counter-assisted transfer loop
```

The clearest `0xC0` packet is at:

```text
0xEF8C7-0xEF8EF
```

Packet shape:

```text
C0, [0069], [006A], [006B], 00, 00, 01
```

Meaning:

```text
0xC0    Mitsumi read command
0069    BCD-ish minute
006A    BCD-ish second
006B    BCD-ish frame
00
00
01      sector count
```

There is also a generalized helper at:

```text
0xF08AB-0xF08DC
```

which sends:

```text
C0, [0069], [006A], [006B], [006C], [006D], [006E]
```

## Extended request handlers

The driver dispatches several extended/vendor requests. Static roles:

```text
80h -> 0xEF656  primary sector-read / transfer path
82h -> 0xEFE93  position/status or seek-style request
83h -> 0xF000E  single-position/status request
84h -> 0xF01A0  range-based command path
85h -> 0xF051A  media/status/hold path
88h -> 0xF0652  ready/media gate
```

Only `80h` is fully proven as the primary sector-read path. The others are mapped by request fields, status tests, command use, and similarity to public Mitsumi-family driver behavior.

## Mitsumi command vocabulary seen in the ROM

Actual command writes through the `[0x0061]` path include:

```text
0x10  TOC / disk info candidate
0x20  sub-Q candidate
0x40  status
0x50  set drive mode
0x70  hold / pause
0x90  configure
0xC0  read 1x / sector read
0xDC  request version
0xF6  eject
0xF8  close tray
0xFE  lock/unlock
```

This closely matches the public Linux `mcdx.c` command vocabulary for Mitsumi proprietary CD-ROM drives.

## Important driver variables

```text
0x0061       command/data port candidate
0x0063       status/phase port candidate
0x0069-006B  start MSF BCD
0x006C-006E  secondary MSF / count
0x00C5       drive mode byte
0x00C6       IRQ/vector selector
0x00C7       PIC mask value
0x00C8       EOI/vector-related value
0x00CB       buffer count
0x00CD       transfer count base
0x00ED/00EF  transfer progress counters
0x0101/0103  transfer-size limits
0x0509/050A/050C /H host service mode/pointer
```

## Status/phase behavior

The driver polls the candidate status/phase port at `0x0063` and watches low-nibble phase values:

```text
0x0B
0x0D
```

It then reads response/status/data through `0x0061`.

Working status-bit labels from repeated software use:

```text
0x40  ready / command accepted style bit
0x20  media change / attention style bit
0x08  data/status phase branch bit
0x04  completion/data-ready branch bit
0x02  state/error branch bit
```

These are software-derived working labels, not final electrical names.

## Transfer behavior

The final sector movement does not appear as a simple visible `REP INSB` loop inside the `80h` handler. Instead, it appears to be interrupt/counter/glue-assisted.

The handler uses:

```text
0x00C6       selected interrupt/vector path
0x00ED/00EF  transfer progress counters
0x00CD       transfer count base
0x00D4       VIS glue I/O write appears in retry/continuation path
```

With `/i:5`, the driver selects the INT `0D` branch in the transfer path.

## What is settled

```text
- The embedded lower driver is Mitsumi/Gryphon.
- MSCDEX finds it as MSCD001/MSCD00.
- Command 80h is the primary sector-read path.
- Command 80h sends Mitsumi 0xC0 read packets.
- The read packet is C0 M S F 00 00 count.
- 0x0061 is the command/data port candidate.
- 0x0063 is the status/phase port candidate.
- The transfer path is interrupt/counter/glue-assisted.
```

## What remains unknowable from ROM alone

```text
- exact electrical timing
- exact 40-pin phase/status waveform behavior
- whether DRQ/DACK are used during normal title reads
- exact meaning of OUT 0x00D4,0x05
- exact response bytes tolerated by all titles
```


## Plain-English companion

For a simple layer-by-layer explanation of how TLAUNCH, MSCDEX, the embedded ROM driver, and the physical Mitsumi drive communicate, see:

```text
docs/01a_how_the_vis_talks_to_the_mitsumi_drive.md
```
