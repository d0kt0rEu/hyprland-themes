#!/usr/bin/env python3
import subprocess
import json
import html
import time
import sys

def get_window_status():
    try:
        w_raw = subprocess.check_output(['hyprctl', 'activewindow', '-j'], stderr=subprocess.DEVNULL)
        win = json.loads(w_raw)
    except Exception:
        win = {}

    addr = win.get('address')
    if not addr or addr == "0x0":
        try:
            ws_raw = subprocess.check_output(['hyprctl', 'activeworkspace', '-j'], stderr=subprocess.DEVNULL)
            ws = json.loads(ws_raw).get('id', 1)
        except Exception:
            ws = 1
        top = 'DESKTOP'
        bottom = f'Workspace {ws}'
        tooltip = f'Workspace {ws}'
    else:
        cls = win.get('class', 'Unknown')
        title = win.get('title', '')
        if len(title) > 28:
            title = title[:25] + '...'
        top = cls.upper()
        bottom = title
        tooltip = f'{cls}: {title}'

    esc_top = html.escape(top)
    esc_bottom = html.escape(bottom)

    text = f"<span size='8500' foreground='#83c092' rise='-2000'>{esc_top}</span>\n<span size='10500' weight='bold' foreground='#d3c6aa'>{esc_bottom}</span>"
    return json.dumps({'text': text, 'class': 'custom-window', 'tooltip': tooltip})

last = ""
while True:
    try:
        status = get_window_status()
        if status != last:
            print(status)
            sys.stdout.flush()
            last = status
    except Exception:
        pass
    time.sleep(0.4)
