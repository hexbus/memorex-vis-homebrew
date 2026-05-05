# Tool Reference

## Keygen

```bash
python3 tools/keygen/vis_register_keygen.py --vendor 500 --product 1 --class C
python3 tools/keygen/validate_keygen.py
```

## CONTROL.TAT

```bash
python3 tools/controltat/controltat_report.py CONTROL.TAT
python3 tools/controltat/compare_control_tat.py OLD.TAT NEW.TAT
```

## ROM extraction

```bash
python3 tools/extract/extract_vis_rom.py VIS_BIOS_1MB.bin out/regions --wrappers
python3 tools/extract/extract_romwintoc.py VIS_BIOS_1MB.bin out/romwintoc
python3 tools/extract/extract_all.py VIS_BIOS_1MB.bin out/all --wrappers
```

## DOS compatibility

```bash
python3 tools/dos/dos_program_classifier.py PROGRAM.EXE
python3 tools/dos/batch_classify.py folder --json out/batch.json
python3 tools/dos/compatibility_report.py out/batch.json out/report.md
```
