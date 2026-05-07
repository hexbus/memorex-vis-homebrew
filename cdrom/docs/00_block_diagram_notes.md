# VIS Block Diagram Notes Relevant to the CD-ROM Path

Thanks to Eddie Malphrus, who provided a VIS block diagram.

## What the diagram appears to show

The CD-ROM is connected through the main controller side of the system, not as a normal PC IDE/ATAPI drive.

The diagram appears to show:

```text
Controller ASIC / system-control area
  -> CD-XA signals
  -> CD-ROM block
```

That is consistent with the ROM evidence:

```text
ROM MSCDEX layer
  -> embedded Mitsumi/Gryphon CD-ROM driver
  -> VIS controller/glue logic
  -> proprietary Mitsumi CD-ROM bus
```

## Why this matters

The driver does not look like it is simply writing to a stock PC Mitsumi ISA card base address. It uses internal variables such as:

```text
0x0061  command/data port candidate
0x0063  status/phase port candidate
0x00D4  VIS glue write appears in read recovery/continuation path
```

The block diagram helps explain why: the VIS likely has custom controller glue between the CPU/software driver and the physical CD-ROM connector.

## Engineering implication

A replacement drive still needs to emulate the Mitsumi drive-side protocol, but the VIS host side may not behave exactly like a generic PC Mitsumi controller card. Firmware should therefore:

```text
- log every command byte
- log HA0/HA1 register selection
- log IOR*/IOW*/ENABLE* timing
- tolerate permissive status/mode/config behavior initially
- focus first on satisfying C0 sector reads for A:\CONTROL.TAT
```

## Confidence note

This note is based on a hard-to-read block diagram plus the ROM analysis. It should not be treated as a full schematic-level claim.
