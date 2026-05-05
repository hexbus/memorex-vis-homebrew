from __future__ import annotations
from dataclasses import dataclass, asdict
from typing import Dict, Any
from video_stub import VideoStub
from hand_controller_stub import HandControllerStub

class GbiosServices:
    def __init__(self) -> None:
        self.video = VideoStub()
        self.controller = HandControllerStub()

    def int15(self, ax: int, **kwargs) -> Dict[str, Any]:
        if ax == 0x7100:
            return {"carry": False, "service": "VIS system/status", "installed": True, "version": "VISENV-stub"}
        if ax == 0x7101:
            return {"carry": False, "service": "hand-controller", **self.controller.poll()}
        return {"carry": True, "ax": 0x8600, "error": f"unsupported GBIOS INT15 AX={ax:04X}h"}

    def set_video_mode(self, mode: int) -> Dict[str, Any]:
        return self.video.set_mode(mode)

    def list_video_modes(self):
        return self.video.list_modes()
