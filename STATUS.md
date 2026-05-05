# Project Status

This project is currently a **developer preview** for VIS homebrew development.

## Usable now

| Area | Status |
|---|---|
| REGISTER-style keygen | Works for the implemented algorithm and validates the known sample vector |
| CONTROL.TAT inspection | Works for known fields and heuristic launch diagnostics |
| ROM extraction | Extracts known VIS ROM regions and ROMWINTOC B: runtime files |
| VISENV boot model | Models the boot/title-launch path through TLAUNCH and MINWIN handoff |
| DOS compatibility triage | Static scanner flags common VIS risk patterns |
| GBIOS/input/video stubs | Callable placeholders exist |
| Audio / CyberCard stubs | Service-backed placeholders exist |
| Hardware reference | Initial unit photo inventory included |

## Not complete

| Area | Remaining work |
|---|---|
| CONTROL.TAT validator | Needs deeper byte-level parity with production ROM |
| GBIOS service map | Needs verified service numbers, inputs, outputs, and error behavior |
| Video behavior | Needs real hardware testing by mode |
| Input behavior | Needs keyboard/controller hardware validation |
| Modular Windows runtime | Handoff diagnostics exist, but it does not boot the runtime |
| ROM annotated assembly | Needs more exact byte-addressed chunks |
| v1.0 readiness | Requires hardware-tested homebrew path |
