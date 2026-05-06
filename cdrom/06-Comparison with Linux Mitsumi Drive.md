# VIS Mitsumi Driver vs. Linux `mcdx.c`

This page compares the embedded VIS Mitsumi/Gryphon CD-ROM driver with the public Linux Mitsumi `mcdx.c` driver.

## Executive summary

The VIS driver and Linux `mcdx.c` appear to describe the same broad hardware family:

```text
Mitsumi proprietary CD-ROM interface
  non-ATAPI
  small register window
  command bytes written to data port
  status/data readback
  optional IRQ / no-DMA mode
  MSF-addressed sector reads
```

But they are not arranged the same way.

Linux `mcdx.c` is a native Linux block/CD-ROM driver. The VIS driver is a DOS character/block device driver that sits below MSCDEX.

## Stack comparison

### VIS stack

```text
TLAUNCH
  -> INT 21h open/read A:\CONTROL.TAT
  -> ROM MSCDEX layer
  -> embedded Mitsumi/Gryphon DOS device driver
  -> proprietary Mitsumi CD-ROM interface
```

### Linux `mcdx.c` stack

```text
Linux block/CD-ROM layer
  -> mcdx.c
  -> proprietary Mitsumi CD-ROM interface
```

So the same rough hardware interface is exposed through very different OS-facing driver models.

## Register model comparison

Linux `mcdx.c` names four register roles:

```text
wreg_data  / rreg_data
wreg_reset / rreg_status
wreg_hcon
wreg_chn
```

It sets them as a four-port window:

```text
base + 0  data
base + 1  reset/status
base + 2  hardware config
base + 3  channel
```

The VIS disassembly does not yet have symbolic register names, but it does show repeated use of driver variables that look like initialized port addresses:

```text
[0x0061]  command/data-style output port candidate
[0x0063]  paired status/data-style candidate
```

The VIS init command line includes:

```text
/i:5
/t:5
/m:18
/d:mscd001
/h
```

and the embedded init routine parses `/P`, `/D`, `/T`, `/I`, `/M`, `/U`, `/A`, `/N`, and `/H`. `/P` is especially important because Linux `mcdx.c` also treats the base I/O port as the anchor for the four-port register window.

## Command model comparison

Linux `mcdx.c` exposes these important Mitsumi command bytes:

| Operation | Linux command byte |
|---|---:|
| Read single speed | `0xC0` |
| Read double speed | `0xC1` |
| Get TOC / disk info | `0x10` |
| Multisession disk info | `0x11` |
| Request sub-Q | `0x20` |
| Get status | `0x40` |
| Set drive mode | `0x50` |
| Soft reset | `0x60` |
| Hold / pause | `0x70` |
| Configure IRQ/DMA | `0x90` |
| Set data mode | `0xA0` |
| Request version | `0xDC` |
| Stop | `0xF0` |
| Eject | `0xF6` |
| Close tray | `0xF8` |
| Lock door | `0xFE` |

The VIS disassembly already shows several of these same command bytes in plausible command paths:

| VIS location | Byte(s) | Likely meaning by comparison |
|---|---:|---|
| `0xEF3B4` | `0x40` | Get status |
| `0xEF3E8` | `0x50, 0x00` | Set drive mode / mode register |
| `0xEF448` | `0x90, 0x04, 0x01` | Configure hardware / IRQ/DMA-style mode |
| command-line `/d:mscd001` | n/a | MSCDEX device name |
| command-line `/m:18` | n/a | MSCDEX/driver buffer count |
| command-line `/i:5` | n/a | IRQ 5 |
| command-line `/t:5` | n/a | likely timing/timeout/transfer option |

This is the strongest current evidence that the VIS driver and Linux `mcdx.c` share the same Mitsumi command vocabulary.

## Read path comparison

Linux `mcdx.c` reads sectors by:

```text
1. Choosing READ1X or READ2X command.
2. Converting logical sector to MSF.
3. Sending a 7-byte command:
   [readcmd, minute, second, frame, 0, 0, sector_count]
4. Waiting for data-ready status/interrupt.
5. Reading sector data from the data port.
```

The VIS driver has not yet been fully mapped at the sector-read handler, but command table candidates suggest the likely path lives in the extended/vendor handlers:

```text
0xEF656  command 80h handler
0xEFE93  command 82h handler
0xF000E  command 83h handler
0xF01A0  command 84h handler
0xF051A  command 85h handler
0xF0652  command 88h handler
```

The VIS driver also contains a hardware/interrupt-ish region around `0xF0B47-0xF0CD8` that manipulates port `0xD0`, `0xD4`, `0xD6`, `0xD8`, `0xC4`, `0xC6`, `0x8B`, and PIC ports `0x20`/`0xA0`. That may be VIS-specific controller glue rather than the simple ISA base+0..3 model shown by Linux.

## Key difference: direct port model vs. VIS platform glue

Linux `mcdx.c` assumes a PC ISA controller with a small I/O base window.

The VIS driver appears to have two layers:

```text
Mitsumi command vocabulary
  0x40, 0x50, 0x90, likely 0xC0/0xC1 elsewhere

VIS platform/controller glue
  low ports around 0xC4, 0xC6, 0xD0, 0xD4, 0xD6, 0xD8, 0x8B
```

That likely means the VIS drive is not just a stock PC Mitsumi interface card at a normal base address. The embedded driver may be adapting Mitsumi protocol to VIS-specific glue hardware.

## Practical result for a replacement drive

A BlueSCSI-style replacement should not implement the Linux driver. It should implement the **drive-side Mitsumi protocol** that both drivers expect.

Minimum target behavior:

```text
status/readiness response
version response
configure response
drive mode response
TOC/disk info response
read command accepting MSF + count
sector data output
interrupt/status signaling compatible with VIS glue
```

## Next things that the community needs to do:

1. Trace VIS command handlers for `0x80`, `0x82`, `0x83`, `0x84`, `0x85`, and `0x88`.
2. Search the VIS driver for byte constants used by Linux `mcdx.c`: `C0`, `C1`, `10`, `11`, `20`, `40`, `50`, `60`, `70`, `90`, `A0`, `DC`, `F0`, `F6`, `F8`, `FE`.
3. Decode the VIS driver's variable map around `0x005F`, `0x0061`, `0x0063`, `0x00ED`, `0x00EF`, `0x00FA`, `0x0101`, and `0x0500-0x0518`.
4. Correlate VIS physical port writes with a logic-analyzer trace from the CD-ROM connector.
5. Implement a VISENV `mitsumi_protocol_stub.py` with the Linux `mcdx.c` command vocabulary as the first model.
