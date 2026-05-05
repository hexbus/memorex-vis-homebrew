#!/usr/bin/env python3
"""
VIS REGISTER.EXE key generator, reconstructed from the Tandy VIS REGISTER.EXE.

This generates the 20-character registration key that MAKETAT expects on the
REGISTER line in a VIS .JOB file.

Known validation vector:
    vendor=500, product=1, class=A -> fF<kJ+L?0[WZ)C!_%[K0
"""

from __future__ import annotations

import argparse

SCRAMBLE_TABLE = [0x06, 0x0D, 0x05, 0x07, 0x0F, 0x01, 0x04, 0x0B,
                  0x08, 0x02, 0x09, 0x0C, 0x00, 0x0E, 0x0A, 0x03]

ALPHABET = "!#$%&()*+-./0123456789<=>?@ABCDEFGHIJKLMNPQRSTUVWXYZ[]_abcdefghk"

def _encode_low_bit_pairs(nibbles, value, start_pair, end_pair):
    """REGISTER routine at 0x044A: ORs bit 0 into paired nibbles."""
    for pair in range(start_pair, end_pair + 1):
        if value & 1:
            nibbles[2 * pair + 1] |= 0x1
        if value & 2:
            nibbles[2 * pair] |= 0x1
        value >>= 2

def _encode_high_bit_pairs(nibbles, value, start_pair, end_pair):
    """REGISTER routine at 0x049E: ORs bit 3 into paired nibbles."""
    for pair in range(start_pair, end_pair + 1):
        if value & 1:
            nibbles[2 * pair + 1] |= 0x8
        if value & 2:
            nibbles[2 * pair] |= 0x8
        value >>= 2

def _scramble_first_24_nibbles(nibbles):
    """REGISTER routine at 0x0660."""
    prev = 0
    for idx in range(24):
        v = (SCRAMBLE_TABLE[(nibbles[idx] + idx) & 0x0F] - idx) & 0xFFFF
        v ^= prev
        prev = v
        nibbles[idx] = v & 0x0F

def _append_checks(nibbles, license_class):
    """REGISTER checksum logic around 0x0327-0x03A4."""
    nibbles.append(ord(license_class) - ord("A"))

    s = 0
    for i in range(0, 24, 2):
        s = (s + nibbles[i] + (nibbles[i + 1] << 8)) & 0xFFFF

    for _ in range(4):
        nibbles.append(s & 0x0F)
        s >>= 4

    x = 0
    for i in range(24):
        x ^= nibbles[i]
    nibbles.append(x & 0x0F)

def _pack_to_key(nibbles):
    """REGISTER routine at 0x05B6 packs 30 nibbles into 20 six-bit chars."""
    bits = []
    for v in nibbles:
        for shift in (3, 2, 1, 0):
            bits.append((v >> shift) & 1)

    chars = []
    for i in range(0, len(bits), 6):
        idx = 0
        for bit in bits[i:i + 6]:
            idx = (idx << 1) | bit
        chars.append(ALPHABET[idx])
    return "".join(chars)

def generate_key(vendor_id, product_id, license_class):
    license_class = license_class.upper()
    if license_class not in {"A", "B", "C"}:
        raise ValueError("REGISTER.EXE only contains mappings for A, B, and C. Its UI offers A and C only.")

    if not (0 <= vendor_id <= 30000):
        raise ValueError("vendor_id must be 0..30000")
    if not (0 <= product_id <= 16000):
        raise ValueError("product_id must be 0..16000")

    # REGISTER.EXE maps display class to this internal field:
    # A -> 1, B -> 2, C -> 0. D is not mapped.
    internal_license = {"A": 1, "B": 2, "C": 0}[license_class]

    nibbles = [0x4] * 24

    # Vendor number: 16 bits across pairs 0..7.
    _encode_low_bit_pairs(nibbles, vendor_id, 0, 7)

    # Unknown/reserved field: pairs 8..11. REGISTER initializes it to zero.
    _encode_low_bit_pairs(nibbles, 0, 8, 11)

    # Product number: 10 bits across pairs 0..4.
    _encode_high_bit_pairs(nibbles, product_id, 0, 4)

    # Internal license field: pairs 5..6.
    _encode_high_bit_pairs(nibbles, internal_license, 5, 6)

    # Unknown/reserved fields, both zero in REGISTER.EXE.
    _encode_high_bit_pairs(nibbles, 0, 7, 8)
    _encode_high_bit_pairs(nibbles, 0, 9, 11)

    _scramble_first_24_nibbles(nibbles)
    _append_checks(nibbles, license_class)
    return _pack_to_key(nibbles)

def main(argv=None):
    parser = argparse.ArgumentParser(description="Generate a Tandy VIS MAKETAT registration key.")
    # Accept both old positional form and newer flag form.
    parser.add_argument("positional", nargs="*", help="optional positional form: vendor_id product_id class")
    parser.add_argument("--vendor", type=int)
    parser.add_argument("--product", type=int)
    parser.add_argument("--class", dest="license_class_flag", choices=["A","B","C","a","b","c"])
    args = parser.parse_args(argv)

    if args.positional:
        if len(args.positional) != 3:
            parser.error("positional form requires: vendor_id product_id class")
        vendor_id = int(args.positional[0])
        product_id = int(args.positional[1])
        license_class = args.positional[2]
    else:
        if args.vendor is None or args.product is None or args.license_class_flag is None:
            parser.error("use either positional args or --vendor --product --class")
        vendor_id = args.vendor
        product_id = args.product
        license_class = args.license_class_flag

    print(generate_key(vendor_id, product_id, license_class))

if __name__ == "__main__":
    main()
