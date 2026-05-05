from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2] / "visenv" / "src"
sys.path.insert(0, str(ROOT))

from visenv_core import VisEnv

env = VisEnv()
env.boot()
if hasattr(env, "interrupts"):
    print(env.interrupts.int15(0x7100))
    print(env.interrupts.int15(0x7101))
    print(env.interrupts.int2f(0x8100))
    print(env.interrupts.int6f(0))
else:
    print("Callable interrupt scaffold not available in this build.")
