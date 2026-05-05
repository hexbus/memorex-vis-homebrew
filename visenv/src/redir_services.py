from __future__ import annotations

DEFAULT_SYSTEM_INI = """[boot]
shell=cdplayer.exe
mouse.drv=mouse.drv
sound.drv=sound.drv
comm.drv=comm.drv
system.drv=system.drv
drivers=mmsystem.dll
display.drv=vga.drv
keyboard.drv=keyboard.drv

[drivers]
wave=vwavmidi.drv
midi=vwavmidi.drv
timer=timer.drv
"""

class RedirServices:
    def __init__(self, system_ini: str = DEFAULT_SYSTEM_INI) -> None:
        self.system_ini = system_ini

    def get_system_ini(self) -> str:
        return self.system_ini

    def boot_shell(self) -> str | None:
        for line in self.system_ini.splitlines():
            if line.lower().startswith("shell="):
                return line.split("=", 1)[1].strip()
        return None
