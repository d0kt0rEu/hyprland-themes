#!/usr/bin/env python3
import subprocess
import sys
import os

def run_fuzzel(options, prompt="Bluetooth > ", lines=None, width=48, x_margin=160):
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
    has_btctl = os.path.exists("/usr/bin/bluetoothctl")

    # Check rfkill
    blocked = False
    try:
        rf = subprocess.check_output(["rfkill", "list", "bluetooth"], stderr=subprocess.DEVNULL).decode()
        if "Soft blocked: yes" in rf or "Hard blocked: yes" in rf:
            blocked = True
    except Exception:
        pass

    powered_on = False
    if has_btctl and not blocked:
        try:
            out = subprocess.check_output(["bluetoothctl", "show"], stderr=subprocess.DEVNULL).decode()
            powered_on = "Powered: yes" in out
        except Exception:
            pass

    options = []
    if not has_btctl:
        options.append("󰂲 Bluetooth Daemon (bluez) Not Installed")
        options.append("──────────────────────────────────────────────")
        options.append("󰒓 Install & Enable BlueZ (kitty terminal)")
        if blocked:
            options.append("󰂯 Unblock Bluetooth via RF-Kill")
        else:
            options.append("󰂲 Block Bluetooth via RF-Kill")
    else:
        status_txt = "Powered On" if powered_on else ("Blocked" if blocked else "Powered Off")
        icon = "󰂯" if powered_on else "󰂲"
        options.append(f"{icon} Bluetooth Status: {status_txt}")
        options.append("──────────────────────────────────────────────")

        if powered_on:
            options.append("󰂲 Turn Bluetooth Off")
            # Query connected devices
            try:
                conns = subprocess.check_output(["bluetoothctl", "devices", "Connected"], stderr=subprocess.DEVNULL).decode().strip().splitlines()
                for c in conns:
                    parts = c.split(" ", 2)
                    if len(parts) >= 3:
                        mac, name = parts[1], parts[2]
                        options.append(f"󱘖 Disconnect: {name} ({mac})")
            except Exception:
                pass

            # Query paired devices
            try:
                paired = subprocess.check_output(["bluetoothctl", "devices", "Paired"], stderr=subprocess.DEVNULL).decode().strip().splitlines()
                for p in paired:
                    parts = p.split(" ", 2)
                    if len(parts) >= 3:
                        mac, name = parts[1], parts[2]
                        options.append(f"󰂱 Connect to: {name} ({mac})")
            except Exception:
                pass

            options.append("󰑐 Scan for Nearby Bluetooth Devices...")
        else:
            options.append("󰂯 Turn Bluetooth On")

    choice = run_fuzzel(options, prompt="Bluetooth > ", width=48, x_margin=160)
    if not choice:
        return

    if "Install & Enable BlueZ" in choice:
        subprocess.Popen([
            "kitty",
            "--title", "Install Bluetooth Daemon",
            "bash", "-c",
            "echo 'Installing BlueZ and bluez-utils...'; sudo pacman -S --needed bluez bluez-utils && sudo systemctl enable --now bluetooth && echo 'Done! Bluetooth is active.' && sleep 2"
        ])
    elif "Turn Bluetooth Off" in choice:
        subprocess.run(["bluetoothctl", "power", "off"])
    elif "Turn Bluetooth On" in choice:
        if blocked:
            subprocess.run(["rfkill", "unblock", "bluetooth"])
        subprocess.run(["bluetoothctl", "power", "on"])
    elif "Unblock Bluetooth via RF-Kill" in choice:
        subprocess.run(["rfkill", "unblock", "bluetooth"])
    elif "Block Bluetooth via RF-Kill" in choice:
        subprocess.run(["rfkill", "block", "bluetooth"])
    elif "Disconnect: " in choice:
        mac = choice.split("(")[-1].replace(")", "").strip()
        subprocess.run(["bluetoothctl", "disconnect", mac])
    elif "Connect to: " in choice:
        mac = choice.split("(")[-1].replace(")", "").strip()
        subprocess.run(["bluetoothctl", "connect", mac])
    elif "Scan for Nearby" in choice:
        subprocess.Popen([
            "kitty",
            "--title", "Bluetooth Device Discovery",
            "bash", "-c",
            "bluetoothctl scan on"
        ])

if __name__ == "__main__":
    main()
