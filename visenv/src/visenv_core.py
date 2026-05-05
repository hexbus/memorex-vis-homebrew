from __future__ import annotations
from pathlib import Path
from typing import Dict, Optional

from trace import Trace
from services import VirtualInterruptTable, FakeDos
from media_exec import inspect_media_executable
from romexec import RomExecResolver, RomExport
from interrupts import CallableInterrupts
from modules import Command, Mscdex, Gbios, Redir, Roma, Romb, Tlaunch, Minwin

class VisEnv:
    def __init__(self, media_a: Optional[Path] = None, rom_b: Optional[Path] = None) -> None:
        self.media_a = media_a
        self.rom_b = rom_b
        self.trace = Trace()
        self.services = VirtualInterruptTable()
        self.dos = FakeDos(self)
        self.interrupts = CallableInterrupts(self)
        self.state: Dict[str, object] = {}
        self.control_tat_info = None

        self.exports = {
            "COMMAND": RomExport("COMMAND", "DC3C:0000", "custom VIS dispatcher"),
            "MSCDEX": RomExport("MSCDEX", "DC46:0000", "CD-ROM/media service layer"),
            "GBIOS": RomExport("GBIOS", "E166:0000", "VISBIOS service layer"),
            "REDIR": RomExport("REDIR", "E8AD:0000", "redirector/config provider"),
            "ROMA": RomExport("ROMA", "C000:0000?", "external ROM probe"),
            "ROMB": RomExport("ROMB", "C400:0000?", "external ROM probe"),
            "TLAUNCH": RomExport("TLAUNCH", "E988:0000", "title launcher"),
            "MINWIN": RomExport("MINWIN", "E158:0000", "Modular Windows starter"),
        }
        self.resolver = RomExecResolver(self.exports)
        self.modules = {
            "COMMAND": Command(),
            "MSCDEX": Mscdex(),
            "GBIOS": Gbios(),
            "REDIR": Redir(),
            "ROMA": Roma(),
            "ROMB": Romb(),
            "TLAUNCH": Tlaunch(),
            "MINWIN": Minwin(),
        }

    def boot(self) -> None:
        self.trace.add("BOOT", "Phoenix BIOS / D8800 option-ROM handoff modeled")
        self.trace.add("BOOT", "D8960 boot core requests EXEC COMMAND")
        self.dos.int21_exec("COMMAND", caller="D8960 boot core")

    def exec(self, target: str, caller: str) -> None:
        kind = self.resolver.classify(target)
        self.trace.add("EXEC", "classified EXEC target", caller=caller, target=target, classification=kind)
        if kind in ("ROM export launch", "title/minwin launch after CONTROL.TAT validation"):
            exp = self.resolver.resolve(target)
            if not exp:
                self.trace.add("ROMEXEC", "export not found", target=target)
                return
            self.trace.add("ROMEXEC", "resolved ROM export", name=exp.name, entry=exp.entry, role=exp.role)
            self.modules[exp.name].run(self)
        elif kind == "fake/probe executable launch":
            self.trace.add("EXEC", "fake probe blocked", target=target, expected_ax="6664h")
        else:
            info = inspect_media_executable(self.media_a, target)
            self.trace.add("EXEC", "real media executable launch classified", target=info.target, exists=info.exists, format=info.format, action=info.action, reason=info.reason)
