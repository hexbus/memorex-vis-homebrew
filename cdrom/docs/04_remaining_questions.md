# Remaining Questions After Software-Only Analysis

The software/ROM analysis is now substantially complete. The remaining questions are mostly hardware-facing.

## Still unknown

```text
1. Exact values behind the 0x0061 and 0x0063 port variables at runtime.
2. Exact electrical timing of ENABLE*, IOR*, IOW*, IRQ, DRQ, and DACK*.
3. Whether normal VIS title reads use DRQ/DACK, IRQ only, or both.
4. Exact meaning of the VIS glue write OUT 0x00D4,0x05.
5. Exact response bytes required for all possible 0x10 TOC/disk-info cases.
6. Whether every VIS title tolerates a minimal one-data-track TOC.
7. Whether 0xC1 is ever required. ROM confirms 0xC0 as primary read.
```

## What can still be done without hardware?

Useful but diminishing returns:

```text
- More detailed naming of handler 82h/83h/84h/85h/88h.
- More comparison with other Mitsumi DOS/Linux/BSD drivers.
- Build a richer VISENV Mitsumi model to simulate the Mitsumi target drive 
- Create unit tests for C0 MSF-to-LBA conversion and ISO sector reads.
```

## What really needs hardware?

```text
- bus timing
- exact status/phase values
- IRQ vs DRQ/DACK behavior
- controller glue behavior
```

## Recommended next work

Implement a permissive Mitsumi target prototype with heavy logging.

The logger should record:

```text
HA0/HA1
ENABLE*
IOR*
IOW*
HD0-HD7 writes
HD0-HD7 reads
IRQ transitions
DRQ/DACK transitions
parsed command packets
derived LBA
sector bytes served
```
