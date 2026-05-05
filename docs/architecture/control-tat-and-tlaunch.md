# CONTROL.TAT and TLAUNCH

`CONTROL.TAT` is the VIS title-control file. TLAUNCH waits for media, opens this file, validates it, and then launches the selected title path.

## Known fields

```text
+0x98  registration payload area
+0xB0  MAKETAT/version marker area
+0xD8  observed version-gate byte area
```

## TLAUNCH model states

VISENV models:

```text
waiting_for_media
control_tat_missing
control_tat_opened
control_tat_read
registration_payload_seen
maketat_marker_seen
fake_probe_blocked
validator_called
title_launch_allowed
minwin_handoff
media_executable_handoff
invalid_title
```

## Tools

```bash
python3 tools/controltat/controltat_report.py CONTROL.TAT
python3 tools/controltat/compare_control_tat.py A.CONTROL.TAT B.CONTROL.TAT
```

## Limitation

The parser is intentionally conservative. It provides actionable diagnostics without claiming full byte-for-byte validator parity.
