# Mitsumi 40-Pin Bus and BlueSCSI-Style Replacement Notes

These notes summarize the practical replacement-drive direction for VIS homebrew.

## Likely 40-pin Mitsumi pinout

The Tandy CDR-1000/Mitsumi-style 40-pin cable pinout:

```text
 1 HA0        2 GND
 3 HA1        4 GND
 5 N/C        6 GND
 7 N/C        8 GND
 9 N/C       10 GND
11 N/C       12 GND
13 IRQ       14 GND
15 DRQ       16 GND
17 DACK*     18 GND
19 IOR*      20 GND
21 IOW*      22 GND
23 ENABLE*   24 GND
25 HD0       26 GND
27 HD1       28 GND
29 HD2       30 GND
31 HD3       32 GND
33 HD4       34 GND
35 HD5       36 GND
37 HD6       38 GND
39 HD7       40 GND
```

`*` means active low.

## Signal model

```text
HA0/HA1       register select
HD0-HD7       bidirectional 8-bit data bus
ENABLE*       device select
IOR*          host reads selected register
IOW*          host writes selected register
IRQ           interrupt / data-ready style signal
DRQ/DACK*     DMA-style handshake, possibly used during transfers
```

## How this lines up with the ROM

The VIS ROM driver uses two important software variables:

```text
0x0061  command/data port candidate
0x0063  status/phase port candidate
```

The driver writes Mitsumi command bytes through `0x0061` and polls phase/status through `0x0063`.

This aligns with a small register-window style bus selected by `HA0/HA1`.

## Minimum command set for replacement engine

For data-only homebrew, implement these first:

```text
0x40  status
0x50  set drive mode
0x70  hold/pause
0x90  configure
0x10  TOC / disk info
0xDC  version
0xC0  read 1x / sector read
```

Door/tray commands can probably be accepted as no-op success:

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

Convert to LBA with the usual CD math:

```text
frames = minute * 60 * 75 + second * 75 + frame
lba    = frames - 150
```

The 150-frame pregap is the default assumption and should be made configurable while testing.

## Suggested firmware state machine

```text
IDLE
  wait for ENABLE* + IOW*

PACKET_RECEIVE
  collect command and packet bytes

STATUS_READY
  expose status/phase expected by VIS polling

DATA_OUT
  return version, TOC, or status bytes

READ_ACTIVE
  stream ISO sector data after C0 command

ERROR
  expose error/status and wait for reset/status/hold
```

## BlueSCSI-style porting concept

Reuse:

```text
SD card access
ISO image handling
sector cache
logging/debug shell
configuration file handling
main firmware framework
```

Replace:

```text
SCSI bus state machine
SCSI CDB parser
SCSI status/message phases
```

With:

```text
Mitsumi 40-pin bus target
HA0/HA1 register decode
HD0-HD7 bidirectional data handling
IOR*/IOW*/ENABLE* edge handling
IRQ/DRQ/DACK behavior
Mitsumi command packet parser
```

## First success goal

The first firmware milestone should not be “boot every title.”

The first milestone should be:

```text
VIS successfully reads A:\CONTROL.TAT from an ISO on SD card.
```

After that, expand TOC behavior, status bits, timing, and optional CD audio.
