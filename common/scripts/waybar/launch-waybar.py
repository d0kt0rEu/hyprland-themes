#!/usr/bin/env python3
import os
import sys
import socket
import select
import signal
import subprocess
import threading

UID = os.getuid()
HYPR_BASE = f"/run/user/{UID}/hypr"

def get_real_signature():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if sig and sig != "waybar_proxy" and os.path.exists(f"{HYPR_BASE}/{sig}/.socket.sock"):
        return sig
    # Search for active signature
    if os.path.exists(HYPR_BASE):
        for entry in os.listdir(HYPR_BASE):
            if entry != "waybar_proxy" and os.path.exists(f"{HYPR_BASE}/{entry}/.socket.sock"):
                return entry
    return None

REAL_SIG = get_real_signature()
if not REAL_SIG:
    print("Error: Could not find Hyprland instance signature", file=sys.stderr)
    # Fallback to direct waybar execution
    os.execvp("waybar", ["waybar"])

REAL_SOCK = f"{HYPR_BASE}/{REAL_SIG}/.socket.sock"
REAL_SOCK2 = f"{HYPR_BASE}/{REAL_SIG}/.socket2.sock"

PROXY_DIR = f"{HYPR_BASE}/waybar_proxy"
os.makedirs(PROXY_DIR, exist_ok=True)

PROXY_SOCK = os.path.join(PROXY_DIR, ".socket.sock")
PROXY_SOCK2 = os.path.join(PROXY_DIR, ".socket2.sock")

# Set up socket2 symlink for hyprland event stream
if os.path.exists(PROXY_SOCK2) or os.path.islink(PROXY_SOCK2):
    try:
        os.remove(PROXY_SOCK2)
    except OSError:
        pass
os.symlink(REAL_SOCK2, PROXY_SOCK2)

# Set up command socket proxy
if os.path.exists(PROXY_SOCK):
    try:
        os.remove(PROXY_SOCK)
    except OSError:
        pass

server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
server.bind(PROXY_SOCK)
server.listen(32)

running = True

def handle_client(client_sock):
    try:
        data = client_sock.recv(4096)
        if not data:
            client_sock.close()
            return

        text = data.decode("utf-8", errors="ignore")

        # Hyprland 0.57+ in Lua mode evaluates dispatch commands as Lua code:
        # "return hl.dispatch(<cmd>)". Legacy commands like "workspace 2" fail syntax parsing.
        # We translate workspace commands to hl.dsp.focus({ workspace = ... }) and others to hl.dsp.exec_raw()
        if text.startswith("dispatch "):
            cmd = text[9:].strip()
            if cmd.startswith("workspace "):
                ws = cmd[10:].strip()
                if ws.isdigit():
                    text = f'dispatch hl.dsp.focus({{ workspace = {ws} }})'
                else:
                    text = f'dispatch hl.dsp.focus({{ workspace = "{ws}" }})'
                data = text.encode("utf-8")
            elif not cmd.startswith("hl.dsp.") and not cmd.startswith("return "):
                escaped = cmd.replace('\\', '\\\\').replace('"', '\\"')
                text = f'dispatch hl.dsp.exec_raw("{escaped}")'
                data = text.encode("utf-8")

        # Forward to real hyprland socket
        real_s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        real_s.connect(REAL_SOCK)
        real_s.sendall(data)
        
        # Read response and forward back
        resp = real_s.recv(4096)
        real_s.close()
        client_sock.sendall(resp)
    except Exception:
        pass
    finally:
        try:
            client_sock.close()
        except OSError:
            pass

def proxy_loop():
    while running:
        r, _, _ = select.select([server], [], [], 0.5)
        if r:
            try:
                c, _ = server.accept()
                threading.Thread(target=handle_client, args=(c,), daemon=True).start()
            except OSError:
                break

proxy_thread = threading.Thread(target=proxy_loop, daemon=True)
proxy_thread.start()

# Launch Waybar with proxy environment
env = os.environ.copy()
env["HYPRLAND_INSTANCE_SIGNATURE"] = "waybar_proxy"

proc = subprocess.Popen(["waybar"], env=env)

def cleanup(sig=None, frame=None):
    global running
    running = False
    try:
        proc.terminate()
    except Exception:
        pass
    try:
        server.close()
    except Exception:
        pass
    try:
        if os.path.exists(PROXY_SOCK):
            os.remove(PROXY_SOCK)
    except OSError:
        pass

signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)

# Wait for waybar process
proc.wait()
cleanup()
