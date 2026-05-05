# VISENV

VISENV is an experimental model of the Memorex/Tandy VIS ROM boot/runtime environment.

## What is VISENV?

VISENV is not an emulator yet. It is a test harness and runtime model for the parts of the VIS that make it different from a normal DOS PC. 

A VIS title does not simply boot from CD and run like a regular DOS game. The system starts from ROM, launches several built-in 
runtime modules, waits for `CONTROL.TAT`, validates the title, and then decides whether to launch a DOS program or hand off to 
the Modular Windows runtime. VISENV models that path so homebrew developers can test their disc layout, `CONTROL.TAT`, launch 
command, ROMWINTOC files, and expected VIS services before burning media or debugging on real hardware. 

In plain terms: VISENV gives us a safe place to answer, “Would the VIS even understand and try to launch this title?” before 
we move on to the much harder work of video, audio, controller, and full hardware behavior.

## Technical Information

VISENV is currently a Python scaffold with:

- ROM EXEC resolver model
- fake interrupt dispatcher
- virtual drive mapping
- minimal CONTROL.TAT parser
- module stubs for COMMAND, MSCDEX, GBIOS, REDIR, ROMA, ROMB, MINWIN, TLAUNCH
- raw-module loader experiment scaffold

Usage:

```bash
python3 src/visenv.py --media-a examples/media_a_with_control_tat
```
