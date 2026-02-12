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
