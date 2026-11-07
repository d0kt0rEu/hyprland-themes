#!/usr/bin/env python3
import os
import sys
import socket
import subprocess
import time

def find_socket():
    uid = os.getuid()
    hypr_dir = f"/run/user/{uid}/hypr"
    instance = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    
    if not instance and os.path.exists(hypr_dir):
        subdirs = [d for d in os.listdir(hypr_dir) if os.path.isdir(os.path.join(hypr_dir, d))]
        if subdirs:
            instance = subdirs[0]
            
    if not instance:
        return None
        
    sock_path = os.path.join(hypr_dir, instance, ".socket2.sock")
    return sock_path if os.path.exists(sock_path) else None

def main():
    sock_path = find_socket()
    if not sock_path:
        sys.exit(1)
        
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(sock_path)
    except Exception:
        sys.exit(1)
        
    pill_script = os.path.expanduser("~/.config/waybar/scripts/show-pill.sh")
    last_trigger = 0.0

    buffer = ""
    while True:
        try:
            chunk = s.recv(2048).decode("utf-8", errors="ignore")
            if not chunk:
                break
            buffer += chunk
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                line = line.strip()
                if line.startswith("activelayout>>"):
                    now = time.time()
                    # Debounce fast repeated triggers within 0.15s
                    if now - last_trigger > 0.15:
                        last_trigger = now
                        subprocess.Popen([pill_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            break

if __name__ == "__main__":
    main()
