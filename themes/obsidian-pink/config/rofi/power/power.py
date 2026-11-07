#!/usr/bin/env python3
import subprocess
import sys
import os
import shutil

DIR = os.path.expanduser("~/.config/rofi/power")
THEME = os.path.join(DIR, "power.rasi")

# Toggle behavior: if rofi is already open, close it and exit
try:
    pids = subprocess.check_output(["pgrep", "-x", "rofi"]).decode().strip().split()
    if pids:
        subprocess.run(["pkill", "-x", "rofi"])
        sys.exit(0)
except subprocess.CalledProcessError:
    pass

# Read Battery & Power Info
pct = "100%"
stat = "AC"
rate = ""
thresh = "80"

try:
    with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
        pct = f.read().strip() + "%"
    with open("/sys/class/power_supply/BAT0/status", "r") as f:
        stat = f.read().strip()
    if os.path.exists("/sys/class/power_supply/BAT0/charge_control_end_threshold"):
        with open("/sys/class/power_supply/BAT0/charge_control_end_threshold", "r") as f:
            thresh = f.read().strip()
except Exception:
    pass

# Query upower for power draw rate
try:
    out = subprocess.check_output(["upower", "-i", "/org/freedesktop/UPower/devices/battery_BAT0"], stderr=subprocess.DEVNULL).decode()
    for l in out.splitlines():
        if "energy-rate:" in l:
            rate = l.split(":", 1)[1].strip()
            break
except Exception:
    pass

# Read Current Profile
current_profile = "balanced"
has_platform_profile = os.path.exists("/sys/firmware/acpi/platform_profile")
if has_platform_profile:
    try:
        with open("/sys/firmware/acpi/platform_profile", "r") as f:
            current_profile = f.read().strip()
    except Exception:
        pass
elif shutil.which("powerprofilesctl"):
    try:
        current_profile = subprocess.check_output(["powerprofilesctl", "get"]).decode().strip()
    except Exception:
        pass

# Profiles list
profiles = [
    {
        "type": "profile",
        "id": "performance",
        "ppd": "performance",
        "icon": "󰓅",
        "name": "Performance",
        "desc": "Boost clocks & high thermal headroom"
    },
    {
        "type": "profile",
        "id": "balanced",
        "ppd": "balanced",
        "icon": "󰾅",
        "name": "Balanced",
        "desc": "Adaptive balance between power & speed"
    },
    {
        "type": "profile",
        "id": "quiet",
        "ppd": "power-saver",
        "icon": "󰾆",
        "name": "Quiet / Saver",
        "desc": "Silent fan profile & maximized battery life"
    },
    {
        "type": "profile",
        "id": "cool",
        "ppd": "power-saver",
        "icon": "󰈐",
        "name": "Cool",
        "desc": "Prioritize cooler chassis surface temperatures"
    },
    {
        "type": "thresh",
        "limit": 80,
        "icon": "󱐌",
        "name": "Charge Limit: 80%",
        "desc": "Recommended for Dell XPS battery longevity"
    },
    {
        "type": "thresh",
        "limit": 100,
        "icon": "󱐌",
        "name": "Charge Limit: 100%",
        "desc": "Full capacity charge for travel"
    }
]

menu_items = []
items_data = []

rate_str = f" • {rate}" if rate else ""
prompt_title = f"󰁹 Battery {pct}"
placeholder_str = f"{stat}{rate_str} • Plan: {current_profile.capitalize()}"

for p in profiles:
    if p["type"] == "profile":
        is_active = (p["id"] == current_profile or (p["id"] == "quiet" and current_profile == "power-saver"))
        tag = "  [Active]" if is_active else ""
        label = f"{p['icon']}  {p['name']:<18}  {p['desc']}{tag}"
    elif p["type"] == "thresh":
        is_active = (str(p["limit"]) == thresh)
        tag = "  [Active]" if is_active else ""
        label = f"{p['icon']}  {p['name']:<18}  {p['desc']}{tag}"
    menu_items.append(label)
    items_data.append(p)

theme_str = (
    f'entry {{ placeholder: "{placeholder_str}"; }} '
    f'listview {{ lines: {len(menu_items)}; }}'
)

# Run Rofi
input_str = "\n".join(menu_items)
try:
    proc = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", prompt_title, "-theme-str", theme_str, "-theme", THEME],
        input=input_str.encode("utf-8"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    choice = proc.stdout.decode("utf-8").strip()
except Exception:
    sys.exit(0)

if not choice:
    sys.exit(0)

selected = None
for i, item in enumerate(menu_items):
    if item == choice:
        selected = items_data[i]
        break

if not selected:
    sys.exit(0)

if selected["type"] == "profile":
    p_id = selected["id"]
    ppd_id = selected["ppd"]
    name = selected["name"]
    applied = False

    if shutil.which("powerprofilesctl"):
        res = subprocess.run(["powerprofilesctl", "set", ppd_id], capture_output=True)
        if res.returncode == 0:
            applied = True

    if not applied and has_platform_profile:
        try:
            with open("/sys/firmware/acpi/platform_profile", "w") as f:
                f.write(p_id)
            applied = True
        except PermissionError:
            cmd = f"echo '{p_id}' > /sys/firmware/acpi/platform_profile"
            res = subprocess.run(["pkexec", "sh", "-c", cmd])
            if res.returncode == 0:
                applied = True

    if applied:
        subprocess.run(["notify-send", "-a", "Power Profile", f"⚡ Power Plan: {name}", f"System profile successfully switched to {name}."])
    else:
        subprocess.run(["notify-send", "-u", "critical", "-a", "Power Profile", "⚠️ Power Profile Error", f"Failed to activate {name}."])

elif selected["type"] == "thresh":
    lim = selected["limit"]
    cmd = f"echo {lim} > /sys/class/power_supply/BAT0/charge_control_end_threshold"
    res = subprocess.run(["pkexec", "sh", "-c", cmd])
    if res.returncode == 0:
        subprocess.run(["notify-send", "-a", "Battery Limit", f"󱐌 Charge Threshold: {lim}%", f"Battery charging limit set to {lim}%."])
    else:
        subprocess.run(["notify-send", "-u", "critical", "-a", "Battery Limit", "⚠️ Battery Error", "Could not set charging threshold."])
