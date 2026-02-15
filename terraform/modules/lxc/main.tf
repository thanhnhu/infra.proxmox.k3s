resource "proxmox_virtual_environment_container" "lxc" {
  node_name = var.node_name
  vm_id     = var.vmid
  started   = true

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = "${var.ip}/24"
        gateway = var.gateway
      }
    }

    user_account {
      password = var.password
    }
  }

  operating_system {
    template_file_id = var.template
    type             = "debian"
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.storage
    size         = var.disk_size
  }

  network_interface {
    name = "eth0"
    bridge = "vmbr1"
  }
}