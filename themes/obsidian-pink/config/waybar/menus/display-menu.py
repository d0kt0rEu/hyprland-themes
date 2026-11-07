#!/usr/bin/env python3
import subprocess
import json
import sys

def get_brightness_pct():
    try:
        raw = subprocess.check_output(["brightnessctl", "-m"], stderr=subprocess.DEVNULL).decode().strip()
        parts = raw.split(",")
        if len(parts) >= 4:
            return parts[3].strip()
    except Exception:
        pass
    return "50%"

def get_current_monitor():
    try:
        mons = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], stderr=subprocess.DEVNULL).decode())
        if mons:
            return mons[0]
    except Exception:
        pass
    return {"name": "eDP-1", "width": 3840, "height": 2400, "refreshRate": 59.99, "scale": 2}

def run_fuzzel(options, prompt="Display Settings > ", lines=None, width=50, x_margin=95):
    if lines is None:
        lines = len(options)
    menu_input = "\n".join(options).encode("utf-8")
    try:
        p = subprocess.Popen(
            [
                "fuzzel",
                "--dmenu",
                "--anchor=top-left",
                f"--x-margin={x_margin}",
                "--y-margin=46",
                f"--width={width}",
                f"--lines={lines}",
                "--border-width=2",
                "--border-color=ff2a85ff",
                "--border-radius=14",
                "--background-color=0f0c16fa",
                "--text-color=d5c0f2ff",
                "--prompt-color=ff2a85ff",
                "--selection-color=381a5aff",
                "--selection-text-color=ffffffff",
                "--selection-match-color=ff79c6ff",
                "--selection-radius=8",
                f"--prompt={prompt}"
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )
        stdout, _ = p.communicate(input=menu_input)
        return stdout.decode("utf-8").strip()
    except Exception:
        return ""

def main():
    b_pct = get_brightness_pct()
    mon = get_current_monitor()

    w = mon.get("width", 3840)
    h = mon.get("height", 2400)
    hz = round(float(mon.get("refreshRate", 60)), 1)
    scale = mon.get("scale", 2)
    m_name = mon.get("name", "eDP-1")

    options = [
        f"󰃠 Brightness: {b_pct}",
        f"󰍹 Resolution: {w}x{h} @ {hz}Hz  (Scale {scale}x)",
        "──────────────────────────────────────────────",
        "󰃠 Set Brightness: 100%",
        "󰃠 Set Brightness: 80%",
        "󰃟 Set Brightness: 60%",
        "󰃞 Set Brightness: 40%",
        "󰃞 Set Brightness: 20%",
        "󰃞 Set Brightness: 5%",
        "──────────────────────────────────────────────",
        "󰍹 Resolution: 3840x2400 @ 60Hz (Native 4K+)",
        "󰍹 Resolution: 3840x2400 @ 48Hz (Battery Saver)",
        "󰍹 Resolution: 1920x1200 @ 60Hz (FHD+ High Performance)",
        "󰍹 Resolution: 2560x1600 @ 60Hz (QHD+ Balanced)",
        "──────────────────────────────────────────────",
        "󰕭 Display Scale: 2.0x (Standard Retina)",
        "󰕭 Display Scale: 1.75x (Expanded Desktop)",
        "󰕭 Display Scale: 1.5x (Compact)",
        "󰕭 Display Scale: 1.25x",
        "󰕭 Display Scale: 1.0x (Native 1:1 Pixels)",
        "──────────────────────────────────────────────",
        "󰛩 Orientation: Normal (0°)",
        "󰛩 Orientation: Rotate Right (90°)",
        "󰛩 Orientation: Inverted (180°)",
        "󰛩 Orientation: Rotate Left (270°)"
    ]

    choice = run_fuzzel(options, prompt="Display Settings > ", width=52, x_margin=95)
    if not choice:
        return

    # Brightness handlers
    if "Set Brightness:" in choice:
        pct_val = choice.split(":")[-1].strip()
        subprocess.run(["brightnessctl", "set", pct_val])
        # Pop up brightness OSD pill
        subprocess.Popen([os.path.expanduser("~/.config/waybar/scripts/brightness-osd.sh")])

    # Resolution handlers
    elif "Resolution: 3840x2400 @ 60Hz" in choice:
        apply_monitor(m_name, "3840x2400@59.99400", scale, 0)
    elif "Resolution: 3840x2400 @ 48Hz" in choice:
        apply_monitor(m_name, "3840x2400@47.99000", scale, 0)
    elif "Resolution: 1920x1200 @ 60Hz" in choice:
        apply_monitor(m_name, "1920x1200@60", 1, 0)
    elif "Resolution: 2560x1600 @ 60Hz" in choice:
        apply_monitor(m_name, "2560x1600@60", 1.5, 0)

    # Scale handlers
    elif "Display Scale: 2.0x" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", 2.0, 0)
    elif "Display Scale: 1.75x" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", 1.75, 0)
    elif "Display Scale: 1.5x" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", 1.5, 0)
    elif "Display Scale: 1.25x" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", 1.25, 0)
    elif "Display Scale: 1.0x" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", 1.0, 0)

    # Orientation handlers
    elif "Orientation: Normal" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", scale, 0)
    elif "Orientation: Rotate Right" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", scale, 1)
    elif "Orientation: Inverted" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", scale, 2)
    elif "Orientation: Rotate Left" in choice:
        apply_monitor(m_name, f"{w}x{h}@{hz}", scale, 3)

def apply_monitor(output, mode, scale, transform):
    lua_code = f'hl.monitor({{ output = "{output}", mode = "{mode}", position = "0x0", scale = {scale}, transform = {transform} }})'
    subprocess.run(["hyprctl", "eval", lua_code])

if __name__ == "__main__":
    main()
