resource "proxmox_vm_qemu" "vm" {
  target_node = var.node
  name        = var.name
  clone       = var.template

  cores  = var.cores
  memory = var.memory

  disk {
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=${var.ip}/24,gw=${var.gateway}"

  ciuser = "debian"
  #sshkeys = var.ssh_key
}