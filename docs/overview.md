# Project Overview

The Memorex / Tandy Video Information System is a 1992 CD-ROM-based multimedia system built on a PC-compatible foundation, but it does not behave like a normal desktop PC.

This project documents the VIS boot/runtime environment and provides tools to support homebrew development.  It is enough to get serious software 
engineers to ask questions and merge requests to improve the repo are definitely welcome!  (I am not perfect, so I'm sure there are likely errors in here.)

## Core model

```text
Phoenix-derived BIOS
  -> D8800 VIS option ROM
  -> ROM DOS-like boot core
  -> ROM EXEC resolver
  -> COMMAND dispatcher
  -> MSCDEX / GBIOS / REDIR / ROMA / ROMB
  -> TLAUNCH media/title loop
  -> CONTROL.TAT validation
  -> DOS title launch or minwin b:
```

## Main project goals

1. Make the VIS boot process understandable.
2. Provide tools to create and inspect homebrew title-control files.
3. Extract and document ROM-resident runtime files.
4. Help developers determine whether simple DOS programs are likely to work.
5. Build a VISENV scaffold that models the runtime services needed for homebrew.
6. Document the hardware enough to guide future emulation and software support.
7. Encourage Open Source Community participation to improve the documentation and software support for the VIS, especially VISENV

## What this is not

This is not a commercial VIS SDK replacement and not a full emulator. It is a community homebrew research and development kit.
