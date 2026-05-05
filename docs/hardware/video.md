# Video Notes

The VIS has TV-oriented analog video output and custom video/system logic. Do not assume normal desktop VGA behavior.

## First modes to test

```text
INT 10h mode 13h style 320x200x256
INT 10h mode 0Dh style 320x200x16
INT 10h mode 0Eh style 640x200x16
```

## Risky assumptions

```text
80x25 text UI
Mode X
direct VGA sequencer/CRTC programming
direct palette assumptions
CGA composite tricks
```

VISENV currently provides a video mode registry, not video emulation.
