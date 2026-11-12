# HỆ THỐNG TỰ ĐỘNG HÓA CẤU HÌNH MẠNG (IaC) GITOPS KẾT HỢP ANSIBLE AWX

Đồ án tốt nghiệp: **Xây dựng hệ thống tự động hóa cấu hình mạng (IaC) sử dụng mô hình GitOps kết hợp Ansible AWX cho thiết bị Cisco IOS**

---

## 1. Cấu trúc thư mục dự án

```text
d:\Qtmv2/
├── ansible.cfg                 # Cấu hình Ansible tối ưu cho thiết bị mạng
├── hosts.ini                   # Inventory phân nhóm Router và Switch
├── site.yml                    # Playbook chính điều phối toàn bộ
├── group_vars/
│   ├── all.yml                 # Tài khoản SSH và tham số kết nối chung
│   └── switches.yml            # Danh sách khai báo VLAN cho nhóm switch
├── roles/
│   ├── base/tasks/main.yml     # Role cấu hình Hostname và Banner
│   ├── vlans/tasks/main.yml    # Role cấu hình VLAN (Resource Module)
│   └── routing/tasks/main.yml  # Role cấu hình OSPF Area 0
├── setup_ubuntu_awx.sh         # Script tự động dựng AWX trên máy ảo Ubuntu
└── README.md                   # Hướng dẫn chi tiết
```

---

## 2. Các bước thực hiện

### Bước 1: Dựng AWX trên máy ảo Ubuntu Server (VMware)
1. Copy file `setup_ubuntu_awx.sh` vào máy ảo Ubuntu Server (qua WinSCP, SCP hoặc mở nano paste vào).
2. Cấp quyền thực thi và chạy script:
   ```bash
   chmod +x setup_ubuntu_awx.sh
   sudo ./setup_ubuntu_awx.sh
   ```
3. Đợi 3 - 5 phút để hệ thống build DB, sau đó mở trình duyệt truy cập:
   - **URL**: `http://<IP_UBUNTU_SERVER>`
   - **User**: `admin`
   - **Password**: `AdminPassword@123`

### Bước 2: Đẩy mã nguồn này lên GitHub của bạn
Trên máy tính hiện tại (tại thư mục `d:\Qtmv2`):
```bash
git init
git add .
git commit -m "feat: khoi tao ma nguon Ansible IaC Cisco"
git branch -M main
git remote add origin https://github.com/<tai-khoan-github>/cisco-iac-gitops.git
git push -u origin main
```

### Bước 3: Cấu hình trên AWX Web UI
1. **Credentials**: Tạo Credential kiểu `Machine` (User: `admin`, Pass: `CiscoSSHPassword123!`, Enable Secret: `CiscoEnableSecret123!`).
2. **Projects**: Tạo Project liên kết tới URL GitHub của bạn, tích chọn `Update Revision on Launch`.
3. **Job Templates**: Tạo Template chọn Playbook `site.yml`, tích chọn `Enable Webhook`, chọn dịch vụ `GitHub`, tạo Webhook Key.
4. **GitHub Webhooks**: Copy URL Webhook và Key từ AWX dán vào mục **Settings -> Webhooks** trên GitHub.

### Bước 4: Kiểm thử kịch bản GitOps
Mỗi khi bạn sửa file `group_vars/switches.yml` (ví dụ thêm VLAN mới) rồi gõ:
```bash
git commit -am "feat: bo sung vlan moi"
git push
```
GitHub sẽ kích hoạt Webhook sang AWX, AWX sẽ tự động chạy Playbook cập nhật cấu hình xuống thiết bị mạng Cisco.
