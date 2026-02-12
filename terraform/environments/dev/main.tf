module "k3s_master" {
  source     = "../../modules/vm"
  name       = "k3s-master"
  node       = var.node_name
  template   = "debian-12-template"
  cores      = 2
  memory     = 4096
  disk_size  = "30G"
  storage    = "local"
  ip         = "192.168.1.10"
  gateway    = var.gateway
  ssh_key    = var.ssh_key
}

module "k3s_worker" {
  source     = "../../modules/lxc"
  hostname   = "k3s-worker"
  node       = var.node_name
  cores      = 2
  memory     = 2048
  disk_size  = "20G"
  storage    = "local"
  ip         = "192.168.1.11"
  gateway    = var.gateway
  password   = "admin"
}

module "database" {
  source     = "../../modules/lxc"
  hostname   = "database"
  node       = var.node_name
  cores      = 2
  memory     = 2048
  disk_size  = "30G"
  storage    = "local"
  ip         = "192.168.1.100"
  gateway    = var.gateway
  password   = "admin"
}

module "rancher" {
  source     = "../../modules/lxc"
  hostname   = "rancher"
  node       = var.node_name
  cores      = 2
  memory     = 2048
  disk_size  = "20G"
  storage    = "local"
  ip         = "192.168.1.200"
  gateway    = var.gateway
  password   = "admin"
}
