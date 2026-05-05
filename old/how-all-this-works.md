# Tandy VIS `REGISTER.EXE` Reverse Engineering Notes

This document explains the purpose of the Tandy VIS `REGISTER.EXE` program, how it relates to `REGISTER.DAT` and `MAKETAT.EXE`, and what was learned from disassembling the registration-key generation logic.

The goal is to help VIS homebrew developers understand what the original registration tool did and how the recreated Python key generator fits into the build process.

## Toolchain overview

The original VIS title-control workflow appears to have been:

```text
REGISTER.DAT
    |
    v
REGISTER.EXE
    |
    v
20-character registration key
    |
    v
MAKETAT job file, such as JOBD
    |
    v
MAKETAT.EXE
    |
    v
CONTROL.TAT
```

In practical terms:

- `REGISTER.DAT` is a plain-text vendor/product/license database.
- `REGISTER.EXE` reads that database and generates a 20-character registration key.
- The generated key is copied into the `REGISTER` line of a MAKETAT job file.
- `MAKETAT.EXE` validates the key and builds `CONTROL.TAT`.
- The VIS boot/runtime environment looks for and processes `CONTROL.TAT`.

`REGISTER.EXE` does **not** build `CONTROL.TAT` directly. It only generates the registration key that `MAKETAT.EXE` later validates.

## What `REGISTER.EXE` does

`REGISTER.EXE` reads title/vendor metadata from `REGISTER.DAT`, asks for or accepts:

```text
Vendor ID
Product ID
License class
```

and prints the 20-character key used on the `REGISTER` line in a MAKETAT job file.

A format string found in the executable is:

```text
Registration key for Vendor %ld Product %ld License %c is:
```

The resulting key is then placed into a MAKETAT job file.

Example (using a fake vendor ID, product, and licence):

```text
REGISTER fF<kJ+L?0[WZ)C!_%[K0
```

## What `REGISTER.DAT` contains

`REGISTER.DAT` is a plain-text database of vendors, products, and license records.

A representative entry looks like this:

```text
VENDOR "Vendor Name" "Contact Name" 500
PRODUCT "Example VIS Title" 1
LICENSE C DATE "4-SEP-25"
```

For key generation, the important values are:

```text
Vendor ID
Product ID
License class
```

The vendor name, contact name, product title, and date appear to be bookkeeping fields for the registration database. The key-generation algorithm itself appears to use only the numeric vendor ID, numeric product ID, and license class.

## Relationship to MAKETAT job files

A MAKETAT job file contains the `REGISTER` line, the title metadata, and the startup instructions used to generate `CONTROL.TAT`.

For example:

```text
REGISTER fF<kJ+L?0[WZ)C!_%[K0

TITLE "Example VIS Title"

PROGRAM 1 "A:cardtal2.exe"

PAGE 1
BUTTON 1 0 RUN 1
```

`REGISTER.EXE` generates the key.

`MAKETAT.EXE` validates the key.

The generated `CONTROL.TAT` must then be placed on the VIS disc. The VIS boot/runtime environment looks for `CONTROL.TAT` and follows the startup instructions compiled into it.

## Character alphabet

`REGISTER.EXE` uses a custom 64-character alphabet to encode the registration key.

The alphabet is:

```text
!#$%&()*+-./0123456789<=>?@ABCDEFGHIJKLMNPQRSTUVWXYZ[]_abcdefghk
```

Important details:

- The key is 20 characters long.
- Each character encodes 6 bits.
- 20 characters times 6 bits equals 120 encoded bits.
- Those 120 bits represent 30 nibbles.
- Each nibble is 4 bits.

## Confirmed sample

For this input:

```text
Vendor:  500
Product: 1
Class:   A
```

`REGISTER.EXE` generates:

```text
fF<kJ+L?0[WZ)C!_%[K0
```

This is an important reference sample because it confirms that the recreated algorithm matches the original Tandy tool behavior.

## License classes

The `REGISTER.EXE` user interface offers two visible license classes:

```text
A  Fully licensed to use VIS logo
C  Not licensed to use VIS logo
```

The code also contains an internal mapping for `B`, but this version of the UI does not offer `B` as a normal selectable option.

The internal class mapping found in this executable is:

```text
A -> internal field 1
B -> internal field 2
C -> internal field 0
```

There is no `D` mapping in this copy of `REGISTER.EXE`.

A hypothetical hidden class `D` is not referenced by the prompt text or by the class mapping logic found in this executable.

## Relationship to `MAKETAT.EXE`

`REGISTER.EXE` generates the 20-character key.

`MAKETAT.EXE` validates the 20-character key.

The key is placed in a MAKETAT job file using a line like:

```text
REGISTER fF<kJ+L?0[WZ)C!_%[K0
```

`MAKETAT.EXE` then checks the registration key before producing `CONTROL.TAT`.

For normal homebrew work, class `C` is the safest default because it does not imply official VIS logo authorization.

## Algorithm summary

The registration-key algorithm can be summarized as follows.

### 1. Initialize payload nibbles

Start with 24 nibbles initialized to `4`.

Conceptually:

```text
nibbles[0..23] = 4
```

These 24 nibbles form the main encoded payload before the final license and checksum fields are appended.

### 2. Encode the vendor ID

Encode the vendor ID across paired nibbles `0..7` using low-bit planes.

This spreads the vendor number across multiple nibbles rather than storing it directly as a simple integer field.

### 3. Encode the product ID

Encode the product ID across paired nibbles `0..4` using high-bit planes.

The product ID is interleaved into a different bit plane from the vendor ID.

### 4. Encode the license field

Encode the internal license field across paired nibbles `5..6` using high-bit planes.

The internal license field uses this mapping:

```text
A -> 1
B -> 2
C -> 0
```

### 5. Encode reserved fields

Reserved fields are encoded as zero.

These appear to occupy space in the payload structure but are not used by the visible workflow in this recovered toolset.

### 6. Scramble the payload

Scramble the first 24 nibbles using a fixed 16-entry lookup table.

This makes the resulting key less directly readable while remaining simple and deterministic.

### 7. Append license-class nibble

Append a visible license-class nibble:

```text
ord(class) - ord('A')
```

That means:

```text
A -> 0
B -> 1
C -> 2
D -> 3, theoretically
```

However, this does not mean class `D` is supported by the recovered tools. It only means the final class nibble format could numerically represent it.

### 8. Append checksum nibbles

Append four checksum nibbles generated from a pairwise 16-bit sum.

Then append one XOR checksum nibble.

The final structure is:

```text
24 scrambled payload nibbles
1 license-class nibble
4 sum-check nibbles
1 XOR-check nibble
```

Total:

```text
30 nibbles
```

### 9. Pack into 20 encoded characters

The 30 nibbles represent:

```text
30 nibbles times 4 bits = 120 bits
```

Those 120 bits are packed into:

```text
20 characters times 6 bits = 120 bits
```

Each 6-bit value is encoded using the custom 64-character alphabet:

```text
!#$%&()*+-./0123456789<=>?@ABCDEFGHIJKLMNPQRSTUVWXYZ[]_abcdefghk
```

The result is the final 20-character registration key.

## Practical result

The Python implementation, `vis_register.py`, recreates the key-generation behavior of `REGISTER.EXE`.

For example:

```bash
python3 vis_register.py --vendor 500 --product 1 --class A
```

produces:

```text
fF<kJ+L?0[WZ)C!_%[K0
```

For homebrew use, class `C` is recommended:

```bash
python3 vis_register.py --vendor 500 --product 1 --class C
```

The generated key should then be placed into the `REGISTER` line of a MAKETAT job file.

## What this does not do

This key generator does not create a complete VIS title.

It only replaces the original `REGISTER.EXE` key-generation step.

The remaining process still requires:

```text
MAKETAT.EXE
A valid MAKETAT job file, such as JOBD
A target executable or loader referenced by the job file
A final VIS-compatible disc layout
```

The generated `CONTROL.TAT` must still launch something meaningful on the disc.

## Notes on class D

A hidden class `D` has been rumored, but this recovered `REGISTER.EXE` does not expose or map it.

The final license-class nibble could theoretically encode `D` as:

```text
D -> 3
```

because the nibble is derived from:

```text
ord(class) - ord('A')
```

However, this copy of `REGISTER.EXE` does not contain a class `D` mapping, and the recovered `MAKETAT.EXE` does not appear to accept class `D`.

The current finding is:

```text
A = supported
B = internally referenced but not offered by REGISTER.EXE UI
C = supported
D = not supported by the recovered REGISTER.EXE / MAKETAT.EXE pair
```

## Summary

`REGISTER.EXE` is a deterministic registration-key generator.

It uses:

```text
Vendor ID
Product ID
License class
```

to produce a 20-character key.

That key is placed into a MAKETAT job file, where `MAKETAT.EXE` validates it and generates `CONTROL.TAT`.

For modern homebrew use, the recovered process can be simplified to:

```text
vis_register.py -> registration key
registration key + JOBD -> MAKETAT.EXE -> CONTROL.TAT
```

The rest of the VIS title development process is separate from the registration-key mechanism.
