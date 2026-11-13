@echo off
chcp 65001 >nul
title KHOI DONG HE THONG GITOPS CISCO - AWX
cls
echo ======================================================================
echo    HỆ THỐNG TỰ ĐỘNG HÓA CẤU HÌNH MẠNG (IaC) GITOPS - CISCO & AWX
echo ======================================================================
echo.

echo [1/5] Kiểm tra và kích hoạt WSL2 (Kali) & Kubernetes K3s (AWX)...
wsl -d kali-linux -u root -- systemctl start k3s
timeout /t 3 >nul

echo [2/5] Khởi động Cisco SSH Bridge (Port 2221: Router, 2222: Switch)...
start "Cisco SSH Bridge (Port 2221-Router, 2222-Switch)" cmd /k "cd /d d:\Qtmv2 && python cisco_bridge.py"

echo [3/5] Khởi động Cloudflare Tunnel cho AWX Webhook...
start "Cloudflare Tunnel (AWX Webhook Public URL)" cmd /k "wsl -d kali-linux -u root -- cloudflared tunnel --url http://10.43.248.169:80"

echo [4/5] Đồng bộ địa chỉ IP mạng tự động (Chống đổi IP)...
python d:\Qtmv2\sync_network_ip.py

for /f "tokens=1" %%i in ('wsl -d kali-linux -u root -- hostname -I') do set CURRENT_WSL_IP=%%i

echo [5/5] Mở phòng Lab GNS3 (Lab-GitOps-Cisco)...
if exist "C:\Program Files\GNS3\gns3.exe" (
    start "" "C:\Program Files\GNS3\gns3.exe" "C:\Users\TechCare\GNS3\projects\Lab-GitOps-Cisco\Lab-GitOps-Cisco.gns3"
) else (
    echo [!] Không tìm thấy GNS3 tại C:\Program Files\GNS3\gns3.exe. Hãy mở GNS3 thủ công.
)

echo Mở trình duyệt truy cập AWX Web Dashboard tại http://%CURRENT_WSL_IP%:30080...
start http://%CURRENT_WSL_IP%:30080

echo.
echo ======================================================================
echo                       KHỞI ĐỘNG HOÀN TẤT!
echo ======================================================================
echo Địa chỉ AWX hiện tại: http://%CURRENT_WSL_IP%:30080
echo 1. Trên GNS3: Bấm nút ▶ (Play màu xanh lá) để Start 2 thiết bị R1 và R3.
echo 2. Trên cửa sổ Cloudflare Tunnel:
echo    - Tìm dòng: https://xxxx-xxxx.trycloudflare.com
echo    - Cập nhật vào GitHub Webhook nếu muốn tự động hóa qua 'git push'.
echo 3. AWX Web UI: http://%CURRENT_WSL_IP%:30080 (admin / AdminPassword@123)
echo    - Template: 'Deploy-Cisco-Network' (ID: 10)
echo ======================================================================
echo Giữ các cửa sổ CMD đang chạy trong suốt buổi demo!
echo.
pause
