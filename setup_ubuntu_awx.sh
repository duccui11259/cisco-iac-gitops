#!/usr/bin/env bash
# ==============================================================================
# SCRIPT TỰ ĐỘNG DỰNG ANSIBLE AWX TRÊN UBUNTU SERVER (VMWARE) BẰNG DOCKER COMPOSE
# Đồ án tốt nghiệp: Xây dựng hệ thống tự động hóa cấu hình mạng (IaC) GitOps + AWX
# ==============================================================================

set -e

# Đổi màu hiển thị terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}  BAT DAU CAI DAT DOCKER, DOCKER COMPOSE VA ANSIBLE AWX CHO LAB   ${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Kiem tra quyen root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Vui long chay script voi quyen sudo: sudo ./setup_ubuntu_awx.sh${NC}"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}

# 2. Cap nhat he thong va cai dat cac goi co ban
echo -e "${YELLOW}[1/5] Cap nhat Repository va cai dat cac goi can thiet...${NC}"
apt-get update -y
apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release git net-tools

# 3. Cai dat Docker Engine chinh thuc
echo -e "${YELLOW}[2/5] Cai dat Docker va Docker Compose Plugin chinh thuc tu Docker Inc...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker "$REAL_USER"

# 4. Clone AWX on Docker va cau hinh .env
echo -e "${YELLOW}[3/5] Tai ma nguon AWX on Docker va cau hinh file moi truong .env...${NC}"
mkdir -p /opt
cd /opt

if [ -d "/opt/awx-on-docker" ]; then
  echo -e "${CYAN}[i] Thu muc /opt/awx-on-docker da ton tai. Tien hanh cap nhat...${NC}"
  cd /opt/awx-on-docker
  git pull || true
else
  git clone https://github.com/kurokobo/awx-on-docker.git /opt/awx-on-docker
  cd /opt/awx-on-docker
fi

chown -R "$REAL_USER":"$REAL_USER" /opt/awx-on-docker

# Tao file .env neu chua co hoac ghi de theo chuan Lab
cat << 'EOF' > /opt/awx-on-docker/.env
# =====================================================================
# FILE MOI TRUONG AWX ON DOCKER
# =====================================================================
AWX_VERSION=24.6.1
HOST_PORT=80
AWX_ADMIN_USER=admin
AWX_ADMIN_PASSWORD=AdminPassword@123
SECRET_KEY=DuAnTotNghiepGitOpsAnsibleAWXSecretKey2026
POSTGRES_DB=awx
POSTGRES_USER=awx
POSTGRES_PASSWORD=awxpostgrespassword
EOF

# 5. Khoi chay Docker Compose
echo -e "${YELLOW}[4/5] Khoi chay he thong AWX qua Docker Compose (chay nen)...${NC}"
cd /opt/awx-on-docker
docker compose up -d

SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}[SUCCESS] HE THONG DANG KHOI TAO THANH CONG!${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "Cac Container dang khoi dong va thuc hien Migrate Database (khoang 3 - 5 phut)."
echo -e "Theo doi tien trinh khoi tao bang lenh:"
echo -e "   ${YELLOW}docker compose -f /opt/awx-on-docker/docker-compose.yml logs -f awx-web${NC}"
echo -e ""
echo -e "Sau khi khoi tao xong, truy cap giao dien Web tai dia chi:"
echo -e "   URL:      ${GREEN}http://${SERVER_IP}${NC} (hoac http://localhost)"
echo -e "   Username: ${GREEN}admin${NC}"
echo -e "   Password: ${GREEN}AdminPassword@123${NC}"
echo -e "${CYAN}==================================================================${NC}"
