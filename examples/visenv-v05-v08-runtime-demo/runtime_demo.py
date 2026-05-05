from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[2] / "visenv" / "src"
sys.path.insert(0, str(ROOT))

from gbios_services import GbiosServices
from audio_stub import AudioStub
from cybercard_stub import CyberCardStub
from minwin_model import model_minwin

gbios = GbiosServices()
print("GBIOS 7100:", gbios.int15(0x7100))
print("GBIOS 7101:", gbios.int15(0x7101))
print("Video 13h:", gbios.set_video_mode(0x13))

audio = AudioStub()
print("Audio GM on:", audio.set_general_midi(True))
print("Program 0:", audio.program_name(0))

card_path = Path(__file__).with_name("cybercard_test.img")
card = CyberCardStub(card_path)
print("CyberCard:", card.status())

print("MINWIN:", model_minwin("minwin b:"))
