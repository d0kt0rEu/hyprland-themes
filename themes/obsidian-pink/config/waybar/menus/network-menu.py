#!/usr/bin/env python3
import subprocess
import sys

def get_wifi_status():
    try:
        radio = subprocess.check_output(["nmcli", "radio", "wifi"], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        radio = "unknown"

    active_wifi = None
    ip_addr = None

    try:
        lines = subprocess.check_output(["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,IP4-CONNECTIVITY", "dev"], stderr=subprocess.DEVNULL).decode().splitlines()
        for line in lines:
            parts = line.split(":")
            if len(parts) >= 3 and parts[0] == "wifi" and parts[1] == "connected":
                active_wifi = parts[2]
                break
    except Exception:
        pass

    try:
        if active_wifi:
            out = subprocess.check_output(["nmcli", "-t", "-f", "IP4.ADDRESS", "con", "show", active_wifi], stderr=subprocess.DEVNULL).decode()
            for l in out.splitlines():
                if l.startswith("IP4.ADDRESS"):
                    ip_addr = l.split(":", 1)[1].split("/")[0].strip()
                    break
    except Exception:
        pass

    return radio, active_wifi, ip_addr

def run_fuzzel(options, prompt="Network > ", lines=None, width=48, x_margin=85):
    if lines is None:
        lines = len(options)
    menu_input = "\n".join(options).encode("utf-8")
    try:
        p = subprocess.Popen(
            [
                "fuzzel",
                "--dmenu",
                "--anchor=top-right",
                f"--x-margin={x_margin}",
                "--y-margin=46",
                f"--width={width}",
                f"--lines={lines}",
                "--border-width=2",
                "--border-color=9d4eddff",
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

def scan_and_connect():
    try:
        raw = subprocess.check_output(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY,BARS", "dev", "wifi", "list"], stderr=subprocess.DEVNULL).decode()
    except Exception:
        return

    networks = []
    seen = set()
    for line in raw.splitlines():
        parts = line.split(":")
        if len(parts) >= 4:
            in_use = parts[0] == "*"
            ssid = parts[1].strip()
            signal = parts[2].strip()
            sec = parts[3].strip()
            bars = parts[4].strip() if len(parts) > 4 else ""

            if not ssid or ssid == "--" or ssid in seen:
                continue
            seen.add(ssid)

            lock = "🔒" if sec and sec != "--" else "  "
            star = "● " if in_use else "  "
            networks.append((ssid, f"{star}{lock} {ssid}  ({signal}% {bars})", sec != "--"))

    if not networks:
        return

    display_list = [n[1] for n in networks]
    choice = run_fuzzel(display_list, prompt="Select Wi-Fi > ", width=45, x_margin=85)
    if not choice:
        return

    selected_ssid = None
    is_secured = False
    for ssid, disp, sec in networks:
        if disp == choice:
            selected_ssid = ssid
            is_secured = sec
            break

    if not selected_ssid:
        return

    # Check if network is already saved
    try:
        saved = subprocess.check_output(["nmcli", "-t", "-f", "NAME", "con", "show"], stderr=subprocess.DEVNULL).decode().splitlines()
        is_saved = selected_ssid in saved
    except Exception:
        is_saved = False

    if is_saved:
        subprocess.run(["nmcli", "con", "up", "id", selected_ssid])
    elif not is_secured:
        subprocess.run(["nmcli", "dev", "wifi", "connect", selected_ssid])
    else:
        # Prompt for password
        try:
            p = subprocess.Popen(
                [
                    "fuzzel",
                    "--dmenu",
                    "--anchor=top-right",
                    "--x-margin=85",
                    "--y-margin=46",
                    "--width=35",
                    "--lines=0",
                    "--border-width=2",
                    "--border-color=9d4eddff",
                    "--border-radius=14",
                    "--background-color=0f0c16fa",
                    "--password",
                    f"--prompt=Password for {selected_ssid}: "
                ],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL
            )
            stdout, _ = p.communicate(input=b"")
            pwd = stdout.decode("utf-8").strip()
            if pwd:
                subprocess.run(["nmcli", "dev", "wifi", "connect", selected_ssid, "password", pwd])
        except Exception:
            pass

def main():
    radio, active_wifi, ip_addr = get_wifi_status()

    options = []
    if radio == "enabled":
        if active_wifi:
            ip_str = f" • IP: {ip_addr}" if ip_addr else ""
            options.append(f"󰖩 Wi-Fi: Connected to {active_wifi}{ip_str}")
        else:
            options.append("󰤮 Wi-Fi: Disconnected (Turned On)")
    else:
        options.append("󰖪 Wi-Fi: Powered Off")

    options.append("──────────────────────────────────────────────")

    if radio == "enabled":
        options.append("󰖪 Turn Wi-Fi Off")
        options.append("󰖩 Scan & Connect to Wi-Fi...")
        if active_wifi:
            options.append(f"󰈀 Disconnect from {active_wifi}")
    else:
        options.append("󰖩 Turn Wi-Fi On")

    options.append("󰒓 Open Network Connection Manager (nmtui)")

    choice = run_fuzzel(options, prompt="Network > ", width=48, x_margin=85)
    if not choice:
        return

    if "Turn Wi-Fi Off" in choice:
        subprocess.run(["nmcli", "radio", "wifi", "off"])
    elif "Turn Wi-Fi On" in choice:
        subprocess.run(["nmcli", "radio", "wifi", "on"])
    elif "Scan & Connect" in choice:
        scan_and_connect()
    elif "Disconnect from" in choice and active_wifi:
        subprocess.run(["nmcli", "con", "down", "id", active_wifi])
    elif "Open Network Connection Manager" in choice:
        subprocess.Popen(["kitty", "-e", "nmtui"])

if __name__ == "__main__":
    main()
