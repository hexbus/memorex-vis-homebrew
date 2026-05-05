# Audio and MIDI Notes

Internal photos show a Yamaha YMF262-M and Sanyo LC7883KM, supporting an OPL/FM synth plus DAC-style audio path.

## VISENV audio stub

```text
visenv/src/audio_stub.py
```

It currently supports:

```text
General MIDI mode logging
Microsoft base-level mode logging
instrument program lookup
```

The GBIOS MIDI instrument table is available in:

```text
data_tables/gbios_general_midi_instrument_table.csv
```
