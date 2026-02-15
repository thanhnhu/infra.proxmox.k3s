module "k3s_master" {
  source     = "../../modules/vm"
  node_name  = var.node_name
  vmid       = 101
  name       = "k3s-master"
  template   = "debian-12-cloud"
  cores      = 2
  memory     = 4096
  disk_size  = "30G"
  storage    = "local"
  ip         = "192.168.1.101"
  gateway    = var.gateway
  password   = "admin"
  #ssh_key    = var.ssh_key
}

module "k3s_worker" {
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 102
  hostname   = "k3s-worker"
  template   = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "20G"
  storage    = "local"
  ip         = "192.168.1.102"
  gateway    = var.gateway
  password   = "admin"
}

module "database" {
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 110
  hostname   = "database"
  template   = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "30G"
  storage    = "local"
  ip         = "192.168.1.110"
  gateway    = var.gateway
  password   = "admin"
}

module "rancher" {
  source     = "../../modules/lxc"
  node_name  = var.node_name
  vmid       = 200
  hostname   = "rancher"
  template   = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "30G"
  storage    = "local"
  ip         = "192.168.1.200"
  gateway    = var.gateway
  password   = "admin"
}
