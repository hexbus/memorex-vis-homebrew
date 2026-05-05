#!/usr/bin/env python3
"""Extract/emit the known General MIDI-style GBIOS instrument table.

If given a ROM image, this currently emits the canonical General MIDI names as a
developer reference and records the expected ROM anchor. A future pass can add
byte-exact extraction from the GBIOS region once the final string-table parser
is promoted.
"""

from __future__ import annotations
from pathlib import Path
import argparse, csv

GM_NAMES = [
"Acoustic Grand Piano","Bright Acoustic Piano","Electric Grand Piano","Honky-tonk Piano","Electric Piano 1","Electric Piano 2","Harpsichord","Clavinet",
"Celesta","Glockenspiel","Music Box","Vibraphone","Marimba","Xylophone","Tubular Bells","Dulcimer",
"Drawbar Organ","Percussive Organ","Rock Organ","Church Organ","Reed Organ","Accordion","Harmonica","Tango Accordion",
"Acoustic Guitar nylon","Acoustic Guitar steel","Electric Guitar jazz","Electric Guitar clean","Electric Guitar muted","Overdriven Guitar","Distortion Guitar","Guitar Harmonics",
"Acoustic Bass","Electric Bass finger","Electric Bass pick","Fretless Bass","Slap Bass 1","Slap Bass 2","Synth Bass 1","Synth Bass 2",
"Violin","Viola","Cello","Contrabass","Tremolo Strings","Pizzicato Strings","Orchestral Harp","Timpani",
"String Ensemble 1","String Ensemble 2","Synth Strings 1","Synth Strings 2","Choir Aahs","Voice Oohs","Synth Voice","Orchestra Hit",
"Trumpet","Trombone","Tuba","Muted Trumpet","French Horn","Brass Section","Synth Brass 1","Synth Brass 2",
"Soprano Sax","Alto Sax","Tenor Sax","Baritone Sax","Oboe","English Horn","Bassoon","Clarinet",
"Piccolo","Flute","Recorder","Pan Flute","Blown Bottle","Shakuhachi","Whistle","Ocarina",
"Lead 1 square","Lead 2 sawtooth","Lead 3 calliope","Lead 4 chiff","Lead 5 charang","Lead 6 voice","Lead 7 fifths","Lead 8 bass+lead",
"Pad 1 new age","Pad 2 warm","Pad 3 polysynth","Pad 4 choir","Pad 5 bowed","Pad 6 metallic","Pad 7 halo","Pad 8 sweep",
"FX 1 rain","FX 2 soundtrack","FX 3 crystal","FX 4 atmosphere","FX 5 brightness","FX 6 goblins","FX 7 echoes","FX 8 sci-fi",
"Sitar","Banjo","Shamisen","Koto","Kalimba","Bagpipe","Fiddle","Shanai",
"Tinkle Bell","Agogo","Steel Drums","Woodblock","Taiko Drum","Melodic Tom","Synth Drum","Reverse Cymbal",
"Guitar Fret Noise","Breath Noise","Seashore","Bird Tweet","Telephone Ring","Helicopter","Applause","Gunshot"
]

def main() -> int:
    ap = argparse.ArgumentParser(description="Emit GBIOS General MIDI-style instrument table")
    ap.add_argument("out_csv", type=Path)
    args = ap.parse_args()
    args.out_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.out_csv.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["program", "name", "note"])
        for i, n in enumerate(GM_NAMES):
            w.writerow([i, n, "GBIOS MIDI-style table reference"])
    print(f"Wrote {args.out_csv}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
