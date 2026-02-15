resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.node_name
  vm_id     = var.vmid
  name      = var.name

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.storage
    interface    = "scsi0"
    size         = var.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }
}