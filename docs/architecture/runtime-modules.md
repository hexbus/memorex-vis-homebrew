# Runtime Modules

## COMMAND

A fixed ROM dispatcher. It starts the runtime service stack and then loops into TLAUNCH.

## MSCDEX

CD-ROM/media service layer. This supports the later `A:\CONTROL.TAT` file path.

## GBIOS

VISBIOS / low-level service layer for system, input, video, audio, timer, and storage-related services.

## REDIR

Redirector and configuration provider. Supplies embedded/default SYSTEM.INI-style behavior.

## ROMA / ROMB

External ROM probe modules for additional ROM windows.

## TLAUNCH

Title/media gatekeeper. Opens and validates CONTROL.TAT, then launches DOS or Modular Windows paths.

## MINWIN

Bridge to Modular Windows and the ROMWINTOC-backed B: runtime.
