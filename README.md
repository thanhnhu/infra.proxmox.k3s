# I. Infrastructure Deployment on Proxmox (Home/VPS-Contabo)

## 1. Setup network on Contabo VPS only

```bash
nano /etc/network/interfaces
```

```console
auto vmbr1
iface vmbr1 inet static
        address 192.168.2.1/24  # Host IP on current bridge
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        # Set NAT allow LXC access internet via vmbr0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up iptables -t nat -A POSTROUTING -s '192.168.2.0/24' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '192.168.2.0/24' -o vmbr0 -j MASQUERADE
```

## 2. Setup GitHub Self-Hosted Runner in LXC (Proxmox local - depends on storage)
### This can use Proxmox or VM/LXC to run GitHub Runner

Download Debian 13 (Trixie) LXC in Proxmox Templates or [here](http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst)

### Create LXC on Home Proxmox
```bash
pct create 200 local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst \
  --hostname github-runner \
  --cores 2 \
  --memory 2048 \
  --swap 0 \
  --rootfs local-lvm:20 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.2.200/24,gw=192.168.2.1,firewall=1 \
  --unprivileged 0 \
  --features nesting=1,fuse=1 \
  --onboot 1
```

### Or create LXC on VPS Proxmox (Contabo)
```bash
pct create 200 local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst \
  --hostname github-runner \
  --cores 2 \
  --memory 2048 \
  --swap 0 \
  --rootfs local:20 \
  --net0 name=eth0,bridge=vmbr1,ip=192.168.2.200/24,gw=192.168.2.1,firewall=1 \
  --unprivileged 0 \
  --features nesting=1,fuse=1 \
  --onboot 1
```

### Install dependencies
```bash
pct set 200 --nameserver 8.8.8.8
pct start 200
pct enter 200

apt update
apt install -y \
  sudo \
  git \
  curl \
  unzip \
  ca-certificates \
  gnupg \
  docker.io

adduser runner
usermod -aG sudo runner

curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sudo apt install -y python3-pip python3-venv

# Create folder for Terraform state file
sudo mkdir -p /opt/terraform/state/dev
sudo mkdir -p /opt/terraform/state/prod
sudo chown -R runner:runner /opt/terraform/state
sudo chown -R runner:runner /opt/terraform
```

### Install GitHub Runner
Settings → Actions → Runners → New self-hosted runner → Linux x64

#### In LXC, following Github setup

```bash
su - runner

#mkdir actions-runner && cd actions-runner

#curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz

#tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
```

#### Configure Runner
```bash
#./config.sh --url https://github.com/thanhnhu/infra.proxmox.k3s --token AIB4KE3DDH4RBYNGCMSGUWLJSIAOC
```
Runner name → github-runner

```bash
./run.sh
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
```

```bash
su -
sudo visudo # input end of file
```

```console
runner ALL=(ALL) NOPASSWD: ALL
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart "actions.runner.*"
sudo -u runner sudo -n /usr/sbin/pct list
```

### Working folder
```bash
#cd _work/infra.proxmox.k3s/infra.proxmox.k3s
```

### Check user on VM/LXC
```bash
cat /etc/passwd | grep bash
```

### Install Terraform in LXC
```bash
#curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#sudo apt install gnupg -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com trixie main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y
terraform -version
```

### Config GitHub Secrets
Settings → Secrets and variables → Actions \
Create: \
PM_API_URL = https://192.168.2.100:8006 \
PM_HOST = 192.168.2.100 \
PM_USER = terraform@pve | root@pam \
PM_PASSWORD hoặc PM_API_TOKEN \
PM_NODE_NAME = vmi2685714 | pve \
LXC_USER = admin \
LXC_PASSWORD = \
K3S_SUBNET = 192.168.2.0/24 \
CF_TUNNEL_JSON = sudo cat /etc/cloudflared/{{ tunnel_id }}.json | base64 -w 0 \
LF_GOOGLE_MAPS_API_KEY = AIza... \
LF_FB_APP_ID = <facebook_app_id> \
LF_EMAIL_USERNAME = your_email@gmail.com \
LF_EMAIL_PASSWORD = <gmail_app_password_16chars_no_spaces> \
# Note: config.json is built by Ansible from the above secrets \

Refs: \
https://github.com/thanhnhu/local.friends \
https://github.com/thanhnhu/GiveAndTake

### Deploy by run
Home GitHub workflow [infra-prod-cd.yml](https://github.com/thanhnhu/infra.proxmox.k3s/blob/master/.github/workflows/infra-prod-cd.yml) or \
VPS GitHub workflow [infra-dev-cd.yml](https://github.com/thanhnhu/infra.proxmox.k3s/blob/master/.github/workflows/infra-dev-cd.yml)

All Done!

### Install kubectl
```bash
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# K3s includes kubectl built-in — just create a symlink
sudo ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
sudo k3s kubectl version --client
ls -l /tmp/k3s.yaml
export KUBECONFIG=/tmp/k3s.yaml
echo "export KUBECONFIG=/tmp/k3s.yaml" >> ~/.bashrc
# List k3s ingress
sudo k3s kubectl get ingress -A
```

### Check Cloudflared config
```bash
pct enter 200
cloudflared --version
ls -la /etc/cloudflared
cat /etc/cloudflared/config.yml
```

## 3. Login ArgoCD Web as admin, in K3s-master
```bash
sudo k3s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 4. Config on Semaphore (Web UI)
1. Key Store -> Add Key \
Type: Login with Password \
User: root
2. Repositories -> Create New \
Select Local \
Path: /etc/semaphore/playbooks (path inside container)
3. Inventory -> Create New \
Select File \
Path: inventories/dev/hosts.yml
4. Task Template -> Create New Ansible Playbook \
Path to playbook file: playbook.yml \
Click Run

## 5. Login Grafana as admin/admin
http://<GRAFANA_IP>:3000 or http://<GRAFANA_IP>:3000

### Connect Prometheus
1. Connections -> Data sources
2. Add data source -> Prometheus
3. Prometheus server URL -> http://localhost:9090

### Import Dashboard
1. Dashboards -> New -> Import
2. Import via grafana.com -> ID: 1860 -> Load -> Data Source: Prometheus previous step -> Import


# II. This setup VM by Debian Cloud Image in Proxmox
## 1. Download Debian 13 Cloud Image
```bash
cd /var/lib/vz/template/iso
wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
```

## 2. Import into Proxmox & Init template
```bash
qm create 9000 --name debian-13-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 && \
qm importdisk 9000 debian-13-genericcloud-amd64.qcow2 local-lvm && \
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0 && \
qm set 9000 --ide2 local-lvm:cloudinit && \
qm set 9000 --boot c --bootdisk scsi0 && \
qm set 9000 --serial0 socket --vga serial0

qm set 9000 --ciuser admin
qm set 9000 --cipassword admin
qm set 9000 --ipconfig0 ip=192.168.2.10/24,gw=192.168.2.1

qm start 9000
ssh admin@192.168.2.10

sudo apt update
sudo apt install -y qemu-guest-agent docker.io
sudo systemctl enable qemu-guest-agent
sudo systemctl start qemu-guest-agent

sudo cloud-init clean
sudo shutdown now
qm template 9000
```