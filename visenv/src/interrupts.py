from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Dict

@dataclass
class InterruptResult:
    carry: bool
    ax: int = 0
    bx: int = 0
    cx: int = 0
    dx: int = 0
    data: Dict[str, Any] | None = None

class CallableInterrupts:
    """Callable fake interrupt service layer.

    This is not CPU emulation. It gives VISENV modules a consistent way to
    request known VIS/DOS services and receive logged placeholder results.
    """

    def __init__(self, env: "VisEnv") -> None:
        self.env = env

    def int15(self, ax: int, **kwargs) -> InterruptResult:
        self.env.trace.add("INT15", "call", ax=f"{ax:04X}h", **kwargs)
        if ax == 0x7100:
            return InterruptResult(False, ax=0x0000, data={"service": "VIS system", "status": "stub-present"})
        if ax == 0x7101:
            return InterruptResult(False, ax=0x0000, data={"service": "hand-controller", "event": None})
        return InterruptResult(True, ax=0x8600, data={"error": "unsupported INT15 service"})

    def int2f(self, ax: int, **kwargs) -> InterruptResult:
        owners = self.env.services.owners("INT 2Fh")
        self.env.trace.add("INT2F", "multiplex call", ax=f"{ax:04X}h", owners=", ".join(owners), **kwargs)
        return InterruptResult(False, ax=0x0000, data={"owners": owners, "status": "logged-only"})

    def int6f(self, ax: int = 0, **kwargs) -> InterruptResult:
        self.env.trace.add("INT6F", "REDIR/config call", ax=f"{ax:04X}h", **kwargs)
        return InterruptResult(False, ax=0x0000, data={"status": "stub-present"})
