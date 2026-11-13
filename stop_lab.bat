@echo off
chcp 65001 >nul
title DUNG HE THONG GITOPS CISCO - AWX
cls
echo ======================================================================
echo          DỪNG TOÀN BỘ CÁC DỊCH VỤ GITOPS (BRIDGE & TUNNEL)
echo ======================================================================
echo.

echo [1/2] Đang dừng Cisco SSH Bridge...
taskkill /F /FI "WINDOWTITLE eq Cisco SSH Bridge*" >nul 2>&1
powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*cisco_bridge.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1

echo [2/2] Đang dừng Cloudflare Tunnel...
taskkill /F /FI "WINDOWTITLE eq Cloudflare Tunnel*" >nul 2>&1
wsl -d kali-linux -u root -- pkill -f cloudflared >nul 2>&1

echo.
echo ======================================================================
echo       ĐÃ DỪNG THÀNH CÔNG TẤT CẢ CÁC TIẾN TRÌNH NỀN!
echo ======================================================================
pause
