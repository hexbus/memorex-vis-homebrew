import unittest, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(ROOT))
from visenv_core import VisEnv
from control_tat import parse_control_tat

class TestVisEnv(unittest.TestCase):
    def test_boot_empty_waits(self):
        env = VisEnv()
        env.boot()
        messages = [e.message for e in env.trace.events]
        self.assertTrue(any("A:\\CONTROL.TAT unavailable" in m for m in messages))
        self.assertIn("GBIOS", env.services.owners("INT 15h"))
        self.assertIn("MSCDEX", env.services.owners("INT 21h"))

    def test_boot_with_control_tat_reaches_minwin(self):
        media = Path(__file__).resolve().parents[2] / "examples" / "first-homebrew" / "media_a"
        env = VisEnv(media_a=media)
        env.boot()
        messages = [e.message for e in env.trace.events]
        self.assertTrue(any("CONTROL.TAT parsed" in m for m in messages))
        self.assertTrue(any("resolved ROM export" in m and e.data.get("name") == "MINWIN" for e, m in zip(env.trace.events, messages)))

    def test_control_tat_parser(self):
        tat = Path(__file__).resolve().parents[2] / "examples" / "first-homebrew" / "media_a" / "CONTROL.TAT"
        info = parse_control_tat(tat)
        self.assertTrue(info.present)
        self.assertTrue(info.has_registration_payload)
        self.assertTrue(info.has_maketat_marker_area)

if __name__ == "__main__":
    unittest.main()
