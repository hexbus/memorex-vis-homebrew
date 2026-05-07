# ROM Map and Evidence for the VIS Mitsumi CD-ROM Driver

This file records where the major findings came from.

## Driver identity strings

```text
0xED067  cd.sys /m:18 /i:5 /t:5 /d:mscd001 /h
0xED0A7  Copyright (C) Mitsumi corporation 1989,1990,1991
0xF14A2  GRYPHON CD-ROM device driver - Version is 2(33) 29-Sep-92
```

## Driver header

```text
0xED08D  DOS device-driver header
```

Decoded:

```text
next pointer       FF FF FF FF
attributes         0xC800
strategy offset    0x098B
interrupt offset   0x0996
placeholder name   12345678
```

Resolved relative to the header:

```text
strategy entry     0xEDA18
interrupt entry    0xEDA23
```

## Important routines

```text
0xEDA18  strategy entry
0xEDA23  interrupt dispatcher
0xEF656  command 80h primary read handler
0xEF8C7  explicit C0 single-sector read packet
0xF08AB  generalized C0 packet helper
0xF094C  status/data read helper
0xF070F  MSF conversion helper
0xF071E  BCD-like conversion helper
0xF0CD9  INIT handler
```

## Primary packet evidence

At `0xEF8C7-0xEF8EF`, the driver writes:

```text
C0, [0069], [006A], [006B], 00, 00, 01
```

This is a Mitsumi-style read command packet.

## Generalized packet helper

At `0xF08AB-0xF08DC`, the helper writes:

```text
C0, [0069], [006A], [006B], [006C], [006D], [006E]
```

This appears to be the generalized C0 packet sender.

## Evidence maps in this pack

```text
maps/mitsumi_command_writes_to_port_0061.csv
maps/mitsumi_mcdx_constant_hits.csv
maps/mitsumi_extended_handler_complete_map.csv
maps/mitsumi_command_80_read_trace.csv
maps/mitsumi_c0_read_packets.csv
maps/mitsumi_variable_reference_map.csv
maps/mitsumi_init_option_complete_map.csv
maps/mitsumi_port_and_signal_model.csv
maps/mitsumi_minimum_engine_commands.csv
```

## Detailed assembly

The detailed disassembly is kept in:

```text
asm/annotated/11-mitsumi-gryphon-cdrom-driver.asm
```

That file is intentionally separate from the explanation docs so the protocol guide remains readable.
