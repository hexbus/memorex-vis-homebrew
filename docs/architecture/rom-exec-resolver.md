# ROM EXEC Resolver

The VIS uses DOS `INT 21h AH=4Bh` EXEC semantics, but extends the behavior for ROM-resident modules.

## Classification

```text
COMMAND
gbios
redir
tlaunch
  -> ROM export launch

A:\START.EXE
A:\GAME.COM
  -> media executable launch

minwin b:
  -> title/minwin launch after CONTROL.TAT validation

A:\FRANKS_UNLIKELY.EXE
  -> fake/probe executable used by TLAUNCH guardrail behavior
```

## Developer implication

Do not treat ROM exports as recovered standalone EXE files. They expect the VIS ROM runtime context.
