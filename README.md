# Setup network on Contabo VPS
nano /etc/network/interfaces
-----------------------------------------------------------------------------
auto vmbr1
iface vmbr1 inet static
        address 192.168.1.1/24  # IP của Host trên bridge này
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        # Kích hoạt NAT để LXC đi ra internet qua vmbr0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up iptables -t nat -A POSTROUTING -s '192.168.1.0/24' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '192.168.1.0/24' -o vmbr0 -j MASQUERADE
-----------------------------------------------------------------------------

# Setup GitHub Self-Hosted Runner in LAN by LXC (Proxmox local - depends on storage)
pct create 100 local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst \
  --hostname gh-runner \
  --cores 2 \
  --memory 2048 \
  --rootfs local:20 \
  --net0 name=eth0,bridge=vmbr1,ip=192.168.1.100/24,gw=192.168.1.1 \
  --unprivileged 0 \
  --features nesting=1,fuse=1
pct start 100
pct enter 100
apt update
apt install -y curl git unzip sudo ca-certificates
adduser runner
usermod -aG sudo runner
su - runner

## Download GitHub Runner
Settings → Actions → Runners → New self-hosted runner → Linux x64

## Trong LXC, following github setup
mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz

## Configure Runner
./config.sh --url https://github.com/thanhnhu/infra.proxmox.k3s --token AIB4KE3DDH4RBYNGCMSGUWLJSIAOC
Nhập:
- Repository URL
- Token
- Runner name → proxmox-lxc-runner
- Labels → proxmox,lan,lxc
- Work folder → Enter

./run.sh
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status

## Cài Terraform trong LXC
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository \
  "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt update
sudo apt install terraform -y
terraform -version

## Cấu hình GitHub Secrets
Settings → Secrets and variables → Actions
Tạo:
PM_API_URL = https://192.168.1.10:8006
PM_USER = terraform@pve
PM_PASSWORD hoặc PM_API_TOKEN


# Cloud Image Debian cho Proxmox
## Download Debian 12 cloud image
cd /var/lib/vz/template/iso
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

## Import vào Proxmox
qm create 9000 --name debian-12-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

qm importdisk 9000 debian-12-genericcloud-amd64.qcow2 local-lvm

qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot order=scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000


# Deploy dev/prod
cd terraform/environments/dev
terraform init
terraform apply


# Chạy ansible prod
cd ansible
ansible-playbook -i inventories/prod.ini site.yml


# Semaphore để chạy Ansible
docker-compose up -d


# Helm deploy app vào K3s
## Trên lxc-k3s-master
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install nginx bitnami/nginx


# Rancher bằng Helm
## Sau khi k3s chạy
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

kubectl create namespace cattle-system

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.local
