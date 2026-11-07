#!/usr/bin/env python3
import subprocess
import json
import os

def get_bt_status():
    has_btctl = os.path.exists("/usr/bin/bluetoothctl")

    # Check rfkill first
    blocked = False
    try:
        rf = subprocess.check_output(["rfkill", "list", "bluetooth"], stderr=subprocess.DEVNULL).decode()
        if "Soft blocked: yes" in rf or "Hard blocked: yes" in rf:
            blocked = True
    except Exception:
        pass

    if blocked or not has_btctl:
        if not has_btctl:
            return {"text": "󰂲", "tooltip": "Bluetooth: Daemon not installed (Click to setup)", "class": "disabled"}
        return {"text": "󰂲", "tooltip": "Bluetooth: Disabled / Blocked", "class": "disabled"}

    # Check bluetoothctl
    try:
        out = subprocess.check_output(["bluetoothctl", "show"], stderr=subprocess.DEVNULL).decode()
        if "Powered: yes" not in out:
            return {"text": "󰂲", "tooltip": "Bluetooth: Powered Off", "class": "off"}
    except Exception:
        return {"text": "󰂲", "tooltip": "Bluetooth: Inactive", "class": "off"}

    # Check connected devices
    try:
        devs = subprocess.check_output(["bluetoothctl", "devices", "Connected"], stderr=subprocess.DEVNULL).decode().strip()
        if devs:
            lines = devs.splitlines()
            names = [l.split(" ", 2)[-1] for l in lines if len(l.split(" ", 2)) >= 3]
            tip = f"Bluetooth: Connected to {', '.join(names)}"
            return {"text": "󰂱", "tooltip": tip, "class": "connected"}
    except Exception:
        pass

    return {"text": "󰂯", "tooltip": "Bluetooth: Powered On (No devices connected)", "class": "on"}

if __name__ == "__main__":
    print(json.dumps(get_bt_status()))
