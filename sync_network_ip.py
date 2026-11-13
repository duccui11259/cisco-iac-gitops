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

    # Update Host 3 (router-edge) and Host 4 (switch-access)
    hosts_vars = {
        3: f"ansible_host: {win_ip}\nansible_port: 2221\nansible_network_os: cisco.ios.ios",
        4: f"ansible_host: {win_ip}\nansible_port: 2222\nansible_network_os: cisco.ios.ios"
    }
    
    for hid, vars_str in hosts_vars.items():
        try:
            req = urllib.request.Request(
                f"{base_url}/api/v2/hosts/{hid}/",
                data=json.dumps({"variables": vars_str}).encode("utf-8"),
                headers={
                    "Authorization": auth_header,
                    "Content-Type": "application/json"
                },
                method="PATCH"
            )
            with urllib.request.urlopen(req, timeout=5) as resp:
                print(f"[+] AWX Host {hid} updated with ansible_host: {win_ip}")
        except Exception as e:
            print(f"[-] Error updating Host {hid}: {e}")

if __name__ == "__main__":
    wsl_ip = get_wsl_ip()
    win_ip = get_win_ip()
    print(f"[i] WSL IP: {wsl_ip}")
    print(f"[i] Windows Host IP: {win_ip}")
    if wsl_ip and win_ip:
        update_awx_hosts(wsl_ip, win_ip)
