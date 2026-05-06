# Memorex/Tandy VIS CD-ROM Findings: Mitsumi - CMRC-FR model, proprietary interface (like Tandy CDR-1000)

This is a consolidated summary of the VIS CD-ROM analysis for homebrew and preservation work.

## Short version

The Memorex/Tandy VIS CD-ROM path appears to use an embedded **Mitsumi/Gryphon proprietary CD-ROM driver**, not IDE/ATAPI, not SCSI

The ROM contains an embedded DOS-style CD-ROM device driver with these identifying strings and locations in the combined 1 MiB VIS ROM address space:

```text
0xED067  cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h
0xED08D  DOS device-driver header
0xED0A7  Copyright (C) Mitsumi corporation 1989,1990,1991
0xF14A2  GRYPHON CD-ROM device driver - Version is 2(33) 29-Sep-92
```

The driver header decodes as:

```text
Header address:     0xED08D
Attributes:         0xC800
Strategy offset:    0x098B -> approx 0xEDA18
Interrupt offset:   0x0996 -> approx 0xEDA23
Placeholder name:   12345678
```

The `/d:mscd001` option explains how the placeholder name becomes the MSCDEX-visible device name.

## Software stack

The VIS title-launch path looks like this:

```text
TLAUNCH
  -> INT 21h open/read A:\CONTROL.TAT
  -> ROM MSCDEX-derived filesystem layer
  -> embedded Mitsumi/Gryphon DOS CD-ROM driver
  -> proprietary Mitsumi 40-pin CD-ROM bus
  -> physical CD-ROM drive
```

The ROM MSCDEX layer scans for an `MSCD00`-style prefix. The embedded driver uses `/d:mscd001`, so MSCDEX can find it by prefix.

```text
MSCDEX searches: MSCD00
Driver name:     MSCD001
```

## Why this matters

For homebrew and preservation, the CD-ROM path matters because the VIS needs to read `A:\CONTROL.TAT` before it can validate and launch a title.

A replacement drive or SD-card-based solution should therefore emulate the **Mitsumi proprietary CD-ROM drive-side behavior**, not SCSI, IDE/ATAPI.

## Important ROM-side conclusions

From software/ROM analysis:

```text
- The lower CD-ROM driver is embedded in ROM.
- It is a DOS device driver underneath MSCDEX.
- MSCDEX calls the driver's strategy/interrupt entry points.
- Request command 80h is the primary sector-read path.
- Command 80h sends Mitsumi 0xC0 read packets.
- The 0xC0 packet shape is C0 M S F 00 00 count.
- M/S/F fields are BCD-like CD minute/second/frame values.
- The driver uses variable 0x0061 as a command/data port candidate.
- The driver uses variable 0x0063 as a status/phase port candidate.
- Final sector movement appears interrupt/counter/glue-assisted.
```

## Current replacement-device direction

A BlueSCSI-style board may be a useful hardware/software base because it already has SD-card and image-file handling. However, the protocol engine would need to be rewritten as a Mitsumi proprietary CD-ROM target engine.

Conceptual replacement:

```text
Keep:
  SD card support
  ISO image handling
  logging/debug shell
  sector cache
  firmware state-machine structure

Replace:
  SCSI target engine

With:
  Mitsumi proprietary CD-ROM target engine
```

Minimum target behavior for data-only homebrew:

```text
0x40  status
0x50  set drive mode
0x70  hold/pause
0x90  configure
0x10  TOC / disk info
0xDC  version
0xC0  read sector(s)
```

A first success condition would be simple:

```text
VIS reads A:\CONTROL.TAT from the replacement device.
```

## Remaining unknowns

Hardware tracing would still be needed to confirm:

```text
- exact 40-pin timing
- exact phase/status encoding
- whether DRQ/DACK are used during normal title reads
- whether IRQ alone is enough
- exact meaning of OUT 0x00D4,0x05 in the VIS driver
- exact version/TOC response bytes needed by every title
```

But the software/ROM path is now clear enough to guide a first replacement-engine prototype.
