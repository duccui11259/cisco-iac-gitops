#!/usr/bin/env bash
# ==============================================================================
# SCRIPT TỰ ĐỘNG DỰNG ANSIBLE AWX TRÊN UBUNTU SERVER (K3S + AWX OPERATOR)
# Chuẩn kiến trúc chính thức của Red Hat & Ansible cho Lab đồ án tốt nghiệp
# ==============================================================================

set -e

# Đổi màu hiển thị terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}  BAT DAU CAI DAT ANSIBLE AWX (K3S + AWX OPERATOR) CHO PHONG LAB   ${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Kiem tra quyen root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Vui long chay script voi quyen sudo: sudo ./setup_ubuntu_awx.sh${NC}"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}

# 2. Cai dat K3s (Lightweight Kubernetes cua Rancher - rat nhe cho may ao)
echo -e "${YELLOW}[1/5] Cai dat K3s (Kubernetes sieu nhe)...${NC}"
curl -sfL https://get.k3s.io | sh -

# Thiet lap bien moi truong kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
chmod 644 /etc/rancher/k3s/k3s.yaml
mkdir -p /home/"$REAL_USER"/.kube
cp /etc/rancher/k3s/k3s.yaml /home/"$REAL_USER"/.kube/config
chown -R "$REAL_USER":"$REAL_USER" /home/"$REAL_USER"/.kube

echo -e "${CYAN}[i] Cho node K3s san sang...${NC}"
until kubectl get node &>/dev/null; do
  sleep 2
done

# 3. Clone du an chuan kurokobo/awx-on-k3s
echo -e "${YELLOW}[2/5] Tai ma nguon kurokobo/awx-on-k3s tu GitHub...${NC}"
rm -rf /opt/awx-on-k3s
git clone https://github.com/kurokobo/awx-on-k3s.git /opt/awx-on-k3s
cd /opt/awx-on-k3s

# 4. Cai dat AWX Operator
echo -e "${YELLOW}[3/5] Trien khai AWX Operator...${NC}"
kubectl apply -k operator

# 5. Cau hinh mat khau Admin va NodePort de truy cap truc tiep qua IP:30080
echo -e "${YELLOW}[4/5] Cau hinh mat khau Admin va Port truy cap Web...${NC}"

# Tao thu muc luu tru du lieu ben vung
mkdir -p /data
chmod 777 /data

# Dat mat khau Admin la AdminPassword@123
sed -i 's/password=password/password=AdminPassword@123/g' /opt/awx-on-k3s/base/kustomization.yaml

# Cau hinh AWX truy cap qua NodePort 30080 (Khong can mua domain hay sua file hosts)
cat << 'EOF' > /opt/awx-on-k3s/base/awx.yaml
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
  namespace: awx
spec:
  service_type: nodeport
  nodeport_port: 30080
  admin_user: admin
  admin_password_secret: awx-admin-password
  projects_persistence: true
  projects_existing_claim: awx-projects-claim
EOF

# 6. Trien khai AWX
echo -e "${YELLOW}[5/5] Khoi tao toan bo cac Pod cua AWX...${NC}"
kubectl apply -k base

SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}[SUCCESS] HE THONG AWX DANG DUOC KHOI TAO THANH CONG!${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "Cac Pod AWX dang duoc tai ve va tao Database (khoang 3 - 5 phut)."
echo -e "Theo doi trang thai tien trinh bang lenh:"
echo -e "   ${YELLOW}kubectl -n awx get pods -w${NC}"
echo -e ""
echo -e "Khi thay cac Pod 'awx-web' va 'awx-task' co trang thai ${GREEN}Running${NC} (1/1 hoac 4/4):"
echo -e "Ban mo trinh duyet Web tren may tinh truy cap tai:"
echo -e "   URL:      ${GREEN}http://${SERVER_IP}:30080${NC}"
echo -e "   Username: ${GREEN}admin${NC}"
echo -e "   Password: ${GREEN}AdminPassword@123${NC}"
echo -e "${CYAN}==================================================================${NC}"
