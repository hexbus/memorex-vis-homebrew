from __future__ import annotations
from dataclasses import dataclass, asdict
from enum import Enum
from typing import List, Dict, Any, Optional
from pathlib import Path

from control_tat import parse_control_tat, ControlTatInfo

class TlaunchState(str, Enum):
    WAITING_FOR_MEDIA = "waiting_for_media"
    CONTROL_TAT_MISSING = "control_tat_missing"
    CONTROL_TAT_OPENED = "control_tat_opened"
    CONTROL_TAT_READ = "control_tat_read"
    REGISTRATION_PAYLOAD_SEEN = "registration_payload_seen"
    MAKETAT_MARKER_SEEN = "maketat_marker_seen"
    VALIDATOR_CALLED = "validator_called"
    FAKE_PROBE_BLOCKED = "fake_probe_blocked"
    TITLE_LAUNCH_ALLOWED = "title_launch_allowed"
    MINWIN_HANDOFF = "minwin_handoff"
    MEDIA_EXECUTABLE_HANDOFF = "media_executable_handoff"
    INVALID_TITLE = "invalid_title"

@dataclass
class TlaunchReport:
    states: List[str]
    control_tat: Optional[Dict[str, Any]]
    launch_kind: str
    launch_target: Optional[str]
    warnings: List[str]

def choose_launch(info: ControlTatInfo) -> tuple[str, Optional[str]]:
    # Conservative heuristic. Real startup command extraction still needs byte-verified mapping.
    for cmd in info.possible_startup_commands:
        if "minwin" in cmd.lower():
            return "minwin", "minwin b:"
    for cmd in info.possible_startup_commands:
        low = cmd.lower()
        if ".exe" in low or ".com" in low:
            return "media_executable", cmd
    # VIS titles often use minwin b: for Modular Windows; only choose as assumed if fields look sane.
    if info.has_registration_payload and info.has_maketat_marker_area:
        return "minwin", "minwin b:"
    return "none", None

def model_tlaunch(control_tat_path: Path) -> TlaunchReport:
    states = [TlaunchState.WAITING_FOR_MEDIA.value]
    warnings: List[str] = []
    if not control_tat_path.exists():
        states.append(TlaunchState.CONTROL_TAT_MISSING.value)
        return TlaunchReport(states, None, "none", None, ["CONTROL.TAT missing"])

    states.append(TlaunchState.CONTROL_TAT_OPENED.value)
    info = parse_control_tat(control_tat_path)
    states.append(TlaunchState.CONTROL_TAT_READ.value)
    if info.has_registration_payload:
        states.append(TlaunchState.REGISTRATION_PAYLOAD_SEEN.value)
    if info.has_maketat_marker_area:
        states.append(TlaunchState.MAKETAT_MARKER_SEEN.value)

    # Simulate the guardrail probe we know TLAUNCH uses.
    states.append(TlaunchState.FAKE_PROBE_BLOCKED.value)
    states.append(TlaunchState.VALIDATOR_CALLED.value)

    launch_kind, launch_target = choose_launch(info)
    warnings.extend(info.warnings)

    if launch_kind == "minwin":
        states.append(TlaunchState.TITLE_LAUNCH_ALLOWED.value)
        states.append(TlaunchState.MINWIN_HANDOFF.value)
    elif launch_kind == "media_executable":
        states.append(TlaunchState.TITLE_LAUNCH_ALLOWED.value)
        states.append(TlaunchState.MEDIA_EXECUTABLE_HANDOFF.value)
    else:
        states.append(TlaunchState.INVALID_TITLE.value)

    return TlaunchReport(states, info.to_dict(), launch_kind, launch_target, warnings)
