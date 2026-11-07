#!/usr/bin/env python3
import subprocess
import re
import sys

def run_fuzzel(options, prompt="Audio > ", lines=None, width=54, x_margin=235):
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

def get_audio_info():
    try:
        raw = subprocess.check_output(["wpctl", "status"], stderr=subprocess.DEVNULL).decode()
    except Exception:
        return [], [], []

    lines = raw.splitlines()
    section = None
    sinks = []
    sources = []
    streams = []

    for line in lines:
        stripped = line.strip()
        if "Sinks:" in stripped:
            section = "sinks"
            continue
        elif "Sources:" in stripped:
            section = "sources"
            continue
        elif "Streams:" in stripped:
            section = "streams"
            continue
        elif any(k in stripped for k in ["Devices:", "Filters:", "Video", "Settings"]):
            section = None
            continue

        if section in ["sinks", "sources", "streams"]:
            m = re.search(r"([*]?)\s*(\d+)\.\s*(.*)", stripped)
            if m:
                is_def = bool(m.group(1))
                nid = m.group(2)
                name = m.group(3).strip()
                item = {"id": nid, "name": name, "default": is_def}
                if section == "sinks":
                    sinks.append(item)
                elif section == "sources":
                    sources.append(item)
                elif section == "streams":
                    streams.append(item)

    return sinks, sources, streams

def main():
    sinks, sources, streams = get_audio_info()

    # Get master volume
    master_vol = "50%"
    master_muted = False
    try:
        mv = subprocess.check_output(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]).decode()
        if "[MUTED]" in mv:
            master_muted = True
        parts = mv.split()
        if len(parts) >= 2:
            master_vol = f"{int(round(float(parts[1]) * 100))}%"
    except Exception:
        pass

    vol_str = f"MUTED ({master_vol})" if master_muted else master_vol

    options = [
        f" Output Volume: {vol_str}",
        "──────────────────────────────────────────────",
        "🔊 Set Master Volume: 100%",
        "🔊 Set Master Volume: 75%",
        "🔉 Set Master Volume: 50%",
        "🔈 Set Master Volume: 25%",
        "🔇 Toggle Master Mute",
        "──────────────────────────────────────────────"
    ]

    # Add Sinks (Output devices)
    for s in sinks:
        mark = "● " if s["default"] else "  "
        options.append(f"{mark}󰓃 Output: {s['name']} [ID:{s['id']}]")

    # Add Sources (Input devices)
    for src in sources:
        mark = "● " if src["default"] else "  "
        options.append(f"{mark}󰍬 Input: {src['name']} [ID:{src['id']}]")

    options.append("──────────────────────────────────────────────")

    # Add App Streams
    if streams:
        for st in streams:
            options.append(f"󰝚 App Stream: {st['name']} [ID:{st['id']}]")
    else:
        options.append("󰝚 App Streams: No active media playback")

    options.append("🎛️ Open Terminal Audio Mixer (alsamixer)")

    choice = run_fuzzel(options, prompt="Audio & Mixer > ", width=54, x_margin=235)
    if not choice:
        return

    if "Set Master Volume: 100%" in choice:
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "1.0"])
    elif "Set Master Volume: 75%" in choice:
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.75"])
    elif "Set Master Volume: 50%" in choice:
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.50"])
    elif "Set Master Volume: 25%" in choice:
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"])
        subprocess.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "0.25"])
    elif "Toggle Master Mute" in choice:
        subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    elif "Output:" in choice and "[ID:" in choice:
        nid = choice.split("[ID:")[-1].replace("]", "").strip()
        subprocess.run(["wpctl", "set-default", nid])
    elif "Input:" in choice and "[ID:" in choice:
        nid = choice.split("[ID:")[-1].replace("]", "").strip()
        subprocess.run(["wpctl", "set-default", nid])
    elif "App Stream:" in choice and "[ID:" in choice:
        nid = choice.split("[ID:")[-1].replace("]", "").strip()
        adjust_stream(nid)
    elif "Open Terminal Audio Mixer" in choice:
        subprocess.Popen(["kitty", "-e", "alsamixer"])

def adjust_stream(nid):
    options = [
        "🔊 Stream Volume: 100%",
        "🔊 Stream Volume: 75%",
        "🔉 Stream Volume: 50%",
        "🔈 Stream Volume: 25%",
        "🔇 Toggle Stream Mute"
    ]
    choice = run_fuzzel(options, prompt=f"Stream {nid} > ", width=38, x_margin=235)
    if not choice:
        return

    if "100%" in choice:
        subprocess.run(["wpctl", "set-mute", nid, "0"])
        subprocess.run(["wpctl", "set-volume", nid, "1.0"])
    elif "75%" in choice:
        subprocess.run(["wpctl", "set-mute", nid, "0"])
        subprocess.run(["wpctl", "set-volume", nid, "0.75"])
    elif "50%" in choice:
        subprocess.run(["wpctl", "set-mute", nid, "0"])
        subprocess.run(["wpctl", "set-volume", nid, "0.50"])
    elif "25%" in choice:
        subprocess.run(["wpctl", "set-mute", nid, "0"])
        subprocess.run(["wpctl", "set-volume", nid, "0.25"])
    elif "Toggle Stream Mute" in choice:
        subprocess.run(["wpctl", "set-mute", nid, "toggle"])

if __name__ == "__main__":
    main()
