from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Dict, Any
from romwintoc import RomWinTocMount
from redir_services import RedirServices

@dataclass
class MinwinReport:
    command: str
    romwintoc_mounted: bool
    system_ini_available: bool
    boot_shell: Optional[str]
    required_runtime_found: Dict[str, bool]

def model_minwin(command: str, romwintoc_root: Optional[Path] = None) -> MinwinReport:
    mount = RomWinTocMount(romwintoc_root) if romwintoc_root else None
    redir = RedirServices()
    required = {}
    for fn in ["KERNEL.EXE", "GDI.EXE", "USER.EXE", "MMSYSTEM.DLL", "VGA.DRV"]:
        required[fn] = bool(mount and mount.find(fn))
    return MinwinReport(
        command=command,
        romwintoc_mounted=bool(mount and mount.entries),
        system_ini_available=True,
        boot_shell=redir.boot_shell(),
        required_runtime_found=required,
    )
