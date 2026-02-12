module "k3s_master" {
  source     = "../../modules/vm"
  name       = "k3s-master"
  node       = var.node_name
  template   = "ubuntu-22.04-cloud"
  cores      = 2
  memory     = 4096
  disk_size  = "30G"
  storage    = "local-lvm"
  ip         = "192.168.1.10"
  gateway    = var.gateway
  ssh_key    = var.ssh_key
}

module "k3s_worker" {
  source     = "../../modules/lxc"
  hostname   = "k3s-worker"
  node       = var.node_name
  template   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "20G"
  storage    = "local-lvm"
  ip         = "192.168.1.11"
  gateway    = var.gateway
  password   = "changeme"
}

module "database" {
  source     = "../../modules/lxc"
  hostname   = "database"
  node       = var.node_name
  template   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "30G"
  storage    = "local-lvm"
  ip         = "192.168.1.100"
  gateway    = var.gateway
  password   = "changeme"
}

module "rancher" {
  source     = "../../modules/lxc"
  hostname   = "rancher"
  node       = var.node_name
  template   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  cores      = 2
  memory     = 2048
  disk_size  = "20G"
  storage    = "local-lvm"
  ip         = "192.168.1.200"
  gateway    = var.gateway
  password   = "changeme"
}
