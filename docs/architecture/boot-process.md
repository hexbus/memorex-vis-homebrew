# VIS Boot Process

The VIS starts from a PC-compatible foundation but uses a custom ROM-centered boot flow.

## High-level sequence

```text
Phoenix-derived BIOS / POST
  -> option-ROM scan
  -> D8800 VIS option ROM
  -> ROM DOS-like boot core
  -> EXEC "COMMAND"
  -> ROM EXEC resolver
  -> COMMAND dispatcher
  -> EXEC "mscdex"
  -> EXEC "gbios"
  -> EXEC "redir"
  -> EXEC "roma"
  -> EXEC "romb"
  -> loop EXEC "tlaunch"
```

## Why this matters

`COMMAND`, `MSCDEX`, `GBIOS`, `REDIR`, and `TLAUNCH` are not normal files on a disk. They are ROM-resident modules launched through a custom ROM EXEC resolver.

A generic PC emulator booting DOS is not enough to model the VIS. The VIS-specific ROM runtime must be accounted for.
