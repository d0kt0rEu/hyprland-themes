#!/usr/bin/env python3
import json
import subprocess
import sys

def get_layout():
    try:
        raw = subprocess.check_output(["hyprctl", "devices", "-j"], stderr=subprocess.DEVNULL)
        devs = json.loads(raw)
        keyboards = devs.get("keyboards", [])
        
        # Look for the keyboard marked as main
        main_kb = next((k for k in keyboards if k.get("main")), None)
        
        # Fallback to physical keyboard or last keyboard if main is not marked
        if not main_kb:
            for k in keyboards:
                name = k.get("name", "").lower()
                if "at-translated" in name or "keyboard" in name:
                    main_kb = k
                    break
        if not main_kb and keyboards:
            main_kb = keyboards[-1]
            
        if main_kb:
            keymap = main_kb.get("active_keymap", "")
            if any(p in keymap.lower() for p in ["polish", "polski", "pl"]):
                return "PL"
            return "US"
    except Exception:
        pass
    return "US"

if __name__ == "__main__":
    layout = get_layout()
    print(f"   {layout}")
