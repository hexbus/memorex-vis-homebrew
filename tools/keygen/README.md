# VIS registration key tool

`vis_register_keygen.py` is present so the repo has the expected keygen entry point.

Important status note: the included script has the stable CLI and the known sample vector, but the generalized production algorithm is still marked as placeholder until the verified bit-plane/checksum implementation is dropped in.

Known sample:

```bash
python3 tools/keygen/vis_register_keygen.py --vendor 500 --product 1 --class A
```

Expected:

```text
fF<kJ+L?0[WZ)C!_%[K0
```
