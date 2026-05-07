# Mitsumi Replacement Engine Implementation Guide

This is the practical guide for turning the ROM analysis into a replacement-drive engine.

## Target

The target is a **drive-side Mitsumi proprietary CD-ROM engine**.

It is not:

```text
SCSI
IDE / ATAPI
Panasonic / MKE
```

## Likely 40-pin bus model

The Mitsumi/Tandy-style 40-pin pinout is:

```text
1  HA0        2  GND
3  HA1        4  GND
13 IRQ       14  GND
15 DRQ       16  GND
17 DACK*     18  GND
19 IOR*      20  GND
21 IOW*      22  GND
23 ENABLE*   24  GND
25 HD0       26  GND
27 HD1       28  GND
29 HD2       30  GND
31 HD3       32  GND
33 HD4       34  GND
35 HD5       36  GND
37 HD6       38  GND
39 HD7       40  GND
```

Working signal roles:

```text
HA0/HA1       register select
HD0-HD7       bidirectional byte bus
ENABLE*       device select
IOR*          host reads selected register
IOW*          host writes selected register
IRQ           interrupt / data-ready style signal
DRQ/DACK*     optional DMA handshake
```

## Minimum command behavior

A first data-only prototype should implement:

```text
0x40  status
0x50  set drive mode
0x70  hold/pause
0x90  configure
0x10  TOC / disk info
0xDC  version
0xC0  read sectors
```

Accept these as no-op success initially:

```text
0xF6  eject
0xF8  close tray
0xFE  lock/unlock door
```

## C0 read packet

The VIS sends:

```text
C0 M S F 00 00 count
```

Where:

```text
M      BCD minute
S      BCD second
F      BCD frame
count  sector count
```

Convert to LBA:

```text
frames = minute * 60 * 75 + second * 75 + frame
lba    = frames - 150
```

Make the 150-frame pregap configurable while testing.

## Suggested firmware state machine

```text
IDLE
  wait for ENABLE* + IOW*

PACKET_RECEIVE
  collect command and packet bytes

STATUS_READY
  expose ready/phase status expected by the VIS

DATA_OUT
  return version, TOC, or status bytes

READ_ACTIVE
  stream ISO sector bytes after C0 packet

ERROR
  expose error/status until reset/status/hold recovers
```

## BlueSCSI-style reuse

Reuse:

```text
SD card layer
ISO file handling
sector cache
debug logging
configuration file support
main firmware/task structure
```

Replace:

```text
SCSI bus phase engine
SCSI CDB parser
SCSI status/message phases
```

With:

```text
Mitsumi bus target
HA0/HA1 register decoding
HD0-HD7 bidirectional data handling
IOR*/IOW*/ENABLE* edge handling
IRQ/DRQ/DACK behavior
Mitsumi command packet parser
```

## First prototype success condition

Do not try to support every title or audio first.

The first target is:

```text
VIS reads A:\CONTROL.TAT from an ISO-backed replacement device.
```

If that works, then TOC details, timing, status bits, and CD audio can be refined.
