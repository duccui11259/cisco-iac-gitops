import os
import socket
import sys
import threading
import time
import paramiko

KEY_FILE = r"d:\Qtmv2\bridge_key.pem"
if not os.path.exists(KEY_FILE):
    host_key = paramiko.RSAKey.generate(2048)
    host_key.write_private_key_file(KEY_FILE)
else:
    host_key = paramiko.RSAKey.from_private_key_file(KEY_FILE)

class CiscoServer(paramiko.ServerInterface):
    def __init__(self, username="admin", password="admin123"):
        self.username = username
        self.password = password
        self.event = threading.Event()
        self.command = None

    def check_channel_request(self, kind, chanid):
        if kind == "session":
            return paramiko.OPEN_SUCCEEDED
        return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED

    def check_auth_password(self, username, password):
        if username == self.username and password == self.password:
            return paramiko.AUTH_SUCCESSFUL
        return paramiko.AUTH_FAILED

    def get_allowed_auths(self, username):
        return "password"

    def check_channel_shell_request(self, channel):
        self.event.set()
        return True

    def check_channel_exec_request(self, channel, command):
        self.command = command
        self.event.set()
        return True

    def check_channel_pty_request(self, channel, term, width, height, pixelwidth, pixelheight, modes):
        return True

def handle_client(client_sock, telnet_port, name):
    try:
        transport = paramiko.Transport(client_sock)
        transport.add_server_key(host_key)
        server = CiscoServer()
        transport.start_server(server=server)

        channel = transport.accept(20)
        if channel is None:
            transport.close()
            return

        server.event.wait(10)
        if not server.event.is_set():
            channel.close()
            transport.close()
            return

        cisco_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        cisco_sock.connect(("127.0.0.1", telnet_port))

        # Reset console to EXEC mode and clear buffer
        cisco_sock.settimeout(0.3)
        cisco_sock.sendall(b"\x03end\r\n")
        try:
            while True:
                d = cisco_sock.recv(4096)
                if not d: break
        except Exception:
            pass
        cisco_sock.settimeout(None)

        if server.command:
            cmd = server.command.decode("utf-8", errors="ignore").strip()
            cisco_sock.sendall(f"{cmd}\r\n".encode("ascii"))
            time.sleep(0.5)
            cisco_sock.settimeout(1.0)
            try:
                while True:
                    d = cisco_sock.recv(4096)
                    if not d: break
                    clean = bytes([b for b in d if b < 0xf0])
                    channel.send(clean)
            except Exception:
                pass
            cisco_sock.sendall(b"\x03end\r\n")
            channel.close()
            cisco_sock.close()
            transport.close()
            return

        # Interactive shell for Ansible
        cisco_sock.sendall(b"\r\n")
        time.sleep(0.1)
        cisco_sock.settimeout(0.3)
        try:
            d = cisco_sock.recv(4096)
            clean = bytes([b for b in d if b < 0xf0])
            channel.send(clean)
        except Exception:
            channel.send(f"\r\n{name}# ".encode("ascii"))
        cisco_sock.settimeout(None)

        stop_event = threading.Event()

        def ssh_to_cisco():
            try:
                while not stop_event.is_set():
                    data = channel.recv(1024)
                    if not data: break
                    cisco_sock.sendall(data)
            except Exception:
                pass
            finally:
                stop_event.set()

        def cisco_to_ssh():
            try:
                while not stop_event.is_set():
                    data = cisco_sock.recv(1024)
                    if not data: break
                    clean = bytes([b for b in data if b < 0xf0])
                    if clean:
                        channel.send(clean)
            except Exception:
                pass
            finally:
                stop_event.set()

        t1 = threading.Thread(target=ssh_to_cisco, daemon=True)
        t2 = threading.Thread(target=cisco_to_ssh, daemon=True)
        t1.start()
        t2.start()

        stop_event.wait()
        try:
            cisco_sock.sendall(b"\x03end\r\n")
        except Exception:
            pass
        cisco_sock.close()
        channel.close()
        transport.close()
    except Exception as e:
        print(f"[{name}] Handler error: {e}", flush=True)

def run_bridge(listen_port, telnet_port, name):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", listen_port))
    sock.listen(10)
    print(f"[{name}] SSH Bridge listening on 0.0.0.0:{listen_port} -> 127.0.0.1:{telnet_port}", flush=True)
    while True:
        try:
            client, addr = sock.accept()
            threading.Thread(target=handle_client, args=(client, telnet_port, name), daemon=True).start()
        except Exception as e:
            print(f"[{name}] Accept error: {e}", flush=True)

if __name__ == "__main__":
    t_r = threading.Thread(target=run_bridge, args=(2221, 5000, "router-edge"), daemon=True)
    t_c = threading.Thread(target=run_bridge, args=(2223, 5001, "router-core"), daemon=True)
    t_s = threading.Thread(target=run_bridge, args=(2222, 5003, "switch-access"), daemon=True)
    t_r.start()
    t_c.start()
    t_s.start()
    print("Cisco SSH Bridge daemon active (router-edge: 2221, router-core: 2223, switch-access: 2222).", flush=True)
    while True:
        time.sleep(1)
