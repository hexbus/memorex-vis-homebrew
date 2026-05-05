# Writing Your First VIS Homebrew Title

This is the practical starting point.

## Step 1: Generate a registration key

Use the keygen tool when present:

```bash
python3 tools/keygen/vis_register_keygen.py --vendor 500 --product 1 --class C
```

Class C is preferred for homebrew because it does not imply official VIS logo authorization.

## Step 2: Build CONTROL.TAT

Use MAKETAT with a JOBD-style file and your generated key.

## Step 3: Build a media folder

For a DOS title:

```text
CONTROL.TAT
START.EXE
```

For a Modular Windows title:

```text
CONTROL.TAT
WINDOWS\SYSTEM.INI
YOURAPP.EXE
```

## Step 4: Test the boot path in VISENV

```bash
python3 visenv/src/visenv.py --media-a examples/first-homebrew/media_a
```

## Step 5: Move to hardware or deeper emulation

VISENV validates the structural boot path. It does not yet replace real VIS hardware.
