# HỆ THỐNG TỰ ĐỘNG HÓA CẤU HÌNH MẠNG (IaC) GITOPS KẾT HỢP ANSIBLE AWX & CISCO IOS

> **Đồ án tốt nghiệp / Chuyên đề:** Xây dựng hệ thống tự động hóa cấu hình mạng (Infrastructure as Code - IaC) sử dụng mô hình GitOps kết hợp Ansible AWX cho thiết bị mạng Cisco IOS  
> **Tác giả:** duccui11259  
> **Repository:** [https://github.com/duccui11259/cisco-iac-gitops.git](https://github.com/duccui11259/cisco-iac-gitops.git)

---

## 1. Kiến trúc hệ thống (System Architecture)

```
[ Quản trị viên (NetOps) ]
            │ (Sửa file YAML / Jinja2)
            ▼
   [ Git / GitHub Repo ]
            │ (Push Event -> Webhook)
            ▼
   [ Cloudflare Tunnel ] (HTTPS Public Ingress)
            │ (Forward Webhook)
            ▼
   [ Ansible AWX (K3s in WSL2) ]
     ├── Project: Cisco-IaC-GitOps (Auto Sync SCM)
     ├── Inventory: Cisco-Lab-Inventory
     └── Job Template: Deploy-Cisco-Network
            │ (Dynamic Runner Pod / SSH)
            ▼
   [ Windows Host SSH Bridge ] (cisco_bridge.py)
     ├── Port 2221 ──► Telnet 127.0.0.1:5000 (Router-Edge: Cisco 7200)
     └── Port 2222 ──► Telnet 127.0.0.1:5003 (Switch-Access: Cisco 3725)
            │
            ▼
     [ GNS3 Network Lab ] (Thiết bị mạng Cisco IOS)
```

---

## 2. Cấu trúc thư mục mã nguồn

```text
d:\Qtmv2/
├── start_lab.bat               # Script khởi động tự động 1-Click toàn bộ hệ thống
├── stop_lab.bat                # Script dừng an toàn các tiến trình nền
├── cisco_bridge.py             # SSH to Telnet Console Bridge Daemon (Port 2221, 2222)
├── bridge_key.pem              # Khóa RSA host key cho SSH Bridge
├── ansible.cfg                 # Cấu hình Ansible tối ưu cho Network Automation
├── hosts.ini                   # Inventory cục bộ kiểm thử (Router & Switch)
├── site.yml                    # Playbook chính điều phối toàn bộ vai trò
├── collections/
│   └── requirements.yml        # Định nghĩa collection cisco.ios và ansible.netcommon
├── group_vars/
│   ├── all.yml                 # Khai báo thông tin xác thực SSH, NTP, Syslog, DNS chung
│   ├── routers.yml             # Biến dùng chung cho toàn bộ Router
│   └── switches.yml            # Khai báo danh sách VLAN cấp phát cho Switch
├── host_vars/
│   ├── router-edge.yml         # Khai báo Interface IP, OSPF, Default Route, ACL
│   └── switch-access.yml       # Khai báo Port Access VLAN, Trunk 802.1Q, SVI Vlan 1
├── roles/
│   ├── base/                   # Cấu hình Hostname, Banner MOTD, Security Hardening
│   ├── interfaces/             # Cấu hình IP Address, L2/L3 Interface State
│   ├── vlans/                  # Cấu hình Database VLAN cho Switch
│   ├── routing/                # Cấu hình Dynamic Routing (OSPF Area 0, Static Route)
│   ├── acls/                   # Cấu hình Standard / Extended Access Control List
│   └── services/               # Cấu hình NTP Server, Syslog Server, VTY Timeout
└── README.md                   # Tài liệu cẩm nang vận hành chi tiết
```

---

## 3. Hướng dẫn khởi động hệ thống (Startup Guide)

### Cách 1: Khởi động tự động bằng 1-Click (Khuyên dùng)
Chỉ cần nhấp đúp chuột vào file:
```cmd
d:\Qtmv2\start_lab.bat
```
Script sẽ tự động:
1. Kích hoạt môi trường WSL2 Kali Linux và dịch vụ Kubernetes K3s chứa AWX.
2. Khởi chạy tiến trình `cisco_bridge.py` trên 2 cổng `2221` (Router) và `2222` (Switch).
3. Khởi chạy `cloudflared` tạo tunnel đưa Webhook AWX ra Internet.
4. Tự động bật phần mềm GNS3 với dự án `Lab-GitOps-Cisco`.
5. Tự động mở trình duyệt web đến giao diện AWX: `http://172.30.44.148:30080`.

**Thao tác của bạn sau khi chạy script:**
- Trên GNS3: Nhấp vào nút **▶ (Start all nodes)** để bật nguồn 2 thiết bị R1 và R3.
- Chờ 15-20 giây cho 2 thiết bị Cisco nạp xong IOS.

---

### Cách 2: Khởi động thủ công từng bước

#### Bước 1: Khởi động GNS3 Lab
1. Mở GNS3, chọn mở dự án: `C:\Users\TechCare\GNS3\projects\Lab-GitOps-Cisco\Lab-GitOps-Cisco.gns3`.
2. Bấm nút Play màu xanh lá để khởi động Router `R1` (c7200) và Switch `R3` (c3725).
3. Đảm bảo cổng Telnet console là:
   - `R1` (`router-edge`): `127.0.0.1:5000`
   - `R3` (`switch-access`): `127.0.0.1:5003`

#### Bước 2: Khởi chạy SSH Bridge trên Windows
Mở CMD / PowerShell tại `d:\Qtmv2` và gõ:
```cmd
python cisco_bridge.py
```
*Kết quả:* Thông báo `SSH Bridge listening on 0.0.0.0:2221` và `0.0.0.0:2222`.

#### Bước 3: Khởi động Kubernetes K3s & AWX trong WSL2
Mở một cửa sổ terminal mới và gõ:
```bash
wsl -d kali-linux -u root -- systemctl start k3s
```
Kiểm tra các Pods của AWX đã ở trạng thái `Running`:
```bash
wsl -d kali-linux -u root -- kubectl get pods -n awx
```
Truy cập AWX qua trình duyệt: `http://172.30.44.148:30080` (Tài khoản: `admin` / `AdminPassword@123`).

#### Bước 4: Khởi chạy Cloudflare Tunnel cho Webhook
Trong terminal WSL2, chạy lệnh:
```bash
cloudflared tunnel --url http://10.43.248.169:80
```
Màn hình sẽ hiển thị đường link có dạng: `https://<subdomain>.trycloudflare.com`.

---

## 4. Cấu hình GitHub Webhook cho GitOps

1. Truy cập vào GitHub Repo: [https://github.com/duccui11259/cisco-iac-gitops/settings/hooks](https://github.com/duccui11259/cisco-iac-gitops/settings/hooks)
2. Nhấn **Add webhook** (hoặc chỉnh sửa webhook hiện có):
   - **Payload URL:** `https://<subdomain>.trycloudflare.com/api/v2/job_templates/10/github/`  
     *(Thay thế subdomain bằng link nhận được từ cửa sổ Cloudflare Tunnel)*
   - **Content type:** `application/json`
   - **Secret:** *(Để trống hoặc điền Webhook Key tương ứng)*
   - **Which events would you like to trigger this webhook?:** `Just the push event.`
   - Tích chọn **Active** và nhấn **Add / Update webhook**.

---

## 5. Quy trình làm việc GitOps hằng ngày (Workflow)

Người quản trị mạng không bao giờ gõ lệnh trực tiếp trên thiết bị (No Direct CLI Access). Mọi thay đổi đều được khai báo dưới dạng Code (Declarative IaC).

### Ví dụ 1: Thêm VLAN 50 (Phòng Nhân Sự) vào Switch
Mở file `group_vars/switches.yml` và thêm vào danh sách:
```yaml
vlan_list:
  - vlan_id: 10
    name: SALES
  - vlan_id: 20
    name: ENGINEERING
  - vlan_id: 30
    name: GUEST
  - vlan_id: 50
    name: HR_DEPT
```

### Ví dụ 2: Thay đổi thông điệp cảnh báo bảo mật (MOTD Banner)
Mở file `roles/base/tasks/main.yml` hoặc `group_vars/all.yml` chỉnh sửa câu chào `banner_motd`.

### Ví dụ 3: Đẩy cấu hình lên hệ thống GitOps
Mở terminal tại thư mục `d:\Qtmv2` và thực hiện 3 lệnh Git:
```bash
git add .
git commit -m "feat: cap nhat vlan 50 phong nhan su"
git push origin main
```

**Điều gì diễn ra tiếp theo? (Hoàn toàn tự động):**
1. GitHub gửi tín hiệu Webhook qua Internet -> Cloudflare Tunnel -> Ansible AWX.
2. AWX tự động kích hoạt Project Update kéo mã nguồn mới nhất về.
3. AWX tự động kích hoạt Job Template `Deploy-Cisco-Network` (ID 10).
4. Runner Pod của AWX chạy Ansible Playbook, kết nối qua SSH Bridge nạp cấu hình xuống Cisco Router và Switch.
5. Kiểm tra trên console GNS3: Gõ `show vlan-switch brief` -> VLAN 50 đã xuất hiện ngay lập tức!

---

## 6. Kịch bản Demo và Thuyết minh bảo vệ Đồ án tốt nghiệp

### Kịch bản Demo trực tiếp trước Hội đồng (3 - 5 phút):
1. **Bước 1: Trình diễn trạng thái ban đầu**
   - Mở Console Switch trên GNS3, gõ lệnh `show vlan-switch brief` để hội đồng thấy chỉ có VLAN 10, 20, 30.
   - Mở màn hình AWX Web UI ở tab **Jobs** để hội đồng thấy lịch sử các lần chạy trước đó.
2. **Bước 2: Thực hiện thay đổi cấu hình mạng qua Git**
   - Mở VS Code / Notepad sửa file `group_vars/switches.yml`, thêm VLAN 99 với tên `MANAGEMENT`.
   - Mở terminal gõ:
     ```bash
     git commit -am "feat: bo sung vlan 99 quan tri theo yeu cau bao mat"
     git push origin main
     ```
3. **Bước 3: Quan sát cơ chế GitOps tự động hóa (The Magic)**
   - Quay lại màn hình AWX: Chỉ cho hội đồng thấy Job mới vừa tự động được kích hoạt mà không cần ai bấm chuột (nhờ GitHub Webhook).
   - Bấm vào Job đang chạy: Chỉ cho hội đồng xem luồng thực thi chi tiết của từng Role (Base -> Interfaces -> VLANs -> Routing -> ACLs -> Services).
   - Kết quả trả về màu xanh lá: `router-edge: ok=9, changed=0`, `switch-access: ok=9, changed=1`.
4. **Bước 4: Kiểm chứng trên thiết bị thực tế**
   - Quay lại console của Cisco Switch, gõ lại `show vlan-switch brief`.
   - VLAN 99 (`MANAGEMENT`) đã hiện diện trên thiết bị.
5. **Bước 5: Chứng minh Tính Lũy Đẳng (Idempotency - Điểm sáng kỹ thuật)**
   - Bấm nút **Relaunch** lại chính Job đó trên AWX mà không thay đổi code.
   - Kết quả: `changed=0` trên toàn bộ thiết bị.
   - Giải thích với hội đồng: *"Hệ thống có tính lũy đẳng cao, nếu trạng thái thực tế của mạng đã khớp với code khai báo thì Ansible sẽ không gửi lệnh can thiệp, tránh việc chớp cổng mạng hoặc reload thiết bị không mong muốn."*

---

## 7. Các câu hỏi phản biện thường gặp & Hướng dẫn trả lời

### Q1: GitOps khác biệt gì so với việc viết script Python (Netmiko/Paramiko) truyền thống?
*Trả lời:*
- **Scripting (Netmiko/Paramiko):** Là phương pháp mệnh lệnh (*Imperative*), tức là lập trình viên phải tự viết từng bước: vào configure terminal, gửi lệnh, kiểm tra lỗi, rollback nếu lỗi. Khó mở rộng, không có cơ chế quản lý phiên bản tập trung, tiềm ẩn rủi ro ghi đè khi nhiều người cùng chạy script.
- **GitOps + Ansible:** Là phương pháp khai báo (*Declarative*), ta chỉ định nghĩa trạng thái mong muốn (*Desired State*). Ansible tự so sánh với trạng thái hiện tại (*Current State*) và chỉ bù đắp phần còn thiếu. Git đóng vai trò là nguồn chân lý duy nhất (*Single Source of Truth*), có đầy đủ lịch sử commit (ai sửa, sửa lúc nào, lý do gì) và có thể Rollback chỉ bằng 1 lệnh `git revert`.

### Q2: Quản lý mật khẩu và thông tin nhạy cảm của thiết bị mạng như thế nào để đảm bảo an toàn?
*Trả lời:*
- Không bao giờ lưu mật khẩu dạng bản rõ (plaintext) trong kho lưu trữ Git công khai.
- Trong hệ thống này, các thông tin đăng nhập được quản lý bằng **AWX Credentials Management** (được mã hóa lưu trong cơ sở dữ liệu PostgreSQL của AWX với Secret Key riêng biệt) hoặc sử dụng **Ansible Vault** với thuật toán AES-256 để mã hóa các biến nhạy cảm trước khi commit lên Git.
- AWX cung cấp cơ chế phân quyền RBAC (Role-Based Access Control) cho phép kỹ sư vận hành có thể bấm chạy Job mà không cần biết mật khẩu thật của thiết bị.

### Q3: Nếu cấu hình mới bị lỗi hoặc làm mất kết nối mạng thì hệ thống khắc phục thế nào (Rollback)?
*Trả lời:*
- Nhờ có Git, việc khôi phục trạng thái mạng trở về phiên bản ổn định trước đó cực kỳ nhanh chóng và an toàn. Chỉ cần thực hiện:
  ```bash
  git revert HEAD
  git push origin main
  ```
- Webhook sẽ kích hoạt AWX áp dụng lại cấu hình của phiên bản trước đó ngay lập tức, đưa toàn bộ hệ thống mạng trở về trạng thái ổn định ban đầu chỉ trong vòng vài giây.

### Q4: Tại sao đồ án sử dụng Ansible AWX thay vì Ansible CLI đơn thuần trên máy tính cá nhân?
*Trả lời:*
- Ansible CLI chạy trên máy cá nhân không đáp ứng được tiêu chuẩn doanh nghiệp vì: phân tán, không có nhật ký kiểm toán tập trung (Audit Log), không có giao diện Web, không có Webhook tự động nhận sự kiện từ Git, và phụ thuộc vào máy của từng kỹ sư.
- **AWX** là phiên bản mã nguồn mở của Red Hat Ansible Automation Platform:
  - Cung cấp Web UI trực quan, Dashboard giám sát tập trung.
  - Hỗ trợ REST API và Webhook tiếp nhận sự kiện tự động từ CI/CD / GitOps.
  - Quản lý tài nguyên bằng Container (K3s/Kubernetes), mỗi tác vụ chạy trong môi trường Runner Pod cô lập (Execution Environment).
  - Kiểm soát người dùng chặt chẽ qua phân quyền RBAC và lưu trữ lịch sử mọi lần triển khai.

---

## 8. Dừng hệ thống khi không sử dụng
Khi kết thúc buổi làm việc hoặc demo, nhấp đúp vào file:
```cmd
d:\Qtmv2\stop_lab.bat
```
Toàn bộ các tiến trình Python SSH Bridge và Cloudflare Tunnel sẽ được đóng một cách an toàn.
