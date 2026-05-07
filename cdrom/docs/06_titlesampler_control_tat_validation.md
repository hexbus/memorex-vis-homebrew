# Title Sampler ISO Validation

This pass uses `VISSAMPLER.iso` to validate the practical launch assumption: the VIS must be able to read `A:\CONTROL.TAT`.

## ISO summary

```text
System identifier:  
Volume identifier:  VISSAMPLER
Volume sectors:     26372
Root extent:        20
Root size:          4096
File count parsed:  153
Dir count parsed:   5
```

## CONTROL.TAT

Parsed `CONTROL.TAT` records:

```text
/CONTROL.TAT  LBA=28  size=501  offset=57344
```

See:

```text
maps/vissampler_control_tat_location.csv
maps/vissampler_iso_file_map.csv
```

## Why this matters

The replacement engine's first real milestone should be:

```text
1. mount ISO
2. respond to VIS status/config/mode commands
3. accept C0 MSF read packets
4. stream the sectors containing CONTROL.TAT
5. allow TLAUNCH to continue beyond title validation
```

## Connection to the ROM driver

The ROM read path uses:

```text
C0 M S F 00 00 count
```

So the replacement firmware can translate the requested MSF to LBA and read from the ISO.

For an ISO sector LBA:

```text
M/S/F frame address = LBA + 150
```

For a drive command packet:

```text
LBA = MSF_frames - 150
```

The Title Sampler location map gives known target sectors to use in unit tests.
