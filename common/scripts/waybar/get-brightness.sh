#!/usr/bin/env python3
import subprocess
import sys

def get_brightness():
    pct = None
    try:
        raw = subprocess.check_output(
            ["brightnessctl", "-m"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()
        parts = raw.split(",")
        if len(parts) >= 4:
            pct_str = parts[3].replace("%", "").strip()
            pct = int(pct_str)
    except Exception:
        pass

    if pct is None:
        try:
            with open("/sys/class/backlight/intel_backlight/actual_brightness") as f:
                curr = int(f.read().strip())
            with open("/sys/class/backlight/intel_backlight/max_brightness") as f:
                max_b = int(f.read().strip())
            pct = int(round(curr * 100 / max_b))
        except Exception:
            pct = 50

    if pct < 30:
        icon = "󰃞"
    elif pct < 70:
        icon = "󰃟"
    else:
        icon = "󰃠"

    return f"{icon}   {pct}%"

if __name__ == "__main__":
    print(get_brightness())
