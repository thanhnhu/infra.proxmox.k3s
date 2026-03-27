terraform {
  backend "local" {
    path = "/opt/terraform/state/prod/terraform.tfstate"
  }
}

module "rancher" {
  count      = 0 # disable deploy
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 111
  hostname   = "rancher"
  template   = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  cores      = 2
  memory     = 4096
  swap       = 0 # disable swap memory
  disk_size  = "15"
  storage    = "local-lvm"
  ip         = "192.168.2.111"
  gateway    = var.gateway

  #password    = var.lxc_password
  #ssh_key     = var.ssh_key
  pm_host      = var.pm_host
  pm_user      = var.pm_user
  pm_password  = var.pm_password
  lxc_user     = var.lxc_user
  lxc_password = var.lxc_password
  lxc_ssh_key  = var.lxc_ssh_key
}

module "database" {
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 110
  hostname   = "database"
  template   = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  cores      = 2
  memory     = 3072
  swap       = 0 # disable swap memory
  disk_size  = "30"
  storage    = "local-lvm"
  ip         = "192.168.2.110"
  gateway    = var.gateway

  #password    = var.lxc_password
  #ssh_key     = var.ssh_key
  pm_host      = var.pm_host
  pm_user      = var.pm_user
  pm_password  = var.pm_password
  lxc_user     = var.lxc_user
  lxc_password = var.lxc_password
  lxc_ssh_key  = var.lxc_ssh_key
}

module "k3s_master_vm" {
  count         = 0 # disable deploy
  vms = {
    k3s-master  = { ip = "192.168.2.130", id = 0 }
    #k3s-node1  = { ip = "192.168.2.131", id = 1 }
    #k3s-node2  = { ip = "192.168.2.132", id = 2 }
  }

  source        = "../../modules/vm"
  node_name     = var.node_name
  vmid          = 130
  #name         = "k3s-master"
  template_id   = 9000
  cores         = 4
  memory        = 4096
  disk_size     = 30
  storage       = "local-lvm"
  #ip           = "192.168.2.130"
  gateway       = var.gateway

  #pm_host      = var.pm_host
  #pm_user      = var.pm_user
  #pm_password  = var.pm_password
  vm_user       = var.lxc_user
  vm_password   = var.lxc_password
  vm_ssh_keys   = [var.lxc_ssh_key]
}

module "k3s_master" {
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 120
  hostname   = "k3s-master"
  template   = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  cores      = 4
  memory     = 4096
  swap       = 0 # disable swap memory
  disk_size  = "30"
  storage    = "local-lvm"
  ip         = "192.168.2.120"
  gateway    = var.gateway

  #password    = var.vm_password
  #ssh_key     = var.ssh_key
  pm_host      = var.pm_host
  pm_user      = var.pm_user
  pm_password  = var.pm_password
  lxc_user     = var.lxc_user
  lxc_password = var.lxc_password
  lxc_ssh_key  = var.lxc_ssh_key
}

module "k3s_worker" {
  count      = 0 # disable deploy
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 121
  hostname   = "k3s-worker"
  template   = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  swap       = 0 # disable swap memory
  disk_size  = "15"
  storage    = "local-lvm"
  ip         = "192.168.2.121"
  gateway    = var.gateway

  #password    = var.lxc_password
  #ssh_key     = var.ssh_key
  pm_host      = var.pm_host
  pm_user      = var.pm_user
  pm_password  = var.pm_password
  lxc_user     = var.lxc_user
  lxc_password = var.lxc_password
  lxc_ssh_key  = var.lxc_ssh_key
}