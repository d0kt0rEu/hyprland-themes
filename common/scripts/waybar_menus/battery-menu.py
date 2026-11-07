#!/usr/bin/env python3
import subprocess
import sys
import os

def get_battery_info():
    props = {
        "percentage": "--",
        "state": "unknown",
        "time": "calculating...",
        "rate": "--",
        "threshold": "80",
        "plan": "balanced"
    }

    # Query upower
    try:
        out = subprocess.check_output(
            ["upower", "-i", "/org/freedesktop/UPower/devices/battery_BAT0"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8")
        for line in out.splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip()
                if k == "percentage":
                    props["percentage"] = v
                elif k == "state":
                    props["state"] = v.capitalize()
                elif k in ["time to empty", "time to full"]:
                    props["time"] = v
                elif k == "energy-rate":
                    props["rate"] = v
                elif k == "charge-end-threshold":
                    props["threshold"] = v.replace("%", "").strip()
    except Exception:
        pass

    # Fallback to sysfs if needed
    try:
        with open("/sys/class/power_supply/BAT0/capacity") as f:
            props["percentage"] = f.read().strip() + "%"
    except Exception:
        pass

    try:
        with open("/sys/class/power_supply/BAT0/charge_control_end_threshold") as f:
            props["threshold"] = f.read().strip()
    except Exception:
        pass

    # Read CPU energy performance preference
    try:
        with open("/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference") as f:
            props["plan"] = f.read().strip().replace("_", " ").title()
    except Exception:
        pass

    return props

def main():
    info = get_battery_info()

    pct = info["percentage"]
    state = info["state"]
    time_rem = info["time"]
    rate = info["rate"]
    thresh = info["threshold"]
    plan = info["plan"]

    icon = "󰂄" if "charg" in state.lower() else "󰁹"

    options = [
        f"{icon} Battery: {pct} ({state})",
        f"󱎫 Remaining Time: {time_rem}",
        f"󱐋 Power Consumption: {rate}",
        f"󱐌 Charging Limit: Stop at {thresh}%",
        f"󰓅 Active Power Plan: {plan}",
        "──────────────────────────────────────────────",
        "⚡ Stop Charging at 80% (Recommended for Health)",
        "⚡ Stop Charging at 60% (Longevity / Desk Mode)",
        "⚡ Stop Charging at 100% (Full Capacity)",
        "⚡ Enter Custom Charging Limit...",
        "🚀 Power Plan: Performance",
        "⚖️  Power Plan: Balanced",
        "🌱 Power Plan: Power Saver"
    ]

    menu_input = "\n".join(options).encode("utf-8")

    try:
        p = subprocess.Popen(
            [
                "fuzzel",
                "--dmenu",
                "--anchor=top-right",
                "--x-margin=12",
                "--y-margin=46",
                "--width=48",
                f"--lines={len(options)}",
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
                "--prompt=Battery & Power > "
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )
        stdout, _ = p.communicate(input=menu_input)
        selected = stdout.decode("utf-8").strip()
    except Exception:
        return

    if not selected:
        return

    # Handle selections
    if "Stop Charging at 80%" in selected:
        set_threshold(80)
    elif "Stop Charging at 60%" in selected:
        set_threshold(60)
    elif "Stop Charging at 100%" in selected:
        set_threshold(100)
    elif "Custom Charging Limit" in selected:
        custom = prompt_custom_limit()
        if custom:
            set_threshold(custom)
    elif "Power Plan: Performance" in selected:
        set_power_plan("performance")
    elif "Power Plan: Balanced" in selected:
        set_power_plan("balance_performance")
    elif "Power Plan: Power Saver" in selected:
        set_power_plan("power")

def prompt_custom_limit():
    try:
        p = subprocess.Popen(
            [
                "fuzzel",
                "--dmenu",
                "--anchor=top-right",
                "--x-margin=12",
                "--y-margin=46",
                "--width=35",
                "--lines=0",
                "--border-width=2",
                "--border-color=ff2a85ff",
                "--border-radius=14",
                "--background-color=0f0c16fa",
                "--prompt=Enter limit (50-100)%: "
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )
        stdout, _ = p.communicate(input=b"")
        val = stdout.decode("utf-8").strip()
        val_int = int(val)
        if 50 <= val_int <= 100:
            return val_int
    except Exception:
        pass
    return None

def set_threshold(limit):
    cmd = f'sh -c "echo {limit} > /sys/class/power_supply/BAT0/charge_control_end_threshold"'
    subprocess.run(["pkexec", "sh", "-c", cmd])

def set_power_plan(plan):
    cmd = f'for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo {plan} > "$f"; done'
    subprocess.run(["pkexec", "sh", "-c", cmd])

if __name__ == "__main__":
    main()
