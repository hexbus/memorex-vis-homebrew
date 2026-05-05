# Writing Your First VIS Homebrew Title

This is the practical starting point for a simple VIS homebrew title.

## 1. Choose a title type

Two title paths matter:

```text
DOS title
  TLAUNCH validates CONTROL.TAT and launches a DOS executable.

Modular Windows title
  TLAUNCH validates CONTROL.TAT and launches minwin b:.
```

For early testing, start with a DOS title.

## 2. Generate a registration key

Use the keygen tool:

```bash
python3 tools/keygen/vis_register_keygen.py --vendor 500 --product 1 --class C
```

Class C is preferred for homebrew because it does not imply official VIS logo authorization.

Validate the known sample vector:

```bash
python3 tools/keygen/validate_keygen.py
```

## 3. Build CONTROL.TAT

Use MAKETAT with a JOBD-style file and the generated key.

Known runtime-relevant fields:

```text
CONTROL.TAT + 0x98  registration payload area
CONTROL.TAT + 0xB0  MAKETAT/version marker area
```

Inspect the result:

```bash
python3 tools/controltat/controltat_report.py media_a/CONTROL.TAT
```

## 4. Create a media folder

For a DOS title:

```text
media_a/
  CONTROL.TAT
  START.EXE
```

For a Modular Windows title:

```text
media_a/
  CONTROL.TAT
  YOURAPP.EXE
  WINDOWS/
    SYSTEM.INI
```

## 5. Test the launch path with VISENV

```bash
python3 visenv/src/visenv.py --media-a media_a
```

A healthy path should reach TLAUNCH, parse CONTROL.TAT, and report either a DOS media-executable handoff or a MINWIN handoff.

## 6. Test on hardware

VISENV validates structure and likely runtime behavior. Real hardware is still required for video, audio, controller, and timing validation.
