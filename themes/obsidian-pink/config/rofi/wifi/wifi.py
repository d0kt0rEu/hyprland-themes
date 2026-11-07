#!/usr/bin/env python3
import subprocess
import sys
import os
import time

DIR = os.path.expanduser("~/.config/rofi/wifi")
THEME = os.path.join(DIR, "wifi.rasi")

# Toggle behavior: if rofi is already running, kill it and exit
try:
    pids = subprocess.check_output(["pgrep", "-x", "rofi"]).decode().strip().split()
    if pids:
        subprocess.run(["pkill", "-x", "rofi"])
        sys.exit(0)
except subprocess.CalledProcessError:
    pass

# Get wifi device
try:
    devs = subprocess.check_output(["nmcli", "-t", "-f", "DEVICE,TYPE", "device", "status"]).decode().splitlines()
    wifi_dev = "wlan0"
    for d in devs:
        if d.endswith(":wifi"):
            wifi_dev = d.split(":")[0]
            break
except Exception:
    wifi_dev = "wlan0"

# Get saved connections
try:
    saved_conns = set(subprocess.check_output(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]).decode().splitlines())
    saved_ssids = {c.split(":")[0] for c in saved_conns if c.endswith(":802-11-wireless") or c.endswith(":wifi")}
except Exception:
    saved_ssids = set()

# Get wifi networks
try:
    raw = subprocess.check_output(["nmcli", "-t", "-f", "IN-USE,BSSID,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]).decode("utf-8")
except Exception as e:
    subprocess.run(["notify-send", "-u", "critical", "Wi-Fi Error", f"Failed to scan networks: {e}"])
    sys.exit(1)

networks = []
seen = set()
current_ssid = None

for line in raw.splitlines():
    l_safe = line.replace(r"\:", "__COLON__")
    parts = l_safe.split(":")
    if len(parts) >= 5:
        in_use = parts[0].strip()
        bssid = parts[1].replace("__COLON__", ":").strip()
        ssid = parts[2].replace("__COLON__", ":").strip()
        try:
            signal = int(parts[3].strip())
        except ValueError:
            signal = 50
        security = parts[4].replace("__COLON__", ":").strip()

        if not ssid or ssid == "--" or ssid in seen:
            continue
        seen.add(ssid)

        is_connected = (in_use == "*")
        if is_connected:
            current_ssid = ssid

        is_open = (not security or security == "--")
        sec_label = "Open" if is_open else security
        sec_icon = "󰖩" if is_open else "󰌾"

        if signal >= 75:
            sig_icon = "󰤨"
        elif signal >= 50:
            sig_icon = "󰤥"
        elif signal >= 25:
            sig_icon = "󰤢"
        else:
            sig_icon = "󰤟"

        networks.append({
            "ssid": ssid,
            "bssid": bssid,
            "signal": signal,
            "sig_icon": sig_icon,
            "sec_label": sec_label,
            "sec_icon": sec_icon,
            "is_connected": is_connected,
            "is_open": is_open
        })

# Sort: connected first, then by signal strength descending
networks.sort(key=lambda n: (not n["is_connected"], -n["signal"]))

menu_items = []
items_data = []

for n in networks:
    if n["is_connected"]:
        label = f"󰤨  {n['ssid']:<26}  [Connected] {n['signal']:>3}%  {n['sec_label']}"
    else:
        label = f"{n['sec_icon']}  {n['ssid']:<26}  {n['sig_icon']} {n['signal']:>3}%  {n['sec_label']}"
    menu_items.append(label)
    items_data.append(n)

# Action options
menu_items.append("󰤮  Disconnect from Wi-Fi")
items_data.append({"action": "disconnect"})

menu_items.append("  Network Connections (nmtui)")
items_data.append({"action": "nmtui"})

menu_items.append("󰑓  Rescan Networks")
items_data.append({"action": "rescan"})

# Run Rofi
input_str = "\n".join(menu_items)
try:
    proc = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", " Wi-Fi", "-theme", THEME],
        input=input_str.encode("utf-8"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    choice = proc.stdout.decode("utf-8").strip()
except Exception:
    sys.exit(0)

if not choice:
    sys.exit(0)

# Find selected item
selected_data = None
for i, item in enumerate(menu_items):
    if item == choice:
        selected_data = items_data[i]
        break

if not selected_data:
    sys.exit(0)

action = selected_data.get("action")
if action == "disconnect":
    subprocess.run(["nmcli", "device", "disconnect", wifi_dev])
    subprocess.run(["notify-send", "📶 Wi-Fi", "Disconnected from Wi-Fi"])
    sys.exit(0)
elif action == "nmtui":
    subprocess.Popen(["kitty", "-e", "nmtui"])
    sys.exit(0)
elif action == "rescan":
    subprocess.run(["nmcli", "device", "wifi", "rescan"])
    time.sleep(1)
    os.execv(sys.executable, [sys.executable] + sys.argv)

ssid = selected_data["ssid"]
bssid = selected_data["bssid"]
is_open = selected_data["is_open"]
is_connected = selected_data["is_connected"]
target = ssid if ssid else bssid

if is_connected:
    subprocess.run(["notify-send", "📶 Wi-Fi", f"Already connected to {ssid}"])
    sys.exit(0)

def prompt_password_and_connect():
    theme_str = f'window {{ width: 440px; }} mainbox {{ children: [ "inputbar" ]; }} entry {{ placeholder: "Enter password for {ssid}..."; }} listview {{ enabled: false; }}'
    pass_proc = subprocess.run(
        ["rofi", "-dmenu", "-password", "-p", "󰌾 Password", "-theme-str", theme_str, "-theme", THEME],
        stdout=subprocess.PIPE,
        text=True
    )
    password = pass_proc.stdout.strip()
    if not password:
        sys.exit(0)

    subprocess.run(["notify-send", "📶 Wi-Fi", f"Connecting to {ssid}..."])
    res = subprocess.run(
        ["nmcli", "device", "wifi", "connect", target, "password", password],
        capture_output=True,
        text=True
    )
    if res.returncode == 0:
        subprocess.run(["notify-send", "📶 Wi-Fi Connected", f"Connected to {ssid}"])
    else:
        err = res.stderr.strip() or "Connection failed"
        subprocess.run(["notify-send", "-u", "critical", "⚠️ Wi-Fi Error", f"Failed to connect to {ssid}:\n{err}"])

# Check if network is saved or open
is_saved = (ssid in saved_ssids)

if is_open:
    subprocess.run(["notify-send", "📶 Wi-Fi", f"Connecting to {ssid}..."])
    res = subprocess.run(["nmcli", "device", "wifi", "connect", target], capture_output=True, text=True)
    if res.returncode == 0:
        subprocess.run(["notify-send", "📶 Wi-Fi Connected", f"Connected to {ssid}"])
    else:
        err = res.stderr.strip() or "Connection failed"
        subprocess.run(["notify-send", "-u", "critical", "⚠️ Wi-Fi Error", f"Failed to connect to {ssid}:\n{err}"])
elif is_saved:
    subprocess.run(["notify-send", "📶 Wi-Fi", f"Connecting to saved network {ssid}..."])
    res = subprocess.run(["nmcli", "connection", "up", ssid], capture_output=True, text=True)
    if res.returncode == 0:
        subprocess.run(["notify-send", "📶 Wi-Fi Connected", f"Connected to {ssid}"])
    else:
        # If saved connection fails (e.g. password changed), ask for password
        prompt_password_and_connect()
else:
    # Unsaved secured network: ask for password
    prompt_password_and_connect()
