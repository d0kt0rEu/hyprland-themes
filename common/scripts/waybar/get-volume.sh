#!/usr/bin/env python3
import subprocess
import sys

def get_volume():
    try:
        raw = subprocess.check_output(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()
    except Exception:
        return "   50%"

    if "[MUTED]" in raw:
        return "󰝟   MUTED"

    parts = raw.split()
    if len(parts) >= 2:
        try:
            val = float(parts[1])
            pct = int(round(val * 100))
            if pct == 0:
                icon = ""
            elif pct < 40:
                icon = ""
            else:
                icon = ""
            return f"{icon}   {pct}%"
        except Exception:
            pass

    return "   --"

if __name__ == "__main__":
    print(get_volume())
