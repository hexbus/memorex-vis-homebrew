# DOS Video Mode Test

Goal: create a tiny DOS program that sets one video mode, draws a shape, and waits safely.

Recommended first modes to test:

```text
mode 13h style 320x200x256
mode 0Dh style 320x200x16
mode 0Eh style 640x200x16
```

Avoid text-mode assumptions for initial VIS testing.
