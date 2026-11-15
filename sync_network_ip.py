import os
import sys
import subprocess
import urllib.request
import json
import base64
import time

def get_wsl_ip():
    try:
        out = subprocess.check_output(["wsl", "-d", "kali-linux", "-u", "root", "--", "hostname", "-I"], text=True)
        return out.strip().split()[0]
    except Exception as e:
        print(f"Error getting WSL IP: {e}")
        return None

def get_win_ip():
    try:
        out = subprocess.check_output(["wsl", "-d", "kali-linux", "-u", "root", "--", "ip", "route", "show", "default"], text=True)
        return out.strip().split()[2]
    except Exception as e:
        print(f"Error getting Windows Host IP: {e}")
        return None

def update_awx_hosts(wsl_ip, win_ip):
    auth_header = 'Basic ' + base64.b64encode(b'admin:AdminPassword@123').decode()
    base_url = f"http://{wsl_ip}:30080"
    
    print(f"[*] Checking AWX connection at {base_url}...")
    ready = False
    for attempt in range(15):
        try:
            req = urllib.request.Request(f"{base_url}/api/v2/ping/")
            req.add_header('Authorization', auth_header)
            with urllib.request.urlopen(req, timeout=3) as resp:
                if resp.status == 200:
                    ready = True
                    break
        except Exception:
            time.sleep(2)
            
    if not ready:
        print("[-] AWX not responding yet, skipping host update.")
        return

    # Map host names to their SSH Bridge ports
    port_map = {
        "router-edge": 2221,
        "router-core": 2223,
        "switch-access": 2222
    }

    try:
        req = urllib.request.Request(f"{base_url}/api/v2/inventories/2/hosts/")
        req.add_header('Authorization', auth_header)
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode())
            for h in data.get('results', []):
                hname = h.get('name')
                hid = h.get('id')
                if hname in port_map:
                    port = port_map[hname]
                    vars_str = f"ansible_host: {win_ip}\nansible_port: {port}\nansible_network_os: cisco.ios.ios"
                    patch_req = urllib.request.Request(
                        f"{base_url}/api/v2/hosts/{hid}/",
                        data=json.dumps({"variables": vars_str}).encode("utf-8"),
                        headers={
                            "Authorization": auth_header,
                            "Content-Type": "application/json"
                        },
                        method="PATCH"
                    )
                    with urllib.request.urlopen(patch_req, timeout=5) as p_resp:
                        print(f"[+] AWX Host '{hname}' (ID {hid}) updated with ansible_host: {win_ip}, port: {port}")
    except Exception as e:
        print(f"[-] Error querying or updating AWX hosts: {e}")

if __name__ == "__main__":
    wsl_ip = get_wsl_ip()
    win_ip = get_win_ip()
    print(f"[i] WSL IP: {wsl_ip}")
    print(f"[i] Windows Host IP: {win_ip}")
    if wsl_ip and win_ip:
        update_awx_hosts(wsl_ip, win_ip)
