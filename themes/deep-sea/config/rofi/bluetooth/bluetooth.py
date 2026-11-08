#!/usr/bin/env python3
import subprocess
import sys
import os
import time
import re

DIR = os.path.expanduser("~/.config/rofi/bluetooth")
THEME = os.path.join(DIR, "bluetooth.rasi")

# Toggle behavior: if rofi is already running, kill it and exit
try:
    pids = subprocess.check_output(["pgrep", "-x", "rofi"]).decode().strip().split()
    if pids:
        subprocess.run(["pkill", "-x", "rofi"])
        sys.exit(0)
except subprocess.CalledProcessError:
    pass

def notify(title, msg, urgency="normal"):
    subprocess.run(["notify-send", "-u", urgency, title, msg])

def run_rofi(items, prompt="󰂯 Bluetooth", theme_extra=None):
    cmd = ["rofi", "-dmenu", "-i", "-p", prompt, "-theme", THEME]
    if theme_extra:
        cmd.extend(["-theme-str", theme_extra])
    input_str = "\n".join(items).encode("utf-8")
    try:
        proc = subprocess.run(cmd, input=input_str, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return proc.stdout.decode("utf-8").strip()
    except Exception:
        return ""

def is_powered_on():
    try:
        out = subprocess.check_output(["bluetoothctl", "show"], stderr=subprocess.DEVNULL).decode()
        return "Powered: yes" in out
    except Exception:
        return False

def get_device_icon(name, mac):
    nl = name.lower()
    if any(k in nl for k in ["buds", "headphone", "headset", "earbuds", "airpods", "freebuds"]):
        return "󰋋"
    elif any(k in nl for k in ["speaker", "soundbar", "flexus", "klipsch", "jbl", "audio", "boom"]):
        return "󰄝"
    elif any(k in nl for k in ["tv", "box", "shield", "chromecast"]):
        return "󰵪"
    elif any(k in nl for k in ["phone", "oppo", "samsung", "iphone", "pixel", "redmi", "xiaomi", "galaxy"]):
        return "󰏲"
    elif any(k in nl for k in ["keyboard", "keychron", "logi"]):
        return "󰌌"
    elif any(k in nl for k in ["mouse", "mx anywhere", "mx master"]):
        return "󰍽"
    return "󰂯"

def device_submenu(mac, name, is_conn, is_paired):
    options = []
    actions = []

    if is_conn:
        options.append("󰌙  Disconnect Device")
        actions.append("disconnect")
    else:
        options.append("󰂱  Connect to Device")
        actions.append("connect")

    if is_paired:
        options.append("󰆴  Remove / Forget Device")
        actions.append("remove")
    else:
        options.append("󰌹  Pair & Trust Device")
        actions.append("pair")

    options.append("󰋼  View Device Info")
    actions.append("info")

    options.append("󰌑  Back to Device List")
    actions.append("back")

    prompt_title = f"{name[:20]}"
    choice = run_rofi(options, prompt=prompt_title)
    if not choice:
        sys.exit(0)

    selected_action = None
    for i, opt in enumerate(options):
        if opt == choice:
            selected_action = actions[i]
            break

    if selected_action == "back":
        os.execv(sys.executable, [sys.executable] + sys.argv)
    elif selected_action == "disconnect":
        notify("󰂯 Bluetooth", f"Disconnecting {name}...")
        subprocess.run(["bluetoothctl", "disconnect", mac])
        notify("󰂯 Bluetooth", f"Disconnected from {name}")
    elif selected_action == "connect":
        notify("󰂯 Bluetooth", f"Connecting to {name}...")
        res = subprocess.run(["bluetoothctl", "connect", mac], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if "Connection successful" in res.stdout or res.returncode == 0:
            notify("󰂱 Bluetooth Connected", f"Connected to {name}")
        else:
            notify("⚠️ Bluetooth Error", f"Failed to connect to {name}. Device may be off or out of range.", urgency="critical")
    elif selected_action == "pair":
        notify("󰂯 Bluetooth", f"Pairing with {name}...")
        subprocess.run(["bluetoothctl", "trust", mac])
        res = subprocess.run(["bluetoothctl", "pair", mac], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if res.returncode == 0:
            subprocess.run(["bluetoothctl", "connect", mac])
            notify("󰂱 Bluetooth Paired", f"Successfully paired and connected to {name}!")
        else:
            notify("⚠️ Bluetooth Error", f"Pairing failed for {name}.", urgency="critical")
    elif selected_action == "remove":
        subprocess.run(["bluetoothctl", "remove", mac])
        notify("󰂯 Bluetooth", f"Removed device {name}")
    elif selected_action == "info":
        try:
            info = subprocess.check_output(["bluetoothctl", "info", mac], stderr=subprocess.DEVNULL).decode()
            info_lines = [l.strip() for l in info.splitlines() if l.strip()]
            run_rofi(info_lines, prompt="Device Info")
        except Exception:
            pass

def main():
    if not os.path.exists("/usr/bin/bluetoothctl"):
        choice = run_rofi([
            "󰒓  Install & Enable BlueZ (sudo pacman -S bluez bluez-utils)",
            "󰌑  Exit"
        ], prompt="󰂲 Bluetooth Missing")
        if "Install" in choice:
            subprocess.Popen(["kitty", "-e", "bash", "-c", "sudo /tmp/setup-bluetooth.sh; read line"])
        sys.exit(0)

    if not is_powered_on():
        choice = run_rofi([
            "󰂯  Turn Bluetooth On",
            "󰌑  Exit"
        ], prompt="󰂲 Bluetooth Off")
        if "Turn Bluetooth On" in choice:
            subprocess.run(["rfkill", "unblock", "bluetooth"])
            subprocess.run(["bluetoothctl", "power", "on"])
            notify("󰂯 Bluetooth", "Bluetooth powered ON")
            time.sleep(0.8)
            os.execv(sys.executable, [sys.executable] + sys.argv)
        sys.exit(0)

    # 1. Connected devices
    connected_macs = set()
    try:
        conns = subprocess.check_output(["bluetoothctl", "devices", "Connected"], stderr=subprocess.DEVNULL).decode().strip().splitlines()
        for c in conns:
            parts = c.split(" ", 2)
            if len(parts) >= 2:
                connected_macs.add(parts[1])
    except Exception:
        pass

    # 2. Paired devices
    paired_macs = set()
    try:
        paired = subprocess.check_output(["bluetoothctl", "devices", "Paired"], stderr=subprocess.DEVNULL).decode().strip().splitlines()
        for p in paired:
            parts = p.split(" ", 2)
            if len(parts) >= 2:
                paired_macs.add(parts[1])
    except Exception:
        pass

    # 3. All devices
    all_devs = []
    try:
        raw_devs = subprocess.check_output(["bluetoothctl", "devices"], stderr=subprocess.DEVNULL).decode().strip().splitlines()
        for d in raw_devs:
            parts = d.split(" ", 2)
            if len(parts) >= 3:
                mac = parts[1]
                name = parts[2].strip()
                # Determine if real name or anonymous MAC
                is_mac_name = bool(re.match(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$", name.replace("-", ":")))
                all_devs.append({
                    "mac": mac,
                    "name": name,
                    "is_mac_name": is_mac_name,
                    "is_conn": mac in connected_macs,
                    "is_paired": mac in paired_macs
                })
    except Exception:
        pass

    # Build menu
    menu_items = []
    device_data = []

    # Sort priority:
    # 1. Connected devices first
    # 2. Paired devices
    # 3. Named discovered devices
    # 4. Anonymous beacon devices last
    def dev_sort_key(d):
        priority = 3
        if d["is_conn"]:
            priority = 0
        elif d["is_paired"]:
            priority = 1
        elif not d["is_mac_name"]:
            priority = 2
        return (priority, d["name"].lower())

    all_devs.sort(key=dev_sort_key)

    # Add devices
    for d in all_devs:
        icon = get_device_icon(d["name"], d["mac"])
        name_str = f"{d['name']:<28}"
        if d["is_conn"]:
            status_str = "[Connected]"
            lead_icon = "󰂱"
        elif d["is_paired"]:
            status_str = "[Paired]"
            lead_icon = "󰂯"
        else:
            status_str = "[Nearby]"
            lead_icon = icon

        label = f"{lead_icon}  {name_str}  {status_str}  {d['mac']}"
        menu_items.append(label)
        device_data.append(d)

    # Global Quick Actions
    action_scan = "󰑐  Scan for Nearby Devices (5s)"
    action_off = "󰂲  Turn Bluetooth Off"
    action_term = "  Open Bluetooth Shell (bluetoothctl)"

    menu_items.append(action_scan)
    device_data.append({"action": "scan"})

    menu_items.append(action_off)
    device_data.append({"action": "off"})

    menu_items.append(action_term)
    device_data.append({"action": "term"})

    # Launch Rofi
    choice = run_rofi(menu_items, prompt="󰂯 Bluetooth")
    if not choice:
        sys.exit(0)

    selected = None
    for i, item in enumerate(menu_items):
        if item == choice:
            selected = device_data[i]
            break

    if not selected:
        sys.exit(0)

    action = selected.get("action")
    if action == "scan":
        notify("󰂯 Bluetooth", "Scanning for nearby devices (5 seconds)...")
        # Run scan for 5 seconds
        subprocess.run(["bluetoothctl", "--timeout", "5", "scan", "on"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        notify("󰂯 Bluetooth", "Scan complete! Showing updated devices.")
        os.execv(sys.executable, [sys.executable] + sys.argv)
    elif action == "off":
        subprocess.run(["bluetoothctl", "power", "off"])
        notify("󰂲 Bluetooth", "Bluetooth powered OFF")
        sys.exit(0)
    elif action == "term":
        subprocess.Popen(["kitty", "--title", "Bluetooth Control", "bluetoothctl"])
        sys.exit(0)
    else:
        # User selected a device
        device_submenu(selected["mac"], selected["name"], selected["is_conn"], selected["is_paired"])

if __name__ == "__main__":
    main()
