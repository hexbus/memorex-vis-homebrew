# VIS Mitsumi CD-ROM Clean Protocol Pack

This is a consolidated protocol-analysis pack for the Memorex/Tandy VIS CD-ROM subsystem.

It is intended for homebrew and replacement-drive development.

## Start here

```text
docs/01_protocol_and_driver_analysis.md
```

Then read:

```text
docs/02_rom_map_and_evidence.md
docs/03_mitsumi_engine_implementation_guide.md
docs/04_remaining_questions.md
docs/00_block_diagram_notes.md
```

## Detailed disassembly

```text
asm/annotated/11-mitsumi-gryphon-cdrom-driver.asm
```

## Key maps

```text
maps/mitsumi_command_writes_to_port_0061.csv
maps/mitsumi_extended_handler_complete_map.csv
maps/mitsumi_c0_read_packets.csv
maps/mitsumi_variable_reference_map.csv
maps/mitsumi_init_option_complete_map.csv
```

## Short conclusion

The VIS uses an embedded Mitsumi/Gryphon CD-ROM driver below MSCDEX. The primary sector-read path is request command `80h`, which sends a Mitsumi `0xC0` read packet:

```text
C0 M S F 00 00 count
```

A replacement device should emulate a Mitsumi proprietary CD-ROM target, not SCSI or IDE/ATAPI.


## Added in handler semantics pass

```text
docs/05_handler_semantics_appendix.md
docs/06_titlesampler_control_tat_validation.md
maps/513_label_source_search_results.csv
maps/mitsumi_handler_semantics_deep_trace.csv
maps/mitsumi_handler_command_write_matrix.csv
maps/vissampler_control_tat_location.csv
```


## Plain-English CD-ROM flow

Start with:

```text
docs/01a_how_the_vis_talks_to_the_mitsumi_drive.md
```

This explains how TLAUNCH, MSCDEX, the embedded Mitsumi/Gryphon driver, and the physical drive fit together.
