# VISENV Service Reference

VISENV currently includes service stubs for:

```text
GBIOS system/status
hand-controller polling
video mode registry
audio/MIDI mode and program lookup
CyberCard/Save-It backing storage
REDIR SYSTEM.INI provider
ROMWINTOC B: runtime lookup
MINWIN handoff diagnostics
```

Important files:

```text
visenv/src/gbios_services.py
visenv/src/video_stub.py
visenv/src/hand_controller_stub.py
visenv/src/audio_stub.py
visenv/src/cybercard_stub.py
visenv/src/redir_services.py
visenv/src/romwintoc.py
visenv/src/minwin_model.py
```
