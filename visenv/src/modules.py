from __future__ import annotations
from typing import TYPE_CHECKING
from control_tat import parse_control_tat
from tlaunch_model import model_tlaunch

if TYPE_CHECKING:
    from visenv_core import VisEnv

class Module:
    name = "UNKNOWN"
    def run(self, env: "VisEnv") -> None:
        env.trace.add(self.name, "stub executed")

class Command(Module):
    name = "COMMAND"
    def run(self, env: "VisEnv") -> None:
        env.trace.add(self.name, "custom VIS dispatcher starts")
        for target in ["mscdex", "gbios", "redir", "roma", "romb", "tlaunch"]:
            env.dos.int21_exec(target, caller=self.name)

class Mscdex(Module):
    name = "MSCDEX"
    def run(self, env: "VisEnv") -> None:
        env.services.register("INT 21h", self.name, "CD-ROM/media file and EXEC interception")
        env.services.register("INT 2Fh", self.name, "MSCDEX/CD-ROM multiplex")
        env.state["drive_a"] = "CD-ROM/media"
        env.trace.add(self.name, "CD-ROM/media stub installed")

class Gbios(Module):
    name = "GBIOS"
    def run(self, env: "VisEnv") -> None:
        families = ["AX=7100h system", "AX=7101h hand-control", "memory-card", "wave", "synth", "mixer", "timer"]
        env.services.register("INT 15h", self.name, "VISBIOS service dispatcher", families=families)
        env.services.register("INT 2Fh", self.name, "Modular Windows/VISBIOS multiplex")
        env.services.register("GBIOS:VIDEO", self.name, "Gryphon video service placeholder")
        env.services.register("GBIOS:AUDIO", self.name, "AdLib Gold-like audio service placeholder")
        env.services.register("GBIOS:HAND", self.name, "hand-controller service placeholder")
        env.services.register("GBIOS:CYBERCARD", self.name, "CyberCard/Save-It service placeholder")
        env.trace.add(self.name, "VISBIOS service stubs installed", families=", ".join(families))

class Redir(Module):
    name = "REDIR"
    def run(self, env: "VisEnv") -> None:
        env.services.register("INT 6Fh", self.name, "redirector/config provider")
        env.services.register("INT 15h", self.name, "GBIOS dependency/call-through")
        env.services.register("INT 2Fh", self.name, "redirector multiplex")
        env.state["embedded_system_ini"] = "[boot]\\nshell=cdplayer.exe\\ndisplay.drv=vga.drv\\n"
        env.trace.add(self.name, "redirector/config stub installed")

class Roma(Module):
    name = "ROMA"
    def run(self, env: "VisEnv") -> None:
        env.trace.add(self.name, "external ROM probe", address="C000:0000", signature="ER")

class Romb(Module):
    name = "ROMB"
    def run(self, env: "VisEnv") -> None:
        env.trace.add(self.name, "external ROM probe", address="C400:0000", signature="ER")

class Minwin(Module):
    name = "MINWIN"
    def run(self, env: "VisEnv") -> None:
        env.trace.add(self.name, "Modular Windows handoff stub", target="F4000 ROMWINTOC loader")

class Tlaunch(Module):
    name = "TLAUNCH"
    def run(self, env: "VisEnv") -> None:
        env.services.register("INT 21h", self.name, "title executable guardrail / launch filter")
        env.services.register("INT 2Fh", self.name, "title/runtime multiplex")
        env.trace.add(self.name, "waiting for disc/cartridge")

        handle = env.dos.int21_open(r"A:\CONTROL.TAT")
        if handle < 0:
            env.trace.add(self.name, "A:\\CONTROL.TAT unavailable; still waiting")
            return

        data = env.dos.int21_read(handle, 4096)
        info = parse_control_tat(env.media_a / "CONTROL.TAT")
        report = model_tlaunch(env.media_a / "CONTROL.TAT")
        env.control_tat_info = info
        env.tlaunch_report = report
        env.trace.add(self.name, "CONTROL.TAT parsed", size=info.size, has_registration_payload=info.has_registration_payload, has_maketat_marker=info.has_maketat_marker_area, has_authorized_statement=info.has_authorized_statement, launch_kind=report.launch_kind, launch_target=report.launch_target)
        for state in report.states:
            env.trace.add(self.name, "TLAUNCH state", state=state)
        env.trace.add(self.name, "would call production validator", anchor="0xEC290")
        if report.launch_kind == "minwin":
            env.dos.int21_exec(report.launch_target or "minwin b:", caller=self.name)
        elif report.launch_kind == "media_executable" and report.launch_target:
            env.dos.int21_exec(report.launch_target, caller=self.name)
        else:
            env.trace.add(self.name, "title launch not allowed by VISENV model")
